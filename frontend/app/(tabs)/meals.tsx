import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { MealCard } from "@/src/components/MealCard";
import { ProgressBar } from "@/src/components/ProgressBar";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { fetchMealsForDate } from "@/src/services/db";
import type { Meal } from "@/src/types/models";
import { defaultMealsForDate } from "@/src/services/seed";

const ORDER: Meal["type"][] = ["breakfast", "lunch", "snack", "dinner"];
const GOAL = 2000;

function todayStr() {
  return new Date().toISOString().split("T")[0];
}

export default function MealsList() {
  const router = useRouter();
  const { user } = useAuth();
  const [meals, setMeals] = useState<Meal[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    if (!user) return;
    const today = todayStr();
    let list = await fetchMealsForDate(user.uid, today);
    if (list.length === 0) list = defaultMealsForDate(today);
    setMeals(list);
  };

  useEffect(() => {
    load().catch(() => {});
  }, [user?.uid]);

  const onRefresh = async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  };

  const totalIntake = useMemo(
    () => meals.reduce((s, m) => s + (m.calories ?? 0), 0),
    [meals],
  );

  const ordered = useMemo(() => {
    const byType: Record<string, Meal> = {};
    for (const m of meals) byType[m.type] = m;
    return ORDER.map((t) => byType[t]).filter(Boolean) as Meal[];
  }, [meals]);

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        <Text style={styles.title}>Meal Planner</Text>
        <Text style={styles.subtitle}>Track your daily nutrition</Text>

        <View style={[styles.intakeCard, SHADOW_CARD]} testID="meals-intake-card">
          <View style={styles.intakeRow}>
            <View>
              <Text style={styles.intakeLabel}>Daily Intake</Text>
              <Text style={styles.intakeValue}>{totalIntake.toLocaleString()} kcal</Text>
            </View>
            <View style={{ alignItems: "flex-end" }}>
              <Text style={styles.intakeLabel}>Goal</Text>
              <Text style={styles.goalValue}>{GOAL.toLocaleString()} kcal</Text>
            </View>
          </View>
          <View style={{ marginTop: 12 }}>
            <ProgressBar
              value={Math.min(1, totalIntake / GOAL)}
              color={COLORS.cta.logMeal}
              trackColor={COLORS.background}
            />
          </View>
        </View>

        <View style={{ gap: 12, marginTop: 16 }}>
          {ordered.map((m) => (
            <MealCard
              key={m.id}
              meal={m}
              testID={`meal-card-${m.type}`}
              onPress={() => router.push(`/meals/${m.type}`)}
              onAdd={() => router.push(`/meals/edit/${m.type}`)}
            />
          ))}
        </View>

        <View style={{ marginTop: 18 }}>
          <PrimaryButton
            label="Save Entry"
            color={COLORS.cta.logMeal}
            onPress={() => router.push(`/meals/edit/breakfast`)}
            testID="meals-save-entry-button"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { paddingHorizontal: 16, paddingVertical: 16, paddingBottom: 32 },
  title: { color: COLORS.text.primary, fontSize: 26, fontWeight: "800", letterSpacing: -0.6 },
  subtitle: { color: COLORS.text.tertiary, fontSize: 13, marginTop: 2 },
  intakeCard: { marginTop: 16, backgroundColor: COLORS.card, borderRadius: 20, padding: 18 },
  intakeRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  intakeLabel: { color: COLORS.text.tertiary, fontSize: 12, fontWeight: "700", letterSpacing: 0.6, textTransform: "uppercase" },
  intakeValue: { color: COLORS.text.primary, fontSize: 24, fontWeight: "800", letterSpacing: -0.5, marginTop: 2 },
  goalValue: { color: COLORS.cta.logMeal, fontSize: 18, fontWeight: "800", marginTop: 2 },
});
