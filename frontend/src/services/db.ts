import { ref, set, get, update, remove, push } from "firebase/database";
import { db } from "@/src/lib/firebase";
import { storage } from "@/src/utils/storage";
import type {
  Workout,
  Meal,
  Sleep,
  UserProfile,
  WorkoutLogEntry,
  Recipe,
} from "@/src/types/models";

// Local cache keys
const cacheKey = (uid: string, kind: string) => `finnness:${uid}:${kind}`;

async function cachedFetch<T>(uid: string, kind: string, fbPath: string): Promise<T | null> {
  try {
    const snap = await get(ref(db, fbPath));
    const val = snap.exists() ? (snap.val() as T) : null;
    await storage.setItem(cacheKey(uid, kind), JSON.stringify(val) as any);
    return val;
  } catch {
    const raw = await storage.getItem<string>(cacheKey(uid, kind), "" as any);
    if (typeof raw === "string" && raw.length > 0) {
      try {
        return JSON.parse(raw) as T;
      } catch {
        return null;
      }
    }
    return null;
  }
}

// ===== Pending writes queue (offline sync) =====
type PendingWrite = { path: string; value: any; op: "set" | "update" | "remove" };
const PENDING_KEY = "finnness:pending_writes";

async function loadPending(): Promise<PendingWrite[]> {
  const raw = await storage.getItem<string>(PENDING_KEY, "" as any);
  if (typeof raw === "string" && raw.length > 0) {
    try {
      return JSON.parse(raw);
    } catch {
      return [];
    }
  }
  return [];
}

async function savePending(list: PendingWrite[]) {
  await storage.setItem(PENDING_KEY, JSON.stringify(list) as any);
}

async function queuePending(p: PendingWrite) {
  const list = await loadPending();
  list.push(p);
  await savePending(list);
}

async function applyWrite(p: PendingWrite) {
  if (p.op === "set") return set(ref(db, p.path), p.value);
  if (p.op === "update") return update(ref(db, p.path), p.value);
  if (p.op === "remove") return remove(ref(db, p.path));
}

async function writeNow(p: PendingWrite) {
  try {
    await applyWrite(p);
  } catch {
    await queuePending(p);
  }
}

export async function flushPending(): Promise<number> {
  const list = await loadPending();
  if (list.length === 0) return 0;
  const remaining: PendingWrite[] = [];
  let success = 0;
  for (const p of list) {
    try {
      await applyWrite(p);
      success += 1;
    } catch {
      remaining.push(p);
    }
  }
  await savePending(remaining);
  return success;
}

// ===== Profile =====
export async function fetchProfile(uid: string): Promise<UserProfile | null> {
  return cachedFetch<UserProfile>(uid, "profile", `finnness/users/${uid}/profile`);
}

export async function saveProfile(uid: string, profile: Partial<UserProfile>) {
  // Strip undefined values — Firebase RTDB rejects undefined.
  const cleaned: Record<string, any> = {};
  for (const [k, v] of Object.entries(profile)) {
    if (v !== undefined) cleaned[k] = v;
  }
  // Throw on failure so the UI can surface it.
  await update(ref(db, `finnness/users/${uid}/profile`), cleaned);
}

// ===== Workouts =====
export async function fetchWorkouts(uid: string): Promise<Workout[]> {
  const data = await cachedFetch<Record<string, Workout>>(uid, "workouts", `finnness/users/${uid}/workouts`);
  if (!data) return [];
  return Object.values(data);
}

export async function fetchWorkout(uid: string, workoutId: string): Promise<Workout | null> {
  const list = await fetchWorkouts(uid);
  return list.find((w) => w.id === workoutId) ?? null;
}

export async function saveWorkout(uid: string, workout: Workout) {
  await writeNow({
    path: `finnness/users/${uid}/workouts/${workout.id}`,
    value: workout,
    op: "set",
  });
  const list = await fetchWorkouts(uid);
  const map: Record<string, Workout> = {};
  let replaced = false;
  for (const w of list) {
    if (w.id === workout.id) {
      map[w.id] = workout;
      replaced = true;
    } else {
      map[w.id] = w;
    }
  }
  if (!replaced) map[workout.id] = workout;
  await storage.setItem(cacheKey(uid, "workouts"), JSON.stringify(map) as any);
}

// ===== Workout Log (completed sessions) =====
export async function logWorkoutCompletion(uid: string, entry: WorkoutLogEntry) {
  const date = new Date(entry.completedAt).toISOString().split("T")[0];
  const path = `finnness/users/${uid}/workout_log/${date}`;
  const key = `${entry.workoutId}-${entry.completedAt}`;
  await writeNow({ path: `${path}/${key}`, value: entry, op: "set" });
}

export async function fetchWorkoutLogForDate(uid: string, date: string): Promise<WorkoutLogEntry[]> {
  const data = await cachedFetch<Record<string, WorkoutLogEntry>>(
    uid,
    `log:${date}`,
    `finnness/users/${uid}/workout_log/${date}`,
  );
  if (!data) return [];
  return Object.values(data).sort((a, b) => b.completedAt - a.completedAt);
}

// ===== Meals =====
export async function fetchMealsForDate(uid: string, date: string): Promise<Meal[]> {
  const data = await cachedFetch<Record<string, Meal>>(
    uid,
    `meals:${date}`,
    `finnness/users/${uid}/meals/${date}`,
  );
  if (!data) return [];
  return Object.values(data);
}

export async function saveMeal(uid: string, meal: Meal) {
  await writeNow({
    path: `finnness/users/${uid}/meals/${meal.date}/${meal.type}`,
    value: meal,
    op: "set",
  });
  const list = await fetchMealsForDate(uid, meal.date);
  const map: Record<string, Meal> = {};
  let replaced = false;
  for (const m of list) {
    if (m.type === meal.type) {
      map[m.type] = meal;
      replaced = true;
    } else {
      map[m.type] = m;
    }
  }
  if (!replaced) map[meal.type] = meal;
  await storage.setItem(cacheKey(uid, `meals:${meal.date}`), JSON.stringify(map) as any);
}

export async function toggleMealEaten(uid: string, meal: Meal, eaten: boolean) {
  const updated: Meal = { ...meal, eaten };
  await saveMeal(uid, updated);
}

// ===== Recipes (user-created) =====
export async function fetchRecipes(uid: string): Promise<Recipe[]> {
  const data = await cachedFetch<Record<string, Recipe>>(uid, "recipes", `finnness/users/${uid}/recipes`);
  if (!data) return [];
  return Object.values(data).sort((a, b) => b.createdAt - a.createdAt);
}

export async function saveRecipe(uid: string, recipe: Recipe) {
  await writeNow({
    path: `finnness/users/${uid}/recipes/${recipe.id}`,
    value: recipe,
    op: "set",
  });
}

// ===== Sleep =====
export async function fetchSleepForDate(uid: string, date: string): Promise<Sleep | null> {
  return cachedFetch<Sleep>(uid, `sleep:${date}`, `finnness/users/${uid}/sleep/${date}`);
}

export async function fetchAllSleep(uid: string): Promise<Record<string, Sleep> | null> {
  return cachedFetch<Record<string, Sleep>>(uid, "sleep_all", `finnness/users/${uid}/sleep`);
}

export async function saveSleep(uid: string, sleep: Sleep) {
  await writeNow({
    path: `finnness/users/${uid}/sleep/${sleep.date}`,
    value: sleep,
    op: "set",
  });
}
