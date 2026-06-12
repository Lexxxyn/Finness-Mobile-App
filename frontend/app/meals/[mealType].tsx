import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { ArrowLeft, Pencil } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { useAuth } from "@/src/context/AuthContext";
import { fetchMealsForDate } from "@/src/services/db";
import type { Meal } from "@/src/types/models";
import { defaultMealsForDate } from "@/src/services/seed";

function todayStr() {
  return new Date().toISOString().split("T")[0];
}

const MEAL_LABEL: Record<Meal["type"], string> = {
  breakfast: "Breakfast",
  lunch: "Lunch",
  snack: "Snack",
  dinner: "Dinner",
};

export default function MealDetail() {
  const { mealType } = useLocalSearchParams<{ mealType: string }>();
  const router = useRouter();
  const { user } = useAuth();
  const [meal, setMeal] = useState<Meal | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      if (!user || !mealType) return;
      const today = todayStr();
      let list = await fetchMealsForDate(user.uid, today);
      if (list.length === 0) list = defaultMealsForDate(today);
      setMeal(list.find((m) => m.type === mealType) ?? null);
      setLoading(false);
    })().catch(() => setLoading(false));
  }, [user?.uid, mealType]);

  if (loading) {
    return (
      <SafeAreaView style={[styles.safe, { alignItems: "center", justifyContent: "center" }]}>
        <ActivityIndicator color={COLORS.primary} />
      </SafeAreaView>
    );
  }
  if (!meal) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={{ textAlign: "center", marginTop: 40, color: COLORS.text.tertiary }}>
          Meal not found.
        </Text>
      </SafeAreaView>
    );
  }

  const color = COLORS.meals[meal.type];

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <View style={[styles.hero, { backgroundColor: color }]}>
        <View style={styles.heroTop}>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.headerBtn}
            testID="meal-detail-back"
            // @ts-ignore
            data-testid="meal-detail-back"
          >
            <ArrowLeft color="#FFFFFF" size={20} strokeWidth={2.5} />
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => router.push(`/meals/edit/${meal.type}`)}
            style={styles.headerBtn}
            testID="meal-detail-edit"
            // @ts-ignore
            data-testid="meal-detail-edit"
          >
            <Pencil color="#FFFFFF" size={18} strokeWidth={2.5} />
          </TouchableOpacity>
        </View>
        <Text style={styles.heroKind}>{MEAL_LABEL[meal.type]}</Text>
        <Text style={styles.heroFood}>{meal.foodName}</Text>
        <Text style={styles.heroSub}>{meal.time} · {meal.calories} kcal</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.macroRow}>
          <View style={[styles.macro, { backgroundColor: "#DCEEFE" }]}>
            <Text style={[styles.macroValue, { color: "#1D4ED8" }]}>{meal.protein}g</Text>
            <Text style={styles.macroLabel}>Protein</Text>
          </View>
          <View style={[styles.macro, { backgroundColor: "#FFE6CC" }]}>
            <Text style={[styles.macroValue, { color: "#C2410C" }]}>{meal.carbs}g</Text>
            <Text style={styles.macroLabel}>Carbs</Text>
          </View>
          <View style={[styles.macro, { backgroundColor: "#FEE2E2" }]}>
            <Text style={[styles.macroValue, { color: "#B91C1C" }]}>{meal.fat}g</Text>
            <Text style={styles.macroLabel}>Fat</Text>
          </View>
        </View>

        <Text style={styles.section}>Ingredients</Text>
        <View style={{ gap: 8 }}>
          {(meal.ingredients ?? []).map((ing, i) => (
            <View key={i} style={[styles.ingRow, SHADOW_CARD]}>
              <View style={[styles.dot, { backgroundColor: color }]} />
              <Text style={styles.ingText}>{ing}</Text>
            </View>
          ))}
        </View>

        {meal.notes ? (
          <>
            <Text style={styles.section}>Notes</Text>
            <Text style={styles.notes}>{meal.notes}</Text>
          </>
        ) : null}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  hero: {
    paddingTop: 16,
    paddingBottom: 28,
    paddingHorizontal: 16,
    borderBottomLeftRadius: 28,
    borderBottomRightRadius: 28,
  },
  heroTop: { flexDirection: "row", justifyContent: "space-between", marginTop: 6 },
  headerBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: "rgba(255,255,255,0.25)",
    alignItems: "center",
    justifyContent: "center",
  },
  heroKind: { color: "#FFFFFFEE", marginTop: 18, fontSize: 12, fontWeight: "700", letterSpacing: 1.5, textTransform: "uppercase" },
  heroFood: { color: "#FFFFFF", fontSize: 26, fontWeight: "800", marginTop: 6, letterSpacing: -0.6 },
  heroSub: { color: "#FFFFFFCC", fontSize: 13, marginTop: 4 },
  scroll: { paddingHorizontal: 16, paddingTop: 18, paddingBottom: 32 },
  macroRow: { flexDirection: "row", gap: 10 },
  macro: { flex: 1, borderRadius: 14, paddingVertical: 16, alignItems: "center" },
  macroValue: { fontSize: 22, fontWeight: "800", letterSpacing: -0.4 },
  macroLabel: { color: COLORS.text.secondary, fontSize: 12, marginTop: 4, fontWeight: "700", textTransform: "uppercase", letterSpacing: 0.6 },
  section: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", marginTop: 24, marginBottom: 10, letterSpacing: -0.3 },
  ingRow: {
    backgroundColor: COLORS.card,
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  dot: { width: 8, height: 8, borderRadius: 4 },
  ingText: { color: COLORS.text.primary, fontSize: 14, fontWeight: "600" },
  notes: { color: COLORS.text.secondary, fontSize: 14, lineHeight: 22 },
});
