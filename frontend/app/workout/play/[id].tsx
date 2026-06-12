import React, { useEffect, useMemo, useRef, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useLocalSearchParams, useRouter } from "expo-router";
import { X, ChevronRight, Pause, Play, Check } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { ProgressBar } from "@/src/components/ProgressBar";
import { useAuth } from "@/src/context/AuthContext";
import { fetchWorkout, logWorkoutCompletion } from "@/src/services/db";
import type { Workout } from "@/src/types/models";

type Phase = "exercise" | "rest" | "done";

export default function WorkoutPlay() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const router = useRouter();
  const { user } = useAuth();

  const [w, setW] = useState<Workout | null>(null);
  const [loading, setLoading] = useState(true);

  const [exIdx, setExIdx] = useState(0); // current exercise
  const [setIdx, setSetIdx] = useState(0); // current set (0-based)
  const [phase, setPhase] = useState<Phase>("exercise");
  const [secondsLeft, setSecondsLeft] = useState(0);
  const [paused, setPaused] = useState(false);
  const startTimeRef = useRef<number>(0);

  useEffect(() => {
    (async () => {
      if (!user || !id) return;
      const item = await fetchWorkout(user.uid, id);
      setW(item);
      setLoading(false);
      startTimeRef.current = Date.now();
    })().catch(() => setLoading(false));
  }, [user?.uid, id]);

  // Rest countdown
  useEffect(() => {
    if (phase !== "rest" || paused || secondsLeft <= 0) return;
    const t = setInterval(() => {
      setSecondsLeft((s) => {
        if (s <= 1) {
          clearInterval(t);
          // Advance after rest
          advanceAfterRest();
          return 0;
        }
        return s - 1;
      });
    }, 1000);
    return () => clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [phase, paused]);

  const currentEx = w?.exercises?.[exIdx];
  const totalEx = w?.exercises?.length ?? 0;

  const totalSetsAcrossAll = useMemo(() => {
    if (!w) return 0;
    return w.exercises.reduce((s, ex) => s + (ex.sets ?? 1), 0);
  }, [w]);

  const completedSets = useMemo(() => {
    if (!w) return 0;
    let c = 0;
    for (let i = 0; i < exIdx; i++) c += w.exercises[i].sets ?? 1;
    c += setIdx; // current ex completed sets so far
    return c;
  }, [w, exIdx, setIdx]);

  const progress = totalSetsAcrossAll ? completedSets / totalSetsAcrossAll : 0;

  const onCompleteSet = () => {
    if (!w || !currentEx) return;
    const nextSet = setIdx + 1;
    const isLastSetOfEx = nextSet >= (currentEx.sets ?? 1);
    const isLastEx = exIdx >= totalEx - 1;
    const restAfter = currentEx.restSeconds ?? 30;

    if (isLastSetOfEx && isLastEx) {
      // Workout complete
      finishWorkout();
      return;
    }

    if (restAfter > 0) {
      setPhase("rest");
      setSecondsLeft(restAfter);
      setPaused(false);
      // Pre-advance the set/ex pointers for after rest
      if (isLastSetOfEx) {
        // when rest finishes, move to next exercise
      }
    } else {
      advanceImmediately();
    }
  };

  const advanceImmediately = () => {
    if (!w || !currentEx) return;
    const isLastSetOfEx = setIdx + 1 >= (currentEx.sets ?? 1);
    if (isLastSetOfEx) {
      setSetIdx(0);
      setExIdx((i) => i + 1);
    } else {
      setSetIdx((s) => s + 1);
    }
    setPhase("exercise");
  };

  const advanceAfterRest = () => {
    advanceImmediately();
  };

  const skipRest = () => {
    setSecondsLeft(0);
    advanceAfterRest();
  };

  const finishWorkout = async () => {
    setPhase("done");
    if (!user || !w) return;
    const elapsedSec = Math.max(60, Math.round((Date.now() - startTimeRef.current) / 1000));
    const elapsedMin = Math.round(elapsedSec / 60);
    // Scale kcal proportionally if user finished early/late (clamped 0.5x..1.5x)
    const ratio = Math.max(0.5, Math.min(1.5, elapsedMin / (w.duration || 1)));
    const kcal = Math.round(w.kcal * ratio);
    try {
      await logWorkoutCompletion(user.uid, {
        workoutId: w.id,
        name: w.name,
        kcal,
        duration: elapsedMin,
        completedAt: Date.now(),
      });
    } catch (e) {
      console.warn("logWorkoutCompletion", e);
    }
  };

  if (loading || !w) {
    return (
      <SafeAreaView style={[styles.safe, { alignItems: "center", justifyContent: "center" }]}>
        <ActivityIndicator color={COLORS.primary} />
      </SafeAreaView>
    );
  }

  // === DONE SCREEN ===
  if (phase === "done") {
    return (
      <SafeAreaView style={[styles.safe, { backgroundColor: w.color }]} edges={["top", "bottom"]}>
        <View style={styles.doneWrap}>
          <View style={styles.doneCircle}>
            <Check color={w.color} size={56} strokeWidth={3} />
          </View>
          <Text style={styles.doneTitle}>Great job!</Text>
          <Text style={styles.doneSub}>You completed {w.name}</Text>
          <View style={styles.doneStatsRow}>
            <View style={styles.doneStat}>
              <Text style={styles.doneStatValue}>{totalEx}</Text>
              <Text style={styles.doneStatLabel}>EXERCISES</Text>
            </View>
            <View style={styles.doneStat}>
              <Text style={styles.doneStatValue}>{totalSetsAcrossAll}</Text>
              <Text style={styles.doneStatLabel}>SETS</Text>
            </View>
            <View style={styles.doneStat}>
              <Text style={styles.doneStatValue}>{w.kcal}</Text>
              <Text style={styles.doneStatLabel}>KCAL</Text>
            </View>
          </View>
          <View style={{ width: "100%", marginTop: 28 }}>
            <PrimaryButton
              label="Back to Workouts"
              color="#FFFFFF"
              textColor={w.color}
              onPress={() => router.replace("/(tabs)/workout")}
              testID="play-done-back"
            />
          </View>
        </View>
      </SafeAreaView>
    );
  }

  // === REST PHASE ===
  if (phase === "rest") {
    return (
      <SafeAreaView style={[styles.safe, { backgroundColor: w.color }]} edges={["top", "bottom"]}>
        <View style={styles.topBar}>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.iconBtn}
            testID="play-close"
            // @ts-ignore
            data-testid="play-close"
          >
            <X color="#FFFFFF" size={20} strokeWidth={2.5} />
          </TouchableOpacity>
          <Text style={styles.topTitle}>{w.name}</Text>
          <View style={{ width: 40 }} />
        </View>

        <View style={styles.restWrap}>
          <Text style={styles.restLabel}>REST</Text>
          <Text style={styles.restTimer}>{secondsLeft}s</Text>
          <Text style={styles.restNext}>
            Next up: {w.exercises[setIdx + 1 >= (currentEx?.sets ?? 1) ? exIdx + 1 : exIdx]?.name ?? "Done"}
          </Text>
          <View style={{ flexDirection: "row", gap: 12, marginTop: 28 }}>
            <TouchableOpacity
              onPress={() => setPaused((p) => !p)}
              style={[styles.restBtn, { backgroundColor: "rgba(255,255,255,0.25)" }]}
              testID="play-pause"
              // @ts-ignore
              data-testid="play-pause"
            >
              {paused ? (
                <Play color="#FFFFFF" size={20} strokeWidth={2.5} />
              ) : (
                <Pause color="#FFFFFF" size={20} strokeWidth={2.5} />
              )}
              <Text style={styles.restBtnText}>{paused ? "Resume" : "Pause"}</Text>
            </TouchableOpacity>
            <TouchableOpacity
              onPress={skipRest}
              style={[styles.restBtn, { backgroundColor: "#FFFFFF" }]}
              testID="play-skip-rest"
              // @ts-ignore
              data-testid="play-skip-rest"
            >
              <ChevronRight color={w.color} size={20} strokeWidth={2.5} />
              <Text style={[styles.restBtnText, { color: w.color }]}>Skip Rest</Text>
            </TouchableOpacity>
          </View>
        </View>
      </SafeAreaView>
    );
  }

  // === EXERCISE PHASE ===
  return (
    <SafeAreaView style={[styles.safe, { backgroundColor: w.color }]} edges={["top", "bottom"]}>
      <View style={styles.topBar}>
        <TouchableOpacity
          onPress={() => router.back()}
          style={styles.iconBtn}
          testID="play-close"
          // @ts-ignore
          data-testid="play-close"
        >
          <X color="#FFFFFF" size={20} strokeWidth={2.5} />
        </TouchableOpacity>
        <Text style={styles.topTitle}>{w.name}</Text>
        <View style={{ width: 40 }} />
      </View>

      <View style={{ paddingHorizontal: 20, marginTop: 8 }}>
        <ProgressBar value={progress} color="#FFFFFF" trackColor="rgba(255,255,255,0.25)" height={6} />
        <Text style={styles.progressText}>
          Exercise {exIdx + 1} of {totalEx}  ·  Set {setIdx + 1} of {currentEx?.sets ?? 1}
        </Text>
      </View>

      <View style={[styles.exCard, SHADOW_CARD]}>
        <Text style={[styles.exNumber, { color: w.color }]}>#{exIdx + 1}</Text>
        <Text style={styles.exName}>{currentEx?.name}</Text>
        <View style={[styles.repsBox, { backgroundColor: `${w.color}1A` }]}>
          <Text style={[styles.repsValue, { color: w.color }]}>{currentEx?.reps ?? 0}</Text>
          <Text style={styles.repsLabel}>REPS</Text>
        </View>
        {currentEx?.cue ? (
          <View style={styles.cueBox}>
            <Text style={styles.cueTitle}>Step-by-step</Text>
            {currentEx.cue
              .split(/(?<=[.!?])\s+/)
              .map((s) => s.trim())
              .filter((s) => s.length > 0)
              .map((step, i) => (
                <View key={i} style={styles.stepRow}>
                  <View style={[styles.stepNum, { backgroundColor: w.color }]}>
                    <Text style={styles.stepNumText}>{i + 1}</Text>
                  </View>
                  <Text style={styles.stepText}>{step}</Text>
                </View>
              ))}
          </View>
        ) : null}
      </View>

      <View style={styles.bottom}>
        <PrimaryButton
          label={
            setIdx + 1 >= (currentEx?.sets ?? 1) && exIdx >= totalEx - 1
              ? "Finish Workout"
              : "Complete Set"
          }
          color="#FFFFFF"
          textColor={w.color}
          onPress={onCompleteSet}
          icon={<Check color={w.color} size={18} strokeWidth={3} />}
          testID="play-complete-set"
        />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  topBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 16,
    paddingVertical: 10,
  },
  iconBtn: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
  },
  topTitle: { color: "#FFFFFF", fontSize: 16, fontWeight: "800", letterSpacing: -0.3 },
  progressText: { color: "#FFFFFFDD", fontSize: 12, fontWeight: "700", marginTop: 8, letterSpacing: 0.5 },
  exCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 24,
    marginHorizontal: 20,
    marginTop: 24,
    padding: 24,
    alignItems: "center",
    flex: 1,
  },
  exNumber: { fontSize: 14, fontWeight: "800", letterSpacing: 1.5 },
  exName: {
    fontSize: 28,
    fontWeight: "800",
    color: COLORS.text.primary,
    marginTop: 8,
    textAlign: "center",
    letterSpacing: -0.5,
  },
  repsBox: {
    marginTop: 28,
    paddingVertical: 24,
    paddingHorizontal: 36,
    borderRadius: 20,
    alignItems: "center",
  },
  repsValue: { fontSize: 64, fontWeight: "900", letterSpacing: -2 },
  repsLabel: { color: COLORS.text.secondary, fontSize: 12, fontWeight: "700", letterSpacing: 1.5, marginTop: -4 },
  cueBox: {
    marginTop: "auto",
    backgroundColor: "#F3F6FA",
    borderRadius: 14,
    padding: 14,
    alignSelf: "stretch",
  },
  cueTitle: { color: COLORS.text.tertiary, fontSize: 11, fontWeight: "700", letterSpacing: 1.2, textTransform: "uppercase" },
  cueText: { color: COLORS.text.secondary, fontSize: 13, lineHeight: 19, marginTop: 4 },
  stepRow: { flexDirection: "row", alignItems: "flex-start", gap: 10, marginTop: 8 },
  stepNum: {
    width: 22, height: 22, borderRadius: 11,
    alignItems: "center", justifyContent: "center",
    marginTop: 1,
  },
  stepNumText: { color: "#FFFFFF", fontSize: 11, fontWeight: "800" },
  stepText: { flex: 1, color: COLORS.text.secondary, fontSize: 13, lineHeight: 19 },
  bottom: { paddingHorizontal: 20, paddingBottom: 16, paddingTop: 12 },
  // Rest screen
  restWrap: { flex: 1, alignItems: "center", justifyContent: "center", paddingHorizontal: 24 },
  restLabel: { color: "#FFFFFFCC", fontSize: 14, fontWeight: "800", letterSpacing: 3.5 },
  restTimer: { color: "#FFFFFF", fontSize: 120, fontWeight: "900", letterSpacing: -4, marginTop: 8 },
  restNext: { color: "#FFFFFFDD", fontSize: 14, fontWeight: "600", marginTop: 4 },
  restBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    paddingVertical: 14,
    paddingHorizontal: 22,
    borderRadius: 24,
  },
  restBtnText: { color: "#FFFFFF", fontWeight: "800", fontSize: 14 },
  // Done screen
  doneWrap: { flex: 1, alignItems: "center", justifyContent: "center", paddingHorizontal: 24 },
  doneCircle: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: "#FFFFFF",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 24,
  },
  doneTitle: { color: "#FFFFFF", fontSize: 38, fontWeight: "900", letterSpacing: -1 },
  doneSub: { color: "#FFFFFFDD", fontSize: 14, marginTop: 4 },
  doneStatsRow: { flexDirection: "row", gap: 24, marginTop: 28 },
  doneStat: { alignItems: "center" },
  doneStatValue: { color: "#FFFFFF", fontSize: 36, fontWeight: "900", letterSpacing: -1 },
  doneStatLabel: { color: "#FFFFFFCC", fontSize: 11, fontWeight: "700", letterSpacing: 1.5 },
});
