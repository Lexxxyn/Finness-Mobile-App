import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl, TouchableOpacity } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Flame, Apple, Moon, TrendingUp } from "lucide-react-native";
import { useFocusEffect, useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { StatCard } from "@/src/components/StatCard";
import { ProgressBar } from "@/src/components/ProgressBar";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import {
  fetchMealsForDate,
  fetchAllSleep,
  fetchWorkoutLogForDate,
} from "@/src/services/db";
import type { WorkoutLogEntry, Meal, Sleep } from "@/src/types/models";

function todayStr() {
  return new Date().toISOString().split("T")[0];
}

function greeting() {
  const h = new Date().getHours();
  if (h < 12) return "Good Morning";
  if (h < 18) return "Good Afternoon";
  return "Good Evening";
}

export default function HomeScreen() {
  const router = useRouter();
  const { profile, user } = useAuth();
  const [logEntries, setLogEntries] = useState<WorkoutLogEntry[]>([]);
  const [meals, setMeals] = useState<Meal[]>([]);
  const [sleep, setSleep] = useState<Sleep | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    if (!user) return;
    const today = todayStr();
    const [entries, m, sleepMap] = await Promise.all([
      fetchWorkoutLogForDate(user.uid, today),
      fetchMealsForDate(user.uid, today),
      fetchAllSleep(user.uid),
    ]);
    setLogEntries(entries);
    setMeals(m);
    setSleep(sleepMap?.[today] ?? null);
  };

  useEffect(() => {
    load().catch(() => {});
  }, [user?.uid]);

  // Re-fetch when screen regains focus (e.g. after completing a workout / logging a meal)
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

  const caloriesBurned = useMemo(
    () => logEntries.reduce((s, e) => s + (e.kcal ?? 0), 0),
    [logEntries],
  );

  const nutritionEaten = useMemo(
    () => meals.filter((m) => m.eaten).reduce((s, m) => s + (m.calories ?? 0), 0),
    [meals],
  );

  const sleepHrs = sleep?.totalHours ?? 0;

  const displayName = useMemo(() => {
    const n = profile?.name ?? user?.displayName ?? user?.email?.split("@")[0] ?? "Friend";
    return n.split(" ")[0];
  }, [profile, user]);

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        <Text style={styles.greet}>{greeting()}</Text>
        <Text style={styles.hello} testID="home-username">
          Hi, {displayName} 👋
        </Text>

        <View style={{ gap: 12, marginTop: 18 }}>
          <TouchableOpacity
            onPress={() => router.push("/summary/calories")}
            activeOpacity={0.85}
            testID="home-stat-calories-tap"
            // @ts-ignore
            data-testid="home-stat-calories-tap"
          >
            <StatCard
              title="Calories Burned"
              value={`${caloriesBurned} kcal`}
              subtitle={logEntries.length > 0 ? `${logEntries.length} workout${logEntries.length > 1 ? "s" : ""} today` : "Tap to see workouts"}
              color={COLORS.stats.calories}
              icon={<Flame color="#FFFFFF" size={26} strokeWidth={2.5} />}
              testID="home-stat-calories"
            />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => router.push("/summary/nutrition")}
            activeOpacity={0.85}
            testID="home-stat-nutrition-tap"
            // @ts-ignore
            data-testid="home-stat-nutrition-tap"
          >
            <StatCard
              title="Nutrition"
              value={`${nutritionEaten.toLocaleString()} kcal`}
              subtitle={`${meals.filter((m) => m.eaten).length}/${meals.length} meals eaten`}
              color={COLORS.stats.nutrition}
              icon={<Apple color="#FFFFFF" size={26} strokeWidth={2.5} />}
              testID="home-stat-nutrition"
            />
          </TouchableOpacity>

          <TouchableOpacity
            onPress={() => router.push("/(tabs)/sleep")}
            activeOpacity={0.85}
            testID="home-stat-sleep-tap"
            // @ts-ignore
            data-testid="home-stat-sleep-tap"
          >
            <StatCard
              title="Sleep"
              value={sleep ? `${sleepHrs.toFixed(1)} hrs` : "—"}
              subtitle="Last night"
              color={COLORS.stats.sleep}
              icon={<Moon color="#FFFFFF" size={26} strokeWidth={2.5} />}
              testID="home-stat-sleep"
            />
          </TouchableOpacity>
        </View>

        <View style={[styles.progressCard, SHADOW_CARD]} testID="home-progress-card">
          <View style={styles.progressHeader}>
            <Text style={styles.sectionTitle}>Daily Progress</Text>
            <View style={styles.trendIcon}>
              <TrendingUp color={COLORS.primary} size={18} strokeWidth={2.5} />
            </View>
          </View>

          <View style={{ marginTop: 6 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Workout Goal</Text>
              <Text style={styles.progressValue}>{Math.min(100, Math.round((logEntries.length / 1) * 100))}%</Text>
            </View>
            <ProgressBar value={Math.min(1, logEntries.length / 1)} color={COLORS.primary} />
          </View>

          <View style={{ marginTop: 14 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Meals Logged</Text>
              <Text style={styles.progressValue}>
                {meals.length ? Math.round((meals.filter((m) => m.eaten).length / meals.length) * 100) : 0}%
              </Text>
            </View>
            <ProgressBar
              value={meals.length ? meals.filter((m) => m.eaten).length / meals.length : 0}
              color={COLORS.cta.registerAccent}
            />
          </View>

          <View style={{ marginTop: 14 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Sleep Quality</Text>
              <Text style={styles.progressValue}>{sleep ? Math.round(((sleep.totalHours || 0) / 8) * 100) : 0}%</Text>
            </View>
            <ProgressBar value={Math.min(1, (sleep?.totalHours ?? 0) / 8)} color={COLORS.workouts.yoga} />
          </View>
        </View>

        <View style={styles.ctaRow}>
          <PrimaryButton
            label="Start Workout"
            color={COLORS.cta.startWorkout}
            textColor="#FFFFFF"
            onPress={() => router.push("/(tabs)/workout")}
            style={{ flex: 1 }}
            testID="home-start-workout-button"
          />
          <PrimaryButton
            label="Log Meal"
            color={COLORS.cta.logMeal}
            textColor="#FFFFFF"
            onPress={() => router.push("/(tabs)/meals")}
            style={{ flex: 1 }}
            testID="home-log-meal-button"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { paddingHorizontal: 16, paddingVertical: 16, paddingBottom: 32 },
  greet: { color: COLORS.text.tertiary, fontSize: 13, fontWeight: "600" },
  hello: { color: COLORS.text.primary, fontSize: 26, fontWeight: "800", letterSpacing: -0.6, marginTop: 2 },
  progressCard: { marginTop: 18, backgroundColor: COLORS.card, borderRadius: 20, padding: 18 },
  progressHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 8 },
  sectionTitle: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3 },
  trendIcon: { width: 32, height: 32, borderRadius: 16, backgroundColor: "#E0F4FB", alignItems: "center", justifyContent: "center" },
  progressRow: { flexDirection: "row", justifyContent: "space-between", marginBottom: 6 },
  progressLabel: { color: COLORS.text.secondary, fontWeight: "600", fontSize: 13 },
  progressValue: { color: COLORS.text.primary, fontWeight: "700", fontSize: 13 },
  ctaRow: { flexDirection: "row", gap: 12, marginTop: 18 },
});
