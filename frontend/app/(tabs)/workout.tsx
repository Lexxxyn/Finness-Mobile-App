import React, { useEffect, useMemo, useState } from "react";
import { View, Text, StyleSheet, ScrollView, RefreshControl, TextInput } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Search, Sparkles } from "lucide-react-native";
import { useFocusEffect, useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { WorkoutCard } from "@/src/components/WorkoutCard";
import { useAuth } from "@/src/context/AuthContext";
import { fetchWorkouts } from "@/src/services/db";
import type { Workout } from "@/src/types/models";

export default function WorkoutList() {
  const router = useRouter();
  const { user, profile } = useAuth();
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

  const userEquipment = profile?.equipment ?? ["bodyweight"];

  const { recommended, others } = useMemo(() => {
    const q = query.trim().toLowerCase();
    const filtered = items.filter((w) => (q ? w.name.toLowerCase().includes(q) : true));
    const rec: Workout[] = [];
    const rest: Workout[] = [];
    for (const w of filtered) {
      const eq = w.equipment ?? ["bodyweight"];
      const fits = eq.some((e) => userEquipment.includes(e as any));
      if (fits) rec.push(w);
      else rest.push(w);
    }
    return { recommended: rec, others: rest };
  }, [items, query, userEquipment]);

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

        {recommended.length > 0 ? (
          <View style={{ marginTop: 18 }}>
            <View style={styles.sectionRow}>
              <Sparkles color={COLORS.primary} size={18} strokeWidth={2.5} />
              <Text style={styles.section}>Recommended for You</Text>
            </View>
            <Text style={styles.sectionHint}>
              Based on your equipment: {userEquipment.join(", ")}
            </Text>
            <View style={{ gap: 12, marginTop: 10 }}>
              {recommended.map((w) => (
                <WorkoutCard
                  key={w.id}
                  workout={w}
                  testID={`workout-card-${w.id}`}
                  onPress={() => router.push(`/workout/${w.id}`)}
                />
              ))}
            </View>
          </View>
        ) : null}

        {others.length > 0 ? (
          <View style={{ marginTop: 22 }}>
            <Text style={styles.section}>Browse All Workouts</Text>
            <Text style={styles.sectionHint}>You can still try these without recommended equipment.</Text>
            <View style={{ gap: 12, marginTop: 10 }}>
              {others.map((w) => (
                <WorkoutCard
                  key={w.id}
                  workout={w}
                  testID={`workout-card-${w.id}`}
                  onPress={() => router.push(`/workout/${w.id}`)}
                />
              ))}
            </View>
          </View>
        ) : null}

        {recommended.length === 0 && others.length === 0 ? (
          <Text style={styles.empty}>No workouts found.</Text>
        ) : null}
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
    marginTop: 16, backgroundColor: "#FFFFFF", borderRadius: 14,
    paddingHorizontal: 14, paddingVertical: 10,
    flexDirection: "row", alignItems: "center", gap: 10,
  },
  searchInput: { flex: 1, fontSize: 14, color: COLORS.text.primary, paddingVertical: 6 },
  sectionRow: { flexDirection: "row", alignItems: "center", gap: 8 },
  section: { color: COLORS.text.primary, fontSize: 17, fontWeight: "800", letterSpacing: -0.3 },
  sectionHint: { color: COLORS.text.tertiary, fontSize: 12, marginTop: 2 },
  empty: { color: COLORS.text.tertiary, textAlign: "center", paddingVertical: 24 },
});
