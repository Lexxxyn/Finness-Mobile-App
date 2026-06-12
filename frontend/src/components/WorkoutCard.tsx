import React from "react";
import { TouchableOpacity, View, Text, StyleSheet } from "react-native";
import { Clock, Flame, ChevronRight } from "lucide-react-native";
import { SHADOW_CARD } from "@/src/constants/theme";
import type { Workout } from "@/src/types/models";

type Props = {
  workout: Workout;
  onPress: () => void;
  testID?: string;
};

export function WorkoutCard({ workout, onPress, testID }: Props) {
  return (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={onPress}
      testID={testID}
      // @ts-ignore
      data-testid={testID}
      style={[styles.card, { backgroundColor: workout.color }, SHADOW_CARD]}
    >
      <View style={styles.iconBox}>
        <Flame color="#FFFFFF" size={26} strokeWidth={2.5} />
      </View>
      <View style={styles.body}>
        <Text style={styles.title}>{workout.name}</Text>
        <View style={styles.metaRow}>
          <View style={styles.metaItem}>
            <Clock color="#FFFFFFEE" size={14} strokeWidth={2.5} />
            <Text style={styles.metaText}>{workout.duration} min</Text>
          </View>
          <View style={styles.metaItem}>
            <Flame color="#FFFFFFEE" size={14} strokeWidth={2.5} />
            <Text style={styles.metaText}>{workout.kcal} kcal</Text>
          </View>
        </View>
      </View>
      <View style={styles.chev}>
        <ChevronRight color={workout.color} size={20} strokeWidth={3} />
      </View>
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 20,
    padding: 16,
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
  },
  iconBox: {
    width: 54,
    height: 54,
    borderRadius: 14,
    backgroundColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
  },
  body: { flex: 1 },
  title: {
    color: "#FFFFFF",
    fontSize: 18,
    fontWeight: "800",
    letterSpacing: -0.3,
  },
  metaRow: { flexDirection: "row", gap: 14, marginTop: 6 },
  metaItem: { flexDirection: "row", alignItems: "center", gap: 4 },
  metaText: { color: "#FFFFFFEE", fontSize: 13, fontWeight: "600" },
  chev: {
    width: 36,
    height: 36,
    borderRadius: 18,
    backgroundColor: "#FFFFFF",
    alignItems: "center",
    justifyContent: "center",
  },
});
