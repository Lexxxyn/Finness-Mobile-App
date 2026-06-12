import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import { ArrowLeft, Flame, Clock } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { fetchWorkoutLogForDate } from "@/src/services/db";
import type { WorkoutLogEntry } from "@/src/types/models";

function todayStr() { return new Date().toISOString().split("T")[0]; }

function timeAgo(ms: number): string {
  const diff = Date.now() - ms;
  const min = Math.round(diff / 60000);
  if (min < 1) return "Just now";
  if (min < 60) return `${min}m ago`;
  const hr = Math.round(min / 60);
  if (hr < 24) return `${hr}h ago`;
  return new Date(ms).toLocaleDateString();
}

export default function CaloriesSummary() {
  const router = useRouter();
  const { user } = useAuth();
  const [entries, setEntries] = useState<WorkoutLogEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      if (!user) return;
      const list = await fetchWorkoutLogForDate(user.uid, todayStr());
      setEntries(list);
      setLoading(false);
    })().catch(() => setLoading(false));
  }, [user?.uid]);

  const total = entries.reduce((s, e) => s + (e.kcal ?? 0), 0);
  const minutes = entries.reduce((s, e) => s + (e.duration ?? 0), 0);

  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: COLORS.stats.calories }]} edges={["top", "bottom"]}>
      <View style={styles.header}>
        <TouchableOpacity onPress={() => router.back()} style={styles.backBtn} testID="summary-back" /* @ts-ignore */ data-testid="summary-back">
          <ArrowLeft color="#FFFFFF" size={20} strokeWidth={2.5} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Calories Burned</Text>
        <View style={{ width: 40 }} />
      </View>

      <View style={styles.heroBox}>
        <Flame color="#FFFFFF" size={36} strokeWidth={2.5} />
        <Text style={styles.heroValue}>{total}</Text>
        <Text style={styles.heroUnit}>kcal today</Text>
        <Text style={styles.heroSub}>{entries.length} workouts · {minutes} min total</Text>
      </View>

      <View style={styles.sheet}>
        <Text style={styles.section}>Completed Today</Text>
        {loading ? (
          <ActivityIndicator color={COLORS.primary} style={{ marginTop: 16 }} />
        ) : entries.length === 0 ? (
          <View style={{ alignItems: "center", paddingVertical: 24 }}>
            <Text style={styles.empty}>No workouts yet today.</Text>
            <View style={{ marginTop: 18, width: "100%" }}>
              <PrimaryButton
                label="Start a Workout"
                color={COLORS.stats.calories}
                onPress={() => router.replace("/(tabs)/workout")}
                testID="summary-start-workout"
              />
            </View>
          </View>
        ) : (
          <ScrollView contentContainerStyle={{ paddingBottom: 20 }} showsVerticalScrollIndicator={false}>
            {entries.map((e, i) => (
              <View key={`${e.workoutId}-${e.completedAt}-${i}`} style={[styles.row, SHADOW_CARD]} testID={`summary-workout-${i}`}>
                <View style={[styles.iconBox, { backgroundColor: "#FEE2E2" }]}>
                  <Flame color={COLORS.stats.calories} size={20} strokeWidth={2.5} />
                </View>
                <View style={{ flex: 1 }}>
                  <Text style={styles.rowName}>{e.name}</Text>
                  <View style={{ flexDirection: "row", gap: 10, marginTop: 2 }}>
                    <View style={styles.metaPill}>
                      <Clock color={COLORS.text.tertiary} size={11} strokeWidth={2.5} />
                      <Text style={styles.metaText}>{e.duration} min</Text>
                    </View>
                    <Text style={styles.metaText}>{timeAgo(e.completedAt)}</Text>
                  </View>
                </View>
                <Text style={styles.kcal}>{e.kcal} kcal</Text>
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
  heroValue: { color: "#FFFFFF", fontSize: 64, fontWeight: "900", letterSpacing: -2, marginTop: 8 },
  heroUnit: { color: "#FFFFFFDD", fontSize: 14, fontWeight: "700", marginTop: -4 },
  heroSub: { color: "#FFFFFFCC", fontSize: 13, marginTop: 4 },
  sheet: { flex: 1, backgroundColor: COLORS.background, borderTopLeftRadius: 28, borderTopRightRadius: 28, paddingHorizontal: 16, paddingTop: 20 },
  section: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3, marginBottom: 12 },
  empty: { color: COLORS.text.tertiary, fontSize: 14 },
  row: { backgroundColor: COLORS.card, borderRadius: 14, padding: 12, flexDirection: "row", alignItems: "center", gap: 12, marginBottom: 10 },
  iconBox: { width: 40, height: 40, borderRadius: 12, alignItems: "center", justifyContent: "center" },
  rowName: { color: COLORS.text.primary, fontSize: 15, fontWeight: "700" },
  metaPill: { flexDirection: "row", alignItems: "center", gap: 4 },
  metaText: { color: COLORS.text.tertiary, fontSize: 12, fontWeight: "600" },
  kcal: { color: COLORS.stats.calories, fontSize: 15, fontWeight: "800" },
});
