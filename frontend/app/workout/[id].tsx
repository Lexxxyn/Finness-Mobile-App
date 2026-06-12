import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { ArrowLeft, Pencil, Clock, Flame, Activity } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { fetchWorkout } from "@/src/services/db";
import type { Workout } from "@/src/types/models";

export default function WorkoutDetail() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { user } = useAuth();
  const [w, setW] = useState<Workout | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      if (!user || !id) return;
      const item = await fetchWorkout(user.uid, id);
      setW(item);
      setLoading(false);
    })().catch(() => setLoading(false));
  }, [user?.uid, id]);

  if (loading) {
    return (
      <SafeAreaView style={[styles.safe, { alignItems: "center", justifyContent: "center" }]}>
        <ActivityIndicator color={COLORS.primary} />
      </SafeAreaView>
    );
  }

  if (!w) {
    return (
      <SafeAreaView style={styles.safe}>
        <Text style={{ textAlign: "center", marginTop: 40, color: COLORS.text.tertiary }}>
          Workout not found.
        </Text>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <View style={[styles.hero, { backgroundColor: w.color }]}>
        <View style={styles.heroTop}>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.headerBtn}
            testID="workout-detail-back"
            // @ts-ignore
            data-testid="workout-detail-back"
          >
            <ArrowLeft color="#FFFFFF" size={20} strokeWidth={2.5} />
          </TouchableOpacity>
          <TouchableOpacity
            onPress={() => router.push(`/workout/edit/${w.id}`)}
            style={styles.headerBtn}
            testID="workout-detail-edit"
            // @ts-ignore
            data-testid="workout-detail-edit"
          >
            <Pencil color="#FFFFFF" size={18} strokeWidth={2.5} />
          </TouchableOpacity>
        </View>
        <Text style={styles.heroTitle}>{w.name}</Text>
        <Text style={styles.heroSub}>{w.difficulty} · {w.duration} minutes</Text>
      </View>

      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <View style={styles.statsRow}>
          <View style={[styles.statChip, SHADOW_CARD]}>
            <Clock color={w.color} size={18} strokeWidth={2.5} />
            <Text style={styles.statValue}>{w.duration}m</Text>
            <Text style={styles.statLabel}>Duration</Text>
          </View>
          <View style={[styles.statChip, SHADOW_CARD]}>
            <Flame color={w.color} size={18} strokeWidth={2.5} />
            <Text style={styles.statValue}>{w.kcal}</Text>
            <Text style={styles.statLabel}>kcal</Text>
          </View>
          <View style={[styles.statChip, SHADOW_CARD]}>
            <Activity color={w.color} size={18} strokeWidth={2.5} />
            <Text style={styles.statValue}>{w.difficulty.slice(0, 3)}</Text>
            <Text style={styles.statLabel}>Level</Text>
          </View>
        </View>

        <Text style={styles.section}>About</Text>
        <Text style={styles.description}>{w.description}</Text>

        <Text style={styles.section}>Exercises</Text>
        <View style={{ gap: 10 }}>
          {w.exercises.map((ex, i) => (
            <View key={ex.id} style={[styles.exRow, SHADOW_CARD]} testID={`workout-exercise-${ex.id}`}>
              <View style={[styles.exIdx, { backgroundColor: w.color }]}>
                <Text style={styles.exIdxText}>{i + 1}</Text>
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.exName}>{ex.name}</Text>
                <Text style={styles.exMeta}>
                  {ex.sets} sets × {ex.reps} reps
                </Text>
              </View>
            </View>
          ))}
        </View>
      </ScrollView>

      <View style={styles.bottomBar}>
        <PrimaryButton
          label="Start Workout"
          color={COLORS.primary}
          testID="workout-detail-start"
          onPress={() => {}}
        />
      </View>
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
  heroTop: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginTop: 6,
  },
  headerBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: "rgba(255,255,255,0.25)",
    alignItems: "center",
    justifyContent: "center",
  },
  heroTitle: { color: "#FFFFFF", fontSize: 32, fontWeight: "800", letterSpacing: -0.8, marginTop: 20 },
  heroSub: { color: "#FFFFFFDD", fontSize: 13, marginTop: 4, fontWeight: "600" },
  scroll: { paddingHorizontal: 16, paddingBottom: 24 },
  statsRow: { flexDirection: "row", gap: 10, marginTop: -16 },
  statChip: {
    flex: 1,
    backgroundColor: COLORS.card,
    borderRadius: 16,
    padding: 14,
    alignItems: "flex-start",
    gap: 6,
  },
  statValue: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", letterSpacing: -0.4 },
  statLabel: { color: COLORS.text.tertiary, fontSize: 11, fontWeight: "600", textTransform: "uppercase", letterSpacing: 0.6 },
  section: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", marginTop: 22, marginBottom: 10, letterSpacing: -0.3 },
  description: { color: COLORS.text.secondary, fontSize: 14, lineHeight: 22 },
  exRow: {
    backgroundColor: COLORS.card,
    borderRadius: 14,
    padding: 14,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  exIdx: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  exIdxText: { color: "#FFFFFF", fontSize: 14, fontWeight: "800" },
  exName: { color: COLORS.text.primary, fontSize: 15, fontWeight: "700" },
  exMeta: { color: COLORS.text.tertiary, fontSize: 12, marginTop: 2 },
  bottomBar: {
    paddingHorizontal: 16,
    paddingBottom: 12,
    paddingTop: 6,
    backgroundColor: COLORS.background,
  },
});
