import { ref, get, set } from "firebase/database";
import { db } from "@/src/lib/firebase";
import type { Workout, Meal, Sleep } from "@/src/types/models";
import { COLORS } from "@/src/constants/theme";

function todayStr(): string {
  return new Date().toISOString().split("T")[0];
}

function yesterdayStr(daysAgo: number): string {
  const d = new Date();
  d.setDate(d.getDate() - daysAgo);
  return d.toISOString().split("T")[0];
}

export const SEED_WORKOUTS: Workout[] = [
  {
    id: "w-yoga",
    name: "Morning Yoga",
    duration: 30,
    kcal: 150,
    difficulty: "Beginner",
    description:
      "Start your day with mindful flow and gentle stretches to awaken your body and calm your mind.",
    color: COLORS.workouts.yoga,
    exercises: [
      { id: "e1", name: "Sun Salutation", sets: 3, reps: 5 },
      { id: "e2", name: "Downward Dog Flow", sets: 3, reps: 8 },
      { id: "e3", name: "Warrior II", sets: 2, reps: 10 },
      { id: "e4", name: "Child's Pose", sets: 1, reps: 5 },
    ],
  },
  {
    id: "w-hiit",
    name: "HIIT Training",
    duration: 20,
    kcal: 280,
    difficulty: "Advanced",
    description:
      "High intensity interval training to torch calories and boost endurance in a short, intense burst.",
    color: COLORS.workouts.hiit,
    exercises: [
      { id: "e1", name: "Burpees", sets: 4, reps: 12 },
      { id: "e2", name: "Mountain Climbers", sets: 4, reps: 20 },
      { id: "e3", name: "Jump Squats", sets: 4, reps: 15 },
      { id: "e4", name: "Plank to Push-up", sets: 3, reps: 10 },
    ],
  },
  {
    id: "w-run",
    name: "Evening Run",
    duration: 45,
    kcal: 420,
    difficulty: "Intermediate",
    description:
      "A steady-paced outdoor run to build cardiovascular endurance and clear your head after a long day.",
    color: COLORS.workouts.run,
    exercises: [
      { id: "e1", name: "Warm-up Walk", sets: 1, reps: 5 },
      { id: "e2", name: "Easy Jog", sets: 1, reps: 10 },
      { id: "e3", name: "Tempo Run", sets: 1, reps: 25 },
      { id: "e4", name: "Cool Down Walk", sets: 1, reps: 5 },
    ],
  },
  {
    id: "w-strength",
    name: "Strength Training",
    duration: 40,
    kcal: 320,
    difficulty: "Intermediate",
    description:
      "Compound lifts and accessory work to build lean muscle and functional strength.",
    color: COLORS.workouts.strength,
    exercises: [
      { id: "e1", name: "Squats", sets: 4, reps: 10 },
      { id: "e2", name: "Bench Press", sets: 4, reps: 8 },
      { id: "e3", name: "Deadlifts", sets: 3, reps: 6 },
      { id: "e4", name: "Pull-ups", sets: 3, reps: 8 },
    ],
  },
  {
    id: "w-pilates",
    name: "Pilates",
    duration: 35,
    kcal: 200,
    difficulty: "Beginner",
    description:
      "Core-focused mat work emphasizing control, breath, and posture for a strong and stable centre.",
    color: COLORS.workouts.pilates,
    exercises: [
      { id: "e1", name: "Hundred", sets: 1, reps: 10 },
      { id: "e2", name: "Roll Up", sets: 2, reps: 8 },
      { id: "e3", name: "Single Leg Stretch", sets: 2, reps: 12 },
      { id: "e4", name: "Teaser", sets: 2, reps: 6 },
    ],
  },
];

export function defaultMealsForDate(date: string): Meal[] {
  return [
    {
      id: `m-${date}-breakfast`,
      date,
      type: "breakfast",
      foodName: "Oatmeal with berries & nuts",
      time: "8:00 AM",
      calories: 420,
      protein: 14,
      carbs: 62,
      fat: 12,
      ingredients: ["Rolled oats 50g", "Mixed berries 80g", "Almonds 15g", "Honey 1 tbsp", "Milk 200ml"],
      notes: "A balanced breakfast to start the day with sustained energy.",
    },
    {
      id: `m-${date}-lunch`,
      date,
      type: "lunch",
      foodName: "Grilled chicken salad",
      time: "12:30 PM",
      calories: 680,
      protein: 48,
      carbs: 32,
      fat: 28,
      ingredients: [
        "Chicken breast 180g",
        "Mixed greens 120g",
        "Cherry tomatoes 80g",
        "Avocado 1/2",
        "Olive oil 1 tbsp",
        "Lemon juice",
      ],
      notes: "Protein-packed and fibre-rich lunch.",
    },
    {
      id: `m-${date}-snack`,
      date,
      type: "snack",
      foodName: "Greek yogurt & apple",
      time: "3:00 PM",
      calories: 180,
      protein: 12,
      carbs: 22,
      fat: 4,
      ingredients: ["Greek yogurt 150g", "Apple 1 medium", "Cinnamon"],
      notes: "Light afternoon pick-me-up.",
    },
    {
      id: `m-${date}-dinner`,
      date,
      type: "dinner",
      foodName: "Salmon with quinoa",
      time: "7:00 PM",
      calories: 570,
      protein: 38,
      carbs: 45,
      fat: 22,
      ingredients: ["Salmon fillet 160g", "Quinoa 80g", "Broccoli 100g", "Olive oil 1 tbsp", "Garlic"],
      notes: "Omega-3 rich dinner with complex carbs.",
    },
  ];
}

export function defaultSleep(date: string): Sleep {
  return {
    id: `s-${date}`,
    date,
    bedtime: "10:30 PM",
    wakeup: "6:00 AM",
    totalHours: 7.5,
    deepSleep: 0.35,
    lightSleep: 0.5,
    remSleep: 0.15,
  };
}

// Seed only if missing — idempotent.
export async function seedUserIfEmpty(uid: string) {
  try {
    const root = ref(db, `finnness/users/${uid}`);
    const snap = await get(root);
    const existing = snap.exists() ? snap.val() : {};

    if (!existing.workouts) {
      const map: Record<string, Workout> = {};
      for (const w of SEED_WORKOUTS) map[w.id] = w;
      await set(ref(db, `finnness/users/${uid}/workouts`), map);
    }

    const today = todayStr();
    if (!existing.meals || !existing.meals[today]) {
      const meals = defaultMealsForDate(today);
      const map: Record<string, Meal> = {};
      for (const m of meals) map[m.type] = m;
      await set(ref(db, `finnness/users/${uid}/meals/${today}`), map);
    }

    if (!existing.sleep) {
      const sleepMap: Record<string, Sleep> = {};
      // last 7 days
      for (let i = 0; i < 7; i++) {
        const d = yesterdayStr(i);
        const base = defaultSleep(d);
        // small jitter for weekly average chart
        const jitter = (Math.random() - 0.5) * 1.2;
        sleepMap[d] = { ...base, totalHours: Math.max(5.5, Math.min(9, 7.5 + jitter)) };
      }
      await set(ref(db, `finnness/users/${uid}/sleep`), sleepMap);
    }
  } catch (e) {
    console.warn("seed error", e);
  }
}
