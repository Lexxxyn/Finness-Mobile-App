import React, { useEffect, useMemo, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { ArrowLeft, Search, Plus, ChevronRight } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { MEAL_LIBRARY, type MealTemplate } from "@/src/services/seed";
import { useAuth } from "@/src/context/AuthContext";
import { fetchRecipes, saveMeal } from "@/src/services/db";
import type { Meal, Recipe, MealType } from "@/src/types/models";

const CATEGORIES: ("all" | MealType)[] = ["all", "breakfast", "lunch", "snack", "dinner"];
const CAT_LABEL: Record<string, string> = {
  all: "All",
  breakfast: "Breakfast",
  lunch: "Lunch",
  snack: "Snack",
  dinner: "Dinner",
};

function todayStr() {
  return new Date().toISOString().split("T")[0];
}

export default function MealLibrary() {
  const router = useRouter();
  const { user } = useAuth();
  const [query, setQuery] = useState("");
  const [cat, setCat] = useState<"all" | MealType>("all");
  const [recipes, setRecipes] = useState<Recipe[]>([]);

  useEffect(() => {
    (async () => {
      if (!user) return;
      const list = await fetchRecipes(user.uid);
      setRecipes(list);
    })().catch(() => {});
  }, [user?.uid]);

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    return MEAL_LIBRARY.filter((m) => {
      if (cat !== "all" && m.category !== cat) return false;
      if (!q) return true;
      return m.name.toLowerCase().includes(q);
    });
  }, [query, cat]);

  const filteredRecipes = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return recipes;
    return recipes.filter((r) => r.name.toLowerCase().includes(q));
  }, [query, recipes]);

  const addTemplateToToday = async (tpl: MealTemplate) => {
    if (!user) return;
    const date = todayStr();
    const meal: Meal = {
      id: `m-${date}-${tpl.category}`,
      date,
      type: tpl.category,
      foodName: tpl.name,
      time: defaultTimeForCategory(tpl.category),
      calories: tpl.calories,
      protein: tpl.protein,
      carbs: tpl.carbs,
      fat: tpl.fat,
      ingredients: tpl.ingredients,
      notes: "Added from library",
      eaten: false,
    };
    await saveMeal(user.uid, meal);
    router.back();
  };

  const addRecipeToToday = async (r: Recipe, type: MealType = "lunch") => {
    if (!user) return;
    const date = todayStr();
    const meal: Meal = {
      id: `m-${date}-${type}`,
      date,
      type,
      foodName: r.name,
      time: defaultTimeForCategory(type),
      calories: r.calories,
      protein: r.protein,
      carbs: r.carbs,
      fat: r.fat,
      ingredients: r.ingredients,
      notes: "My recipe",
      eaten: false,
    };
    await saveMeal(user.uid, meal);
    router.back();
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <View style={styles.header}>
        <TouchableOpacity
          onPress={() => router.back()}
          style={styles.backBtn}
          testID="library-back"
          // @ts-ignore
          data-testid="library-back"
        >
          <ArrowLeft color={COLORS.text.primary} size={20} strokeWidth={2.5} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Meal Library</Text>
        <TouchableOpacity
          onPress={() => router.push("/meals/recipe-new")}
          style={styles.addRecipeBtn}
          testID="library-add-recipe"
          // @ts-ignore
          data-testid="library-add-recipe"
        >
          <Plus color={COLORS.cta.logMeal} size={18} strokeWidth={3} />
        </TouchableOpacity>
      </View>

      <View style={[styles.searchBox, SHADOW_CARD]}>
        <Search color={COLORS.text.tertiary} size={18} />
        <TextInput
          placeholder="Search meals or recipes..."
          placeholderTextColor={COLORS.text.tertiary}
          value={query}
          onChangeText={setQuery}
          style={styles.searchInput}
          testID="library-search-input"
          // @ts-ignore
          data-testid="library-search-input"
        />
      </View>

      <View style={styles.chipsWrap}>
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.chipsContent}
        >
          {CATEGORIES.map((c) => (
            <TouchableOpacity
              key={c}
              onPress={() => setCat(c)}
              style={[
                styles.chip,
                cat === c && { backgroundColor: COLORS.cta.logMeal, borderColor: COLORS.cta.logMeal },
              ]}
              testID={`library-cat-${c}`}
              // @ts-ignore
              data-testid={`library-cat-${c}`}
            >
              <Text style={[styles.chipText, cat === c && { color: "#FFFFFF" }]}>
                {CAT_LABEL[c]}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
      >
        {filteredRecipes.length > 0 ? (
          <>
            <Text style={styles.section}>My Recipes</Text>
            <View style={{ gap: 10, marginBottom: 14 }}>
              {filteredRecipes.map((r) => (
                <TouchableOpacity
                  key={r.id}
                  onPress={() => addRecipeToToday(r)}
                  style={[styles.card, SHADOW_CARD]}
                  testID={`recipe-card-${r.id}`}
                  // @ts-ignore
                  data-testid={`recipe-card-${r.id}`}
                >
                  <View style={[styles.emojiBox, { backgroundColor: "#FEF3C7" }]}>
                    <Text style={{ fontSize: 22 }}>📝</Text>
                  </View>
                  <View style={{ flex: 1 }}>
                    <Text style={styles.cardName}>{r.name}</Text>
                    <Text style={styles.cardMeta}>{r.calories} kcal · P {r.protein}g · C {r.carbs}g · F {r.fat}g</Text>
                  </View>
                  <ChevronRight color={COLORS.text.tertiary} size={18} strokeWidth={2.5} />
                </TouchableOpacity>
              ))}
            </View>
          </>
        ) : null}

        <Text style={styles.section}>Browse</Text>
        <View style={{ gap: 10, paddingBottom: 24 }}>
          {filtered.map((m) => (
            <TouchableOpacity
              key={m.id}
              onPress={() => addTemplateToToday(m)}
              style={[styles.card, SHADOW_CARD]}
              testID={`library-card-${m.id}`}
              // @ts-ignore
              data-testid={`library-card-${m.id}`}
            >
              <View style={[styles.emojiBox, { backgroundColor: bgForCategory(m.category) }]}>
                <Text style={{ fontSize: 22 }}>{m.emoji}</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.cardKind}>{CAT_LABEL[m.category]}</Text>
                <Text style={styles.cardName}>{m.name}</Text>
                <Text style={styles.cardMeta}>{m.calories} kcal · P {m.protein}g · C {m.carbs}g · F {m.fat}g</Text>
              </View>
              <ChevronRight color={COLORS.text.tertiary} size={18} strokeWidth={2.5} />
            </TouchableOpacity>
          ))}
          {filtered.length === 0 ? (
            <Text style={styles.empty}>No meals found in this category.</Text>
          ) : null}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

function defaultTimeForCategory(c: MealType): string {
  switch (c) {
    case "breakfast": return "8:00 AM";
    case "lunch":     return "12:30 PM";
    case "snack":     return "3:00 PM";
    case "dinner":    return "7:00 PM";
  }
}

function bgForCategory(c: MealType): string {
  switch (c) {
    case "breakfast": return "#FEF3C7";
    case "lunch":     return "#D1FAE5";
    case "snack":     return "#FFEDD5";
    case "dinner":    return "#DBEAFE";
  }
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
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: COLORS.card,
    alignItems: "center", justifyContent: "center",
    ...SHADOW_CARD,
  },
  headerTitle: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", letterSpacing: -0.3 },
  addRecipeBtn: {
    width: 40, height: 40, borderRadius: 20,
    backgroundColor: "#DDF7E5",
    alignItems: "center", justifyContent: "center",
  },
  searchBox: {
    marginHorizontal: 16,
    backgroundColor: "#FFFFFF",
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 10,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14, color: COLORS.text.primary, paddingVertical: 6 },
  chipsWrap: { height: 56, marginTop: 8 },
  chipsContent: { paddingHorizontal: 16, gap: 8, alignItems: "center" },
  chip: {
    flexShrink: 0,
    height: 36,
    paddingHorizontal: 14,
    borderRadius: 18,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: "#FFFFFF",
    alignItems: "center",
    justifyContent: "center",
  },
  chipText: { color: COLORS.text.secondary, fontSize: 13, fontWeight: "700" },
  scroll: { paddingHorizontal: 16, paddingTop: 4 },
  section: { color: COLORS.text.primary, fontSize: 16, fontWeight: "800", marginBottom: 10, letterSpacing: -0.3 },
  card: {
    backgroundColor: COLORS.card,
    borderRadius: 16,
    padding: 12,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  emojiBox: {
    width: 48, height: 48, borderRadius: 12,
    alignItems: "center", justifyContent: "center",
  },
  cardKind: { color: COLORS.text.tertiary, fontSize: 11, fontWeight: "700", letterSpacing: 0.8, textTransform: "uppercase" },
  cardName: { color: COLORS.text.primary, fontSize: 15, fontWeight: "700", marginTop: 1 },
  cardMeta: { color: COLORS.text.tertiary, fontSize: 12, marginTop: 2 },
  empty: { color: COLORS.text.tertiary, textAlign: "center", paddingVertical: 24 },
});
