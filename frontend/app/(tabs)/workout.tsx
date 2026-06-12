import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl, TextInput } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Search } from "lucide-react-native";
import { useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { WorkoutCard } from "@/src/components/WorkoutCard";
import { useAuth } from "@/src/context/AuthContext";
import { fetchWorkouts } from "@/src/services/db";
import type { Workout } from "@/src/types/models";

export default function WorkoutList() {
  const router = useRouter();
  const { user } = useAuth();
  const [items, setItems] = useState<Workout[]>([]);
  const [query, setQuery] = useState("");
  const [refreshing, setRefreshing] = useState(false);

  const load = async () => {
    if (!user) return;
    const list = await fetchWorkouts(user.uid);
    setItems(list);
  };

  useEffect(() => {
    load().catch(() => {});
  }, [user?.uid]);

  const onRefresh = async () => {
    setRefreshing(true);
    await load();
    setRefreshing(false);
  };

  const filtered = useMemo(() => {
    const q = query.trim().toLowerCase();
    if (!q) return items;
    return items.filter((w) => w.name.toLowerCase().includes(q));
  }, [items, query]);

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView
        contentContainerStyle={styles.scroll}
        showsVerticalScrollIndicator={false}
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} />}
      >
        <Text style={styles.title}>Workouts</Text>
        <Text style={styles.subtitle}>Choose your training session</Text>

        <View style={[styles.searchBox, SHADOW_CARD]}>
          <Search color={COLORS.text.tertiary} size={18} />
          <TextInput
            placeholder="Search workouts..."
            placeholderTextColor={COLORS.text.tertiary}
            value={query}
            onChangeText={setQuery}
            style={styles.searchInput}
            testID="workout-search-input"
            // @ts-ignore
            data-testid="workout-search-input"
          />
        </View>

        <View style={{ gap: 12, marginTop: 16 }}>
          {filtered.map((w) => (
            <WorkoutCard
              key={w.id}
              workout={w}
              testID={`workout-card-${w.id}`}
              onPress={() => router.push(`/workout/${w.id}`)}
            />
          ))}
          {filtered.length === 0 ? (
            <Text style={styles.empty}>No workouts found.</Text>
          ) : null}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { paddingHorizontal: 16, paddingVertical: 16, paddingBottom: 32 },
  title: { color: COLORS.text.primary, fontSize: 26, fontWeight: "800", letterSpacing: -0.6 },
  subtitle: { color: COLORS.text.tertiary, fontSize: 13, marginTop: 2 },
  searchBox: {
    marginTop: 16,
    backgroundColor: "#FFFFFF",
    borderRadius: 14,
    paddingHorizontal: 14,
    paddingVertical: 10,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14, color: COLORS.text.primary, paddingVertical: 6 },
  empty: { color: COLORS.text.tertiary, textAlign: "center", paddingVertical: 24 },
});
