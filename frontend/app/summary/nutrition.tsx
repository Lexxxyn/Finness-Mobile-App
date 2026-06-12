import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { ArrowLeft, Apple, Check } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { ProgressBar } from "@/src/components/ProgressBar";
import { useAuth } from "@/src/context/AuthContext";
import { fetchMealsForDate } from "@/src/services/db";
import type { Meal } from "@/src/types/models";

function todayStr() { return new Date().toISOString().split("T")[0]; }

const GOAL = 2000;

const MEAL_LABEL: Record<Meal["type"], string> = {
  breakfast: "Breakfast",
  lunch: "Lunch",
  snack: "Snack",
  dinner: "Dinner",
};

export default function NutritionSummary() {
  const router = useRouter();
  const { user } = useAuth();
  const [meals, setMeals] = useState<Meal[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      if (!user) return;
      const list = await fetchMealsForDate(user.uid, todayStr());
      setMeals(list);
      setLoading(false);
    })().catch(() => setLoading(false));
  }, [user?.uid]);

  const eaten = useMemo(() => meals.filter((m) => m.eaten), [meals]);
  const intake = eaten.reduce((s, m) => s + (m.calories ?? 0), 0);
  const protein = eaten.reduce((s, m) => s + (m.protein ?? 0), 0);
  const carbs = eaten.reduce((s, m) => s + (m.carbs ?? 0), 0);
  const fat = eaten.reduce((s, m) => s + (m.fat ?? 0), 0);

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: COLORS.stats.nutrition }]} edges={["top", "bottom"]}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn} testID="summary-back" /* @ts-ignore */ data-testid="summary-back">
          <ArrowLeft color="#FFFFFF" size={20} strokeWidth={2.5} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Nutrition</Text>
        <View style={{ width: 40 }} />
      </View>

      <View style={styles.heroBox}>
        <Apple color="#FFFFFF" size={36} strokeWidth={2.5} />
        <Text style={styles.heroValue}>{intake.toLocaleString()}</Text>
        <Text style={styles.heroUnit}>kcal eaten</Text>
        <View style={{ width: "100%", marginTop: 14 }}>
          <ProgressBar value={Math.min(1, intake / GOAL)} color="#FFFFFF" trackColor="rgba(255,255,255,0.25)" height={8} />
        </View>
        <Text style={styles.heroSub}>{eaten.length}/{meals.length} meals · Goal {GOAL.toLocaleString()} kcal</Text>
      </View>

      <View style={styles.sheet}>
        <View style={styles.macroRow}>
          <View style={[styles.macro, { backgroundColor: "#DCEEFE" }]}>
            <Text style={[styles.macroValue, { color: "#1D4ED8" }]}>{Math.round(protein)}g</Text>
            <Text style={styles.macroLabel}>Protein</Text>
          </View>
          <View style={[styles.macro, { backgroundColor: "#FFE6CC" }]}>
            <Text style={[styles.macroValue, { color: "#C2410C" }]}>{Math.round(carbs)}g</Text>
            <Text style={styles.macroLabel}>Carbs</Text>
          </View>
          <View style={[styles.macro, { backgroundColor: "#FEE2E2" }]}>
            <Text style={[styles.macroValue, { color: "#B91C1C" }]}>{Math.round(fat)}g</Text>
            <Text style={styles.macroLabel}>Fat</Text>
          </View>
        </View>

        <Text style={styles.section}>Meals Eaten</Text>
        {loading ? (
          <ActivityIndicator color={COLORS.primary} style={{ marginTop: 16 }} />
        ) : eaten.length === 0 ? (
          <Text style={styles.empty}>No meals checked off yet. Open the Meals tab to mark them as eaten.</Text>
        ) : (
          <ScrollView contentContainerStyle={{ paddingBottom: 20 }} showsVerticalScrollIndicator={false}>
            {eaten.map((m) => (
              <View key={m.id} style={[styles.row, SHADOW_CARD]} testID={`summary-meal-${m.type}`}>
                <View style={[styles.iconBox, { backgroundColor: `${COLORS.meals[m.type]}33` }]}>
                  <Check color={COLORS.meals[m.type]} size={20} strokeWidth={3} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.rowKind}>{MEAL_LABEL[m.type]} · {m.time}</Text>
                  <Text style={styles.rowName}>{m.foodName}</Text>
                </View>
                <Text style={styles.kcal}>{m.calories} kcal</Text>
              </View>
            ))}
          </ScrollView>
        )}
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1 },
  header: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", paddingHorizontal: 16, paddingVertical: 10 },
  backBtn: { width: 40, height: 40, borderRadius: 20, backgroundColor: "rgba(255,255,255,0.22)", alignItems: "center", justifyContent: "center" },
  headerTitle: { color: "#FFFFFF", fontSize: 16, fontWeight: "800", letterSpacing: -0.3 },
  heroBox: { alignItems: "center", paddingVertical: 24, paddingHorizontal: 24 },
  heroValue: { color: "#FFFFFF", fontSize: 56, fontWeight: "900", letterSpacing: -2, marginTop: 8 },
  heroUnit: { color: "#FFFFFFDD", fontSize: 14, fontWeight: "700", marginTop: -4 },
  heroSub: { color: "#FFFFFFCC", fontSize: 12, marginTop: 8 },
  sheet: { flex: 1, backgroundColor: COLORS.background, borderTopLeftRadius: 28, borderTopRightRadius: 28, paddingHorizontal: 16, paddingTop: 20 },
  macroRow: { flexDirection: "row", gap: 10, marginBottom: 18 },
  macro: { flex: 1, borderRadius: 14, paddingVertical: 14, alignItems: "center" },
  macroValue: { fontSize: 20, fontWeight: "800", letterSpacing: -0.4 },
  macroLabel: { color: COLORS.text.secondary, fontSize: 11, marginTop: 2, fontWeight: "700", textTransform: "uppercase", letterSpacing: 0.6 },
  section: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3, marginBottom: 12 },
  empty: { color: COLORS.text.tertiary, fontSize: 14, textAlign: "center", marginTop: 18, paddingHorizontal: 24, lineHeight: 22 },
  row: { backgroundColor: COLORS.card, borderRadius: 14, padding: 12, flexDirection: "row", alignItems: "center", gap: 12, marginBottom: 10 },
  iconBox: { width: 40, height: 40, borderRadius: 12, alignItems: "center", justifyContent: "center" },
  rowKind: { color: COLORS.text.tertiary, fontSize: 11, fontWeight: "700", textTransform: "uppercase", letterSpacing: 0.8 },
  rowName: { color: COLORS.text.primary, fontSize: 15, fontWeight: "700", marginTop: 1 },
  kcal: { color: COLORS.stats.nutrition, fontSize: 15, fontWeight: "800" },
});
