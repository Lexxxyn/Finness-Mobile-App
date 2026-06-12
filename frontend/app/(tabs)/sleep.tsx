import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { LinearGradient } from "expo-linear-gradient";
import { Moon, Sun, Sunrise, TrendingUp } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { ProgressBar } from "@/src/components/ProgressBar";
import { useAuth } from "@/src/context/AuthContext";
import { fetchAllSleep } from "@/src/services/db";
import type { Sleep } from "@/src/types/models";
import { defaultSleep } from "@/src/services/seed";

function todayStr() {
  return new Date().toISOString().split("T")[0];
}

export default function SleepScreen() {
  const { user } = useAuth();
  const [data, setData] = useState<Record<string, Sleep>>({});
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    if (!user) return;
    const all = await fetchAllSleep(user.uid);
    if (all) {
      setData(all);
    } else {
      setData({ [todayStr()]: defaultSleep(todayStr()) });
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

  const today = data[todayStr()] ?? defaultSleep(todayStr());
  const weeklyAvg = useMemo(() => {
    const vals = Object.values(data);
    if (vals.length === 0) return 7.2;
    const sum = vals.reduce((s, v) => s + (v.totalHours ?? 0), 0);
    return sum / vals.length;
  }, [data]);

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        <Text style={styles.title}>Sleep Tracker</Text>
        <Text style={styles.subtitle}>Monitor your sleep quality</Text>

        <View style={[styles.heroCard, SHADOW_CARD]} testID="sleep-hero-card">
          <View style={styles.heroIcon}>
            <Moon color="#FFFFFF" size={28} strokeWidth={2.5} />
          </View>
          <Text style={styles.heroLabel}>TOTAL SLEEP DURATION</Text>
          <Text style={styles.heroValue}>{today.totalHours.toFixed(1)} hours</Text>
          <Text style={styles.heroSub}>Last night</Text>
        </View>

        <View style={styles.row}>
          <View style={[styles.timeCard, SHADOW_CARD]} testID="sleep-bedtime-card">
            <View style={[styles.timeIcon, { backgroundColor: "#FFE3CC" }]}>
              <Sun color="#F5A742" size={22} strokeWidth={2.5} />
            </View>
            <Text style={styles.timeLabel}>Bedtime</Text>
            <Text style={styles.timeValue}>{today.bedtime}</Text>
          </View>
          <View style={[styles.timeCard, SHADOW_CARD]} testID="sleep-wakeup-card">
            <View style={[styles.timeIcon, { backgroundColor: "#FFE3CC" }]}>
              <Sunrise color="#F5A742" size={22} strokeWidth={2.5} />
            </View>
            <Text style={styles.timeLabel}>Wake Up</Text>
            <Text style={styles.timeValue}>{today.wakeup}</Text>
          </View>
        </View>

        <View style={[styles.qualityCard, SHADOW_CARD]}>
          <View style={styles.qualityHeader}>
            <Text style={styles.qualityTitle}>Sleep Quality</Text>
            <View style={styles.trendIcon}>
              <TrendingUp color={COLORS.sleepHero} size={18} strokeWidth={2.5} />
            </View>
          </View>

          <View style={{ marginTop: 6 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Deep Sleep</Text>
              <Text style={styles.progressValue}>{Math.round(today.deepSleep * 100)}%</Text>
            </View>
            <ProgressBar value={today.deepSleep} color="#4F46E5" />
          </View>

          <View style={{ marginTop: 14 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>Light Sleep</Text>
              <Text style={styles.progressValue}>{Math.round(today.lightSleep * 100)}%</Text>
            </View>
            <ProgressBar value={today.lightSleep} color={COLORS.sleepHero} />
          </View>

          <View style={{ marginTop: 14 }}>
            <View style={styles.progressRow}>
              <Text style={styles.progressLabel}>REM Sleep</Text>
              <Text style={styles.progressValue}>{Math.round(today.remSleep * 100)}%</Text>
            </View>
            <ProgressBar value={today.remSleep} color="#A78BFA" />
          </View>
        </View>

        <LinearGradient
          colors={["#9B7FD4", "#7B7FD4"]}
          start={{ x: 0, y: 0 }}
          end={{ x: 1, y: 1 }}
          style={[styles.weeklyCard, SHADOW_CARD]}
          testID="sleep-weekly-card"
        >
          <Text style={styles.weeklyLabel}>Weekly Average</Text>
          <Text style={styles.weeklyValue}>{weeklyAvg.toFixed(1)} hours/night</Text>
        </LinearGradient>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { paddingHorizontal: 16, paddingVertical: 16, paddingBottom: 32 },
  title: { color: COLORS.text.primary, fontSize: 26, fontWeight: "800", letterSpacing: -0.6 },
  subtitle: { color: COLORS.text.tertiary, fontSize: 13, marginTop: 2 },
  heroCard: {
    backgroundColor: COLORS.sleepHero,
    marginTop: 16,
    borderRadius: 22,
    padding: 22,
    alignItems: "center",
  },
  heroIcon: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 14,
  },
  heroLabel: { color: "#FFFFFFCC", fontSize: 11, fontWeight: "700", letterSpacing: 1.5 },
  heroValue: { color: "#FFFFFF", fontSize: 38, fontWeight: "800", marginTop: 6, letterSpacing: -1 },
  heroSub: { color: "#FFFFFFCC", fontSize: 12, marginTop: 4 },
  row: { flexDirection: "row", gap: 12, marginTop: 14 },
  timeCard: {
    flex: 1,
    backgroundColor: COLORS.card,
    borderRadius: 18,
    padding: 16,
    alignItems: "flex-start",
  },
  timeIcon: {
    width: 40,
    height: 40,
    borderRadius: 12,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 10,
  },
  timeLabel: { color: COLORS.text.tertiary, fontSize: 12, fontWeight: "700", letterSpacing: 0.8, textTransform: "uppercase" },
  timeValue: { color: COLORS.text.primary, fontSize: 20, fontWeight: "800", marginTop: 4, letterSpacing: -0.4 },
  qualityCard: { marginTop: 14, backgroundColor: COLORS.card, borderRadius: 20, padding: 18 },
  qualityHeader: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 8 },
  qualityTitle: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3 },
  trendIcon: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: "#E8E6FA",
    alignItems: "center",
    justifyContent: "center",
  },
  progressRow: { flexDirection: "row", justifyContent: "space-between", marginBottom: 6 },
  progressLabel: { color: COLORS.text.secondary, fontWeight: "600", fontSize: 13 },
  progressValue: { color: COLORS.text.primary, fontWeight: "700", fontSize: 13 },
  weeklyCard: { marginTop: 14, borderRadius: 22, padding: 22, alignItems: "flex-start" },
  weeklyLabel: { color: "#FFFFFFCC", fontSize: 11, fontWeight: "700", letterSpacing: 1.5 },
  weeklyValue: { color: "#FFFFFF", fontSize: 28, fontWeight: "800", marginTop: 4, letterSpacing: -0.6 },
});
