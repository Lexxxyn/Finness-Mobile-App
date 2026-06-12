import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Flame, Apple, Moon, TrendingUp } from "lucide-react-native";
import { useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { StatCard } from "@/src/components/StatCard";
import { ProgressBar } from "@/src/components/ProgressBar";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { fetchMealsForDate, fetchAllSleep } from "@/src/services/db";

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
  const [calories, setCalories] = useState(420);
  const [nutrition, setNutrition] = useState(1850);
  const [sleepHrs, setSleepHrs] = useState(7.5);
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    if (!user) return;
    const meals = await fetchMealsForDate(user.uid, todayStr());
    if (meals.length > 0) {
      const total = meals.reduce((s, m) => s + (m.calories ?? 0), 0);
      setNutrition(total);
    }
    const sleepMap = await fetchAllSleep(user.uid);
    if (sleepMap) {
      const today = sleepMap[todayStr()];
      if (today?.totalHours) setSleepHrs(today.totalHours);
    }
  };

  useEffect(() => {
    load().catch(() => {});
  }, [user?.uid]);

  const onRefresh = async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  };

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
          <StatCard
            title="Calories Burned"
            value={`${calories} kcal`}
            subtitle="Today"
            color={COLORS.stats.calories}
            icon={<Flame color="#FFFFFF" size={26} strokeWidth={2.5} />}
            testID="home-stat-calories"
          />
          <StatCard
            title="Nutrition"
            value={`${nutrition.toLocaleString()} kcal`}
            subtitle="Daily intake"
            color={COLORS.stats.nutrition}
            icon={<Apple color="#FFFFFF" size={26} strokeWidth={2.5} />}
            testID="home-stat-nutrition"
          />
          <StatCard
            title="Sleep"
            value={`${sleepHrs.toFixed(1)} hrs`}
            subtitle="Last night"
            color={COLORS.stats.sleep}
            icon={<Moon color="#FFFFFF" size={26} strokeWidth={2.5} />}
            testID="home-stat-sleep"
          />
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
              <Text style={styles.progressValue}>75%</Text>
            </View>
            <ProgressBar value={0.75} color={COLORS.primary} />
          </View>

          <View style={{ marginTop: 14 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Water Intake</Text>
              <Text style={styles.progressValue}>60%</Text>
            </View>
            <ProgressBar value={0.6} color={COLORS.cta.registerAccent} />
          </View>

          <View style={{ marginTop: 14 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Steps</Text>
              <Text style={styles.progressValue}>88%</Text>
            </View>
            <ProgressBar value={0.88} color={COLORS.workouts.yoga} />
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
  progressCard: {
    marginTop: 18,
    backgroundColor: COLORS.card,
    borderRadius: 20,
    padding: 18,
  },
  progressHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 8,
  },
  sectionTitle: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3 },
  trendIcon: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: "#E0F4FB",
    alignItems: "center",
    justifyContent: "center",
  },
  progressRow: { flexDirection: "row", justifyContent: "space-between", marginBottom: 6 },
  progressLabel: { color: COLORS.text.secondary, fontWeight: "600", fontSize: 13 },
  progressValue: { color: COLORS.text.primary, fontWeight: "700", fontSize: 13 },
  ctaRow: { flexDirection: "row", gap: 12, marginTop: 18 },
});
