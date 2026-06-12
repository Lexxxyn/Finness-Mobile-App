import React, { useEffect, useState } from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, ActivityIndicator } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { ArrowLeft, Plus, Trash2 } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { InputField } from "@/src/components/InputField";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { fetchWorkout, saveWorkout } from "@/src/services/db";
import type { Workout, Exercise } from "@/src/types/models";

const DIFFS: Workout["difficulty"][] = ["Beginner", "Intermediate", "Advanced"];

export default function EditWorkout() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { user } = useAuth();
  const [w, setW] = useState<Workout | null>(null);
  const [saving, setSaving] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    (async () => {
      if (!user || !id) return;
      const item = await fetchWorkout(user.uid, id);
      setW(item);
      setLoading(false);
    })().catch(() => setLoading(false));
  }, [user?.uid, id]);

  if (loading || !w) {
    return (
      <SafeAreaView style={[styles.safe, { alignItems: "center", justifyContent: "center" }]}>
        <ActivityIndicator color={COLORS.primary} />
      </SafeAreaView>
    );
  }

  const setField = <K extends keyof Workout>(k: K, v: Workout[K]) =>
    setW((prev) => (prev ? { ...prev, [k]: v } : prev));

  const setExerciseField = (idx: number, key: keyof Exercise, val: any) => {
    setW((prev) => {
      if (!prev) return prev;
      const list = [...prev.exercises];
      list[idx] = { ...list[idx], [key]: val };
      return { ...prev, exercises: list };
    });
  };

  const addExercise = () => {
    setW((prev) =>
      prev
        ? {
            ...prev,
            exercises: [
              ...prev.exercises,
              { id: `ex-${Date.now()}`, name: "", sets: 3, reps: 10 },
            ],
          }
        : prev,
    );
  };

  const removeExercise = (idx: number) => {
    setW((prev) => (prev ? { ...prev, exercises: prev.exercises.filter((_, i) => i !== idx) } : prev));
  };

  const onSave = async () => {
    if (!user || !w) return;
    if (!w.name.trim()) return;
    setSaving(true);
    try {
      await saveWorkout(user.uid, w);
      router.back();
    } catch (e) {
      console.warn("save workout", e);
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <View style={styles.header}>
        <TouchableOpacity
          onPress={() => router.back()}
          style={styles.backBtn}
          testID="edit-workout-back"
          // @ts-ignore
          data-testid="edit-workout-back"
        >
          <ArrowLeft color={COLORS.text.primary} size={20} strokeWidth={2.5} />
        </TouchableOpacity>
        <Text style={styles.headerTitle}>Edit Workout</Text>
        <View style={{ width: 40 }} />
      </View>
      <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
        <View style={[styles.card, SHADOW_CARD]}>
          <InputField
            label="Workout Name"
            value={w.name}
            onChangeText={(t) => setField("name", t)}
            testID="edit-workout-name"
          />
          <InputField
            label="Duration (min)"
            keyboardType="number-pad"
            value={String(w.duration)}
            onChangeText={(t) => setField("duration", Number(t) || 0)}
            testID="edit-workout-duration"
          />
          <InputField
            label="Calories (kcal)"
            keyboardType="number-pad"
            value={String(w.kcal)}
            onChangeText={(t) => setField("kcal", Number(t) || 0)}
            testID="edit-workout-kcal"
          />

          <Text style={styles.fieldLabel}>Difficulty</Text>
          <View style={styles.diffRow}>
            {DIFFS.map((d) => (
              <TouchableOpacity
                key={d}
                onPress={() => setField("difficulty", d)}
                style={[
                  styles.diffChip,
                  w.difficulty === d && { backgroundColor: COLORS.primary, borderColor: COLORS.primary },
                ]}
                testID={`edit-workout-diff-${d.toLowerCase()}`}
                // @ts-ignore
                data-testid={`edit-workout-diff-${d.toLowerCase()}`}
              >
                <Text
                  style={[styles.diffText, w.difficulty === d && { color: "#FFFFFF" }]}
                >
                  {d}
                </Text>
              </TouchableOpacity>
            ))}
          </View>

          <InputField
            label="Description"
            value={w.description}
            multiline
            onChangeText={(t) => setField("description", t)}
            style={{ height: 80, textAlignVertical: "top", paddingTop: 12 }}
            testID="edit-workout-description"
          />
        </View>

        <View style={[styles.card, SHADOW_CARD, { marginTop: 14 }]}>
          <View style={{ flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 8 }}>
            <Text style={styles.section}>Exercises</Text>
            <TouchableOpacity
              onPress={addExercise}
              style={styles.addBtn}
              testID="edit-workout-add-exercise"
              // @ts-ignore
              data-testid="edit-workout-add-exercise"
            >
              <Plus color={COLORS.primary} size={16} strokeWidth={3} />
              <Text style={styles.addText}>Add</Text>
            </TouchableOpacity>
          </View>
          {w.exercises.map((ex, idx) => (
            <View key={ex.id} style={styles.exBlock}>
              <View style={styles.exHeaderRow}>
                <Text style={styles.exNum}>#{idx + 1}</Text>
                <TouchableOpacity
                  onPress={() => removeExercise(idx)}
                  testID={`edit-workout-delete-${idx}`}
                  // @ts-ignore
                  data-testid={`edit-workout-delete-${idx}`}
                >
                  <Trash2 color={COLORS.profile.logout} size={18} strokeWidth={2.5} />
                </TouchableOpacity>
              </View>
              <InputField
                label="Name"
                value={ex.name}
                onChangeText={(t) => setExerciseField(idx, "name", t)}
              />
              <View style={{ flexDirection: "row", gap: 8 }}>
                <View style={{ flex: 1 }}>
                  <InputField
                    label="Sets"
                    keyboardType="number-pad"
                    value={String(ex.sets)}
                    onChangeText={(t) => setExerciseField(idx, "sets", Number(t) || 0)}
                  />
                </View>
                <View style={{ flex: 1 }}>
                  <InputField
                    label="Reps"
                    keyboardType="number-pad"
                    value={String(ex.reps)}
                    onChangeText={(t) => setExerciseField(idx, "reps", Number(t) || 0)}
                  />
                </View>
              </View>
            </View>
          ))}
        </View>

        <View style={{ marginTop: 18 }}>
          <PrimaryButton
            label="Save Changes"
            loading={saving}
            onPress={onSave}
            testID="edit-workout-save"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
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
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: COLORS.card,
    alignItems: "center",
    justifyContent: "center",
    ...SHADOW_CARD,
  },
  headerTitle: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", letterSpacing: -0.3 },
  scroll: { paddingHorizontal: 16, paddingBottom: 32 },
  card: { backgroundColor: COLORS.card, borderRadius: 18, padding: 16 },
  fieldLabel: { color: COLORS.text.secondary, fontSize: 13, fontWeight: "600", marginBottom: 6 },
  diffRow: { flexDirection: "row", gap: 8, marginBottom: 12 },
  diffChip: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: "#F3F6FA",
    alignItems: "center",
  },
  diffText: { color: COLORS.text.secondary, fontSize: 13, fontWeight: "700" },
  section: { color: COLORS.text.primary, fontSize: 16, fontWeight: "800", letterSpacing: -0.3 },
  addBtn: { flexDirection: "row", alignItems: "center", gap: 4 },
  addText: { color: COLORS.primary, fontSize: 13, fontWeight: "700" },
  exBlock: { paddingTop: 8, borderTopWidth: 1, borderTopColor: "#F1F5F9", marginTop: 6 },
  exHeaderRow: { flexDirection: "row", justifyContent: "space-between", alignItems: "center", marginBottom: 6 },
  exNum: { color: COLORS.text.tertiary, fontWeight: "700", fontSize: 12, letterSpacing: 0.6 },
});
