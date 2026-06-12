import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { ArrowLeft, Plus, Trash2, Clock } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { InputField } from "@/src/components/InputField";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { fetchMealsForDate, saveMeal } from "@/src/services/db";
import type { Meal } from "@/src/types/models";
import { defaultMealsForDate } from "@/src/services/seed";

function todayStr() {
  return new Date().toISOString().split("T")[0];
}

export default function EditMeal() {
  const { mealType } = useLocalSearchParams<{ mealType: string }>();
  const router = useRouter();
  const { user } = useAuth();
  const [meal, setMeal] = useState<Meal | null>(null);
  const [saving, setSaving] = useState(false);
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

  if (loading || !meal) {
    return (
      <SafeAreaView style={[styles.safe, { alignItems: "center", justifyContent: "center" }]}>
        <ActivityIndicator color={COLORS.primary} />
      </SafeAreaView>
    );
  }

  const set = <K extends keyof Meal>(k: K, v: Meal[K]) =>
    setMeal((prev) => (prev ? { ...prev, [k]: v } : prev));

  const setIngredient = (idx: number, v: string) =>
    setMeal((prev) => {
      if (!prev) return prev;
      const list = [...(prev.ingredients ?? [])];
      list[idx] = v;
      return { ...prev, ingredients: list };
    });

  const addIngredient = () =>
    setMeal((prev) =>
      prev ? { ...prev, ingredients: [...(prev.ingredients ?? []), ""] } : prev,
    );

  const removeIngredient = (idx: number) =>
    setMeal((prev) =>
      prev
        ? { ...prev, ingredients: (prev.ingredients ?? []).filter((_, i) => i !== idx) }
        : prev,
    );

  const onSave = async () => {
    if (!user || !meal) return;
    setSaving(true);
    try {
      const cleaned: Meal = {
        ...meal,
        ingredients: (meal.ingredients ?? []).filter((s) => s && s.trim().length > 0),
      };
      await saveMeal(user.uid, cleaned);
      router.back();
    } catch (e) {
      console.warn("save meal", e);
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <View style={styles.header}>
        <TouchableOpacity
          onPress={() => router.back()}
          style={styles.backBtn}
          testID="edit-meal-back"
          // @ts-ignore
          data-testid="edit-meal-back"
        >
          <ArrowLeft color={COLORS.text.primary} size={20} strokeWidth={2.5} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Edit Meal</Text>
        <View style={{ width: 40 }} />
      </View>

      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <View style={[styles.card, SHADOW_CARD]}>
          <InputField
            label="Food Name"
            value={meal.foodName}
            onChangeText={(t) => set("foodName", t)}
            testID="edit-meal-food"
          />
          <InputField
            label="Time"
            icon={<Clock color={COLORS.text.tertiary} size={18} />}
            value={meal.time}
            onChangeText={(t) => set("time", t)}
            placeholder="e.g. 8:00 AM"
            testID="edit-meal-time"
          />
          <InputField
            label="Calories"
            keyboardType="number-pad"
            value={String(meal.calories)}
            onChangeText={(t) => set("calories", Number(t) || 0)}
            testID="edit-meal-calories"
          />
          <View style={{ flexDirection: "row", gap: 8 }}>
            <View style={{ flex: 1 }}>
              <InputField
                label="Protein (g)"
                keyboardType="decimal-pad"
                value={String(meal.protein)}
                onChangeText={(t) => set("protein", Number(t) || 0)}
              />
            </View>
            <View style={{ flex: 1 }}>
              <InputField
                label="Carbs (g)"
                keyboardType="decimal-pad"
                value={String(meal.carbs)}
                onChangeText={(t) => set("carbs", Number(t) || 0)}
              />
            </View>
            <View style={{ flex: 1 }}>
              <InputField
                label="Fat (g)"
                keyboardType="decimal-pad"
                value={String(meal.fat)}
                onChangeText={(t) => set("fat", Number(t) || 0)}
              />
            </View>
          </View>
        </View>

        <View style={[styles.card, SHADOW_CARD, { marginTop: 14 }]}>
          <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
            <Text style={styles.section}>Ingredients</Text>
            <TouchableOpacity
              onPress={addIngredient}
              style={styles.addBtn}
              testID="edit-meal-add-ing"
              // @ts-ignore
              data-testid="edit-meal-add-ing"
            >
              <Plus color={COLORS.primary} size={16} strokeWidth={3} />
              <Text style={styles.addText}>Add</Text>
            </TouchableOpacity>
          </View>
          {(meal.ingredients ?? []).map((ing, idx) => (
            <View key={idx} style={{ flexDirection: "row", alignItems: "flex-end", gap: 8 }}>
              <View style={{ flex: 1 }}>
                <InputField
                  value={ing}
                  onChangeText={(t) => setIngredient(idx, t)}
                  placeholder="Ingredient"
                />
              </View>
              <TouchableOpacity
                onPress={() => removeIngredient(idx)}
                style={styles.delBtn}
                testID={`edit-meal-del-ing-${idx}`}
                // @ts-ignore
                data-testid={`edit-meal-del-ing-${idx}`}
              >
                <Trash2 color={COLORS.profile.logout} size={18} strokeWidth={2.5} />
              </TouchableOpacity>
            </View>
          ))}
        </View>

        <View style={{ marginTop: 18 }}>
          <PrimaryButton
            label="Save Changes"
            loading={saving}
            onPress={onSave}
            testID="edit-meal-save"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  backBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: COLORS.card,
    alignItems: "center",
    justifyContent: "center",
    ...SHADOW_CARD,
  },
  headerTitle: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", letterSpacing: -0.3 },
  scroll: { paddingHorizontal: 16, paddingBottom: 32 },
  card: { backgroundColor: COLORS.card, borderRadius: 18, padding: 16 },
  section: { color: COLORS.text.primary, fontSize: 16, fontWeight: "800", letterSpacing: -0.3 },
  addBtn: { flexDirection: "row", alignItems: "center", gap: 4 },
  addText: { color: COLORS.primary, fontSize: 13, fontWeight: "700" },
  delBtn: { width: 50, height: 50, alignItems: "center", justifyContent: "center", marginBottom: 12 },
});
