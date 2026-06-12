import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { ArrowLeft, Plus, Trash2 } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { InputField } from "@/src/components/InputField";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { saveRecipe } from "@/src/services/db";
import type { Recipe } from "@/src/types/models";

export default function NewRecipe() {
  const router = useRouter();
  const { user } = useAuth();
  const [name, setName] = useState("");
  const [calories, setCalories] = useState("");
  const [protein, setProtein] = useState("");
  const [carbs, setCarbs] = useState("");
  const [fat, setFat] = useState("");
  const [ingredients, setIngredients] = useState<string[]>([""]);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const set = (i: number, v: string) =>
    setIngredients((prev) => prev.map((x, idx) => (idx === i ? v : x)));
  const add = () => setIngredients((prev) => [...prev, ""]);
  const remove = (i: number) =>
    setIngredients((prev) => prev.filter((_, idx) => idx !== i));

  const onSave = async () => {
    setError(null);
    if (!user) return;
    if (!name.trim()) return setError("Recipe needs a name.");
    if (!calories) return setError("Add a calorie estimate.");
    setSaving(true);
    try {
      const recipe: Recipe = {
        id: `r-${Date.now()}`,
        name: name.trim(),
        calories: Number(calories) || 0,
        protein: Number(protein) || 0,
        carbs: Number(carbs) || 0,
        fat: Number(fat) || 0,
        ingredients: ingredients.map((s) => s.trim()).filter(Boolean),
        createdAt: Date.now(),
      };
      await saveRecipe(user.uid, recipe);
      router.back();
    } catch (e: any) {
      setError(e?.message ?? "Could not save recipe.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        style={{ flex: 1 }}
      >
        <View style={styles.header}>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.backBtn}
            testID="recipe-new-back"
            // @ts-ignore
            data-testid="recipe-new-back"
          >
            <ArrowLeft color={COLORS.text.primary} size={20} strokeWidth={2.5} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>New Recipe</Text>
          <View style={{ width: 40 }} />
        </View>

        <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
          <View style={[styles.card, SHADOW_CARD]}>
            <InputField
              label="Recipe Name"
              placeholder="My Power Bowl"
              value={name}
              onChangeText={setName}
              testID="recipe-name-input"
            />
            <InputField
              label="Calories (kcal)"
              keyboardType="number-pad"
              placeholder="500"
              value={calories}
              onChangeText={setCalories}
              testID="recipe-calories-input"
            />
            <View style={{ flexDirection: "row", gap: 8 }}>
              <View style={{ flex: 1 }}>
                <InputField label="Protein (g)" keyboardType="decimal-pad" value={protein} onChangeText={setProtein} />
              </View>
              <View style={{ flex: 1 }}>
                <InputField label="Carbs (g)" keyboardType="decimal-pad" value={carbs} onChangeText={setCarbs} />
              </View>
              <View style={{ flex: 1 }}>
                <InputField label="Fat (g)" keyboardType="decimal-pad" value={fat} onChangeText={setFat} />
              </View>
            </View>
          </View>

          <View style={[styles.card, SHADOW_CARD, { marginTop: 14 }]}>
            <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
              <Text style={styles.section}>Ingredients</Text>
              <TouchableOpacity onPress={add} style={styles.addBtn} testID="recipe-add-ing">
                <Plus color={COLORS.primary} size={16} strokeWidth={3} />
                <Text style={styles.addText}>Add</Text>
              </TouchableOpacity>
            </View>
            {ingredients.map((ing, idx) => (
              <View key={idx} style={{ flexDirection: "row", alignItems: "flex-end", gap: 8 }}>
                <View style={{ flex: 1 }}>
                  <InputField value={ing} onChangeText={(t) => set(idx, t)} placeholder="e.g. 100g chicken breast" />
                </View>
                {ingredients.length > 1 ? (
                  <TouchableOpacity onPress={() => remove(idx)} style={styles.delBtn} testID={`recipe-del-ing-${idx}`}>
                    <Trash2 color={COLORS.profile.logout} size={18} strokeWidth={2.5} />
                  </TouchableOpacity>
                ) : null}
              </View>
            ))}
          </View>

          {error ? <Text style={styles.error}>{error}</Text> : null}

          <View style={{ marginTop: 18 }}>
            <PrimaryButton
              label="Save Recipe"
              color={COLORS.cta.logMeal}
              loading={saving}
              onPress={onSave}
              testID="recipe-save-button"
            />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  header: {
    flexDirection: "row", alignItems: "center", justifyContent: "space-between",
    paddingHorizontal: 16, paddingVertical: 12,
  },
  backBtn: {
    width: 40, height: 40, borderRadius: 20, backgroundColor: COLORS.card,
    alignItems: "center", justifyContent: "center", ...SHADOW_CARD,
  },
  headerTitle: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", letterSpacing: -0.3 },
  scroll: { paddingHorizontal: 16, paddingBottom: 32 },
  card: { backgroundColor: COLORS.card, borderRadius: 18, padding: 16 },
  section: { color: COLORS.text.primary, fontSize: 16, fontWeight: "800", letterSpacing: -0.3 },
  addBtn: { flexDirection: "row", alignItems: "center", gap: 4 },
  addText: { color: COLORS.primary, fontSize: 13, fontWeight: "700" },
  delBtn: { width: 50, height: 50, alignItems: "center", justifyContent: "center", marginBottom: 12 },
  error: { color: "#DC2626", fontSize: 13, marginTop: 10, textAlign: "center" },
});
