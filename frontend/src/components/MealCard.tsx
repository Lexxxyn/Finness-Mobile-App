import React from "react";
import { TouchableOpacity, View, Text, StyleSheet } from "react-native";
import { Plus } from "lucide-react-native";
import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import type { Meal } from "@/src/types/models";

const MEAL_LABEL: Record<Meal["type"], string> = {
  breakfast: "Breakfast",
  lunch: "Lunch",
  snack: "Snack",
  dinner: "Dinner",
};

type Props = {
  meal: Meal;
  onPress: () => void;
  onAdd?: () => void;
  testID?: string;
};

export function MealCard({ meal, onPress, onAdd, testID }: Props) {
  const color = COLORS.meals[meal.type];
  return (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={onPress}
      testID={testID}
      // @ts-ignore
      data-testid={testID}
      style={[styles.card, { backgroundColor: color }, SHADOW_CARD]}
    >
      <View style={styles.iconBox}>
        <Text style={styles.emoji}>
          {meal.type === "breakfast"
            ? "🥣"
            : meal.type === "lunch"
            ? "🥗"
            : meal.type === "snack"
            ? "🍎"
            : "🍱"}
        </Text>
      </View>
      <View style={styles.body}>
        <Text style={styles.kind}>{MEAL_LABEL[meal.type]}</Text>
        <Text style={styles.food} numberOfLines={1}>
          {meal.foodName}
        </Text>
        <Text style={styles.meta}>
          {meal.time} · {meal.calories} kcal
        </Text>
      </View>
      <TouchableOpacity
        onPress={onAdd ?? onPress}
        style={styles.addBtn}
        testID={`${testID}-add`}
        // @ts-ignore
        data-testid={`${testID}-add`}
      >
        <Plus color={color} size={20} strokeWidth={3} />
      </TouchableOpacity>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 20,
    padding: 14,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  iconBox: {
    width: 52,
    height: 52,
    borderRadius: 14,
    backgroundColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
  },
  emoji: { fontSize: 26 },
  body: { flex: 1 },
  kind: {
    color: "#FFFFFFEE",
    fontSize: 12,
    fontWeight: "700",
    letterSpacing: 1.0,
    textTransform: "uppercase",
  },
  food: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "800",
    marginTop: 2,
    letterSpacing: -0.3,
  },
  meta: { color: "#FFFFFFDD", fontSize: 12, marginTop: 2 },
  addBtn: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "#FFFFFF",
    alignItems: "center",
    justifyContent: "center",
  },
});
