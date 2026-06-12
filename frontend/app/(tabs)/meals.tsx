import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl, TouchableOpacity } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useFocusEffect, useRouter } from "expo-router";
import { BookOpen, Plus } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { MealCard } from "@/src/components/MealCard";
import { ProgressBar } from "@/src/components/ProgressBar";
import { useAuth } from "@/src/context/AuthContext";
import { fetchMealsForDate, toggleMealEaten, saveMeal } from "@/src/services/db";
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
    if (list.length === 0) {
      list = defaultMealsForDate(today);
      // Persist defaults so they show up across sessions
      for (const m of list) await saveMeal(user.uid, m);
    }
    setMeals(list);
  };

  useEffect(() => {
    load().catch(() => {});
  }, [user?.uid]);

  useFocusEffect(
    React.useCallback(() => {
      load().catch(() => {});
    }, [user?.uid]),
  );

  const onRefresh = async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  };

  const eatenIntake = useMemo(
    () => meals.filter((m) => m.eaten).reduce((s, m) => s + (m.calories ?? 0), 0),
    [meals],
  );

  const ordered = useMemo(() => {
    const byType: Record<string, Meal> = {};
    for (const m of meals) byType[m.type] = m;
    return ORDER.map((t) => byType[t]).filter(Boolean) as Meal[];
  }, [meals]);

  const onToggle = async (meal: Meal, next: boolean) => {
    if (!user) return;
    // Optimistic update
    setMeals((prev) => prev.map((m) => (m.type === meal.type ? { ...m, eaten: next } : m)));
    try {
      await toggleMealEaten(user.uid, meal, next);
    } catch (e) {
      console.warn("toggleMealEaten", e);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        <Text style={styles.title}>Meal Planner</Text>
        <Text style={styles.subtitle}>Check off meals as you eat them — intake updates live.</Text>

        <View style={[styles.intakeCard, SHADOW_CARD]} testID="meals-intake-card">
          <View style={styles.intakeRow}>
            <View>
              <Text style={styles.intakeLabel}>Eaten Today</Text>
              <Text style={styles.intakeValue}>{eatenIntake.toLocaleString()} kcal</Text>
            </View>
            <View style={{ alignItems: "flex-end" }}>
              <Text style={styles.intakeLabel}>Goal</Text>
              <Text style={styles.goalValue}>{GOAL.toLocaleString()} kcal</Text>
            </View>
          </View>
          <View style={{ marginTop: 12 }}>
            <ProgressBar
              value={Math.min(1, eatenIntake / GOAL)}
              color={COLORS.cta.logMeal}
              trackColor={COLORS.background}
            />
          </View>
        </View>

        <View style={styles.actionsRow}>
          <TouchableOpacity
            onPress={() => router.push("/meals/library")}
            style={[styles.actionBtn, SHADOW_CARD]}
            testID="meals-browse-library"
            // @ts-ignore
            data-testid="meals-browse-library"
          >
            <View style={[styles.actionIcon, { backgroundColor: "#E0F4FB" }]}>
              <BookOpen color={COLORS.primary} size={18} strokeWidth={2.5} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.actionTitle}>Browse Library</Text>
              <Text style={styles.actionSub}>Pick from saved meals</Text>
            </View>
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => router.push("/meals/recipe-new")}
            style={[styles.actionBtn, SHADOW_CARD]}
            testID="meals-create-recipe"
            // @ts-ignore
            data-testid="meals-create-recipe"
          >
            <View style={[styles.actionIcon, { backgroundColor: "#DDF7E5" }]}>
              <Plus color={COLORS.cta.logMeal} size={18} strokeWidth={3} />
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.actionTitle}>Create Recipe</Text>
              <Text style={styles.actionSub}>Add your own meal</Text>
            </View>
          </TouchableOpacity>
        </View>

        <Text style={styles.todayHeader}>Today&apos;s Plan</Text>

        <View style={{ gap: 12 }}>
          {ordered.map((m) => (
            <MealCard
              key={m.id}
              meal={m}
              testID={`meal-card-${m.type}`}
              onPress={() => router.push(`/meals/${m.type}`)}
              onToggleEaten={(next) => onToggle(m, next)}
            />
          ))}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { paddingHorizontal: 16, paddingVertical: 16, paddingBottom: 32 },
  title: { color: COLORS.text.primary, fontSize: 26, fontWeight: "800", letterSpacing: -0.6 },
  subtitle: { color: COLORS.text.tertiary, fontSize: 13, marginTop: 4 },
  intakeCard: { marginTop: 16, backgroundColor: COLORS.card, borderRadius: 20, padding: 18 },
  intakeRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  intakeLabel: { color: COLORS.text.tertiary, fontSize: 12, fontWeight: "700", letterSpacing: 0.6, textTransform: "uppercase" },
  intakeValue: { color: COLORS.text.primary, fontSize: 24, fontWeight: "800", letterSpacing: -0.5, marginTop: 2 },
  goalValue: { color: COLORS.cta.logMeal, fontSize: 18, fontWeight: "800", marginTop: 2 },
  actionsRow: { flexDirection: "row", gap: 10, marginTop: 14 },
  actionBtn: {
    flex: 1, backgroundColor: COLORS.card, borderRadius: 16, padding: 12,
    flexDirection: "row", alignItems: "center", gap: 10,
  },
  actionIcon: { width: 38, height: 38, borderRadius: 12, alignItems: "center", justifyContent: "center" },
  actionTitle: { color: COLORS.text.primary, fontSize: 13, fontWeight: "800", letterSpacing: -0.2 },
  actionSub: { color: COLORS.text.tertiary, fontSize: 11, marginTop: 1 },
  todayHeader: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3, marginTop: 22, marginBottom: 10 },
});
