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
    equipment: ["yoga_mat", "bodyweight"],
    tags: ["flexibility", "mindfulness", "morning"],
    exercises: [
      { id: "e1", name: "Sun Salutation",        sets: 3, reps: 5,  restSeconds: 30, cue: "Flow smoothly through each pose, syncing movement with breath." },
      { id: "e2", name: "Downward Dog Flow",     sets: 3, reps: 8,  restSeconds: 30, cue: "Press hips up and back, lengthening through the spine." },
      { id: "e3", name: "Warrior II",            sets: 2, reps: 10, restSeconds: 30, cue: "Front knee tracks over ankle. Gaze past front fingertips." },
      { id: "e4", name: "Child's Pose",          sets: 1, reps: 5,  restSeconds: 0,  cue: "Sit hips back to heels and rest forehead on the mat for 5 breaths." },
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
    equipment: ["bodyweight"],
    tags: ["cardio", "fat-burn", "endurance"],
    exercises: [
      { id: "e1", name: "Burpees",            sets: 4, reps: 12, restSeconds: 30, cue: "Explode up, chest to floor, jump to standing. Full range every rep." },
      { id: "e2", name: "Mountain Climbers",  sets: 4, reps: 20, restSeconds: 30, cue: "Drive knees toward chest, keep hips low. Count both legs." },
      { id: "e3", name: "Jump Squats",        sets: 4, reps: 15, restSeconds: 45, cue: "Sit back, then jump tall. Land soft, knees tracking toes." },
      { id: "e4", name: "Plank to Push-up",   sets: 3, reps: 10, restSeconds: 45, cue: "Plank → push-up → plank. Keep hips level the entire time." },
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
    equipment: ["bodyweight", "treadmill"],
    tags: ["cardio", "endurance", "outdoor"],
    exercises: [
      { id: "e1", name: "Warm-up Walk", sets: 1, reps: 5,  restSeconds: 0, cue: "Brisk walk to loosen up joints and elevate heart rate." },
      { id: "e2", name: "Easy Jog",     sets: 1, reps: 10, restSeconds: 0, cue: "Conversational pace. Land mid-foot under your hips." },
      { id: "e3", name: "Tempo Run",    sets: 1, reps: 25, restSeconds: 0, cue: "Comfortably hard pace — 7/10 effort. Hold steady." },
      { id: "e4", name: "Cool Down Walk", sets: 1, reps: 5, restSeconds: 0, cue: "Slow walk to bring heart rate down. Stretch calves after." },
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
    equipment: ["dumbbells", "barbell"],
    tags: ["strength", "muscle", "gym"],
    exercises: [
      { id: "e1", name: "Squats",      sets: 4, reps: 10, restSeconds: 90, cue: "Chest up, knees out, sit between heels. Drive through mid-foot." },
      { id: "e2", name: "Bench Press", sets: 4, reps: 8,  restSeconds: 90, cue: "Shoulder blades pinched. Bar to lower chest, press straight up." },
      { id: "e3", name: "Deadlifts",   sets: 3, reps: 6,  restSeconds: 120, cue: "Neutral spine. Push the floor away. Hips and shoulders rise together." },
      { id: "e4", name: "Pull-ups",    sets: 3, reps: 8,  restSeconds: 75, cue: "Chest to bar, control the descent. Use a band if needed." },
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
    equipment: ["yoga_mat", "bodyweight"],
    tags: ["core", "stability", "low-impact"],
    exercises: [
      { id: "e1", name: "Hundred",            sets: 1, reps: 10, restSeconds: 20, cue: "Pump arms 5 in / 5 out for 10 sets. Low back stays imprinted." },
      { id: "e2", name: "Roll Up",            sets: 2, reps: 8,  restSeconds: 30, cue: "Articulate the spine bone by bone. Control on the way down." },
      { id: "e3", name: "Single Leg Stretch", sets: 2, reps: 12, restSeconds: 30, cue: "Switch legs in a smooth scissor. Shoulders off the mat." },
      { id: "e4", name: "Teaser",             sets: 2, reps: 6,  restSeconds: 45, cue: "V-shape balance on tailbone. Reach long through fingers and toes." },
    ],
  },
  {
    id: "w-bands",
    name: "Resistance Band Burn",
    duration: 25,
    kcal: 180,
    difficulty: "Beginner",
    description:
      "Full-body activation using just a resistance band — perfect for travel or quick home sessions.",
    color: "#6BC4D8",
    equipment: ["resistance_bands"],
    tags: ["mobility", "travel", "full-body"],
    exercises: [
      { id: "e1", name: "Banded Squats",      sets: 3, reps: 15, restSeconds: 45, cue: "Band above knees. Push knees out as you stand." },
      { id: "e2", name: "Banded Rows",        sets: 3, reps: 12, restSeconds: 45, cue: "Pull elbows back, squeeze shoulder blades together." },
      { id: "e3", name: "Banded Glute Bridge", sets: 3, reps: 15, restSeconds: 45, cue: "Drive heels down, squeeze glutes at the top." },
      { id: "e4", name: "Banded Press",       sets: 3, reps: 12, restSeconds: 45, cue: "Press band overhead, keep ribs tucked." },
    ],
  },
  {
    id: "w-kettlebell",
    name: "Kettlebell Power",
    duration: 30,
    kcal: 340,
    difficulty: "Intermediate",
    description:
      "Explosive ballistic moves to build power, grip, and conditioning with a single kettlebell.",
    color: "#E29C6A",
    equipment: ["kettlebell"],
    tags: ["power", "conditioning", "full-body"],
    exercises: [
      { id: "e1", name: "Kettlebell Swing",    sets: 5, reps: 15, restSeconds: 60, cue: "Hinge at the hips. Snap glutes — bell floats to chest height." },
      { id: "e2", name: "Goblet Squat",        sets: 4, reps: 10, restSeconds: 60, cue: "Hold bell at chest. Squat between your elbows." },
      { id: "e3", name: "Single-Arm Clean",    sets: 3, reps: 8,  restSeconds: 60, cue: "Pull tight, catch soft in rack. Tame the arc near your body." },
      { id: "e4", name: "Turkish Get-up",      sets: 2, reps: 3,  restSeconds: 90, cue: "Slow, deliberate. Eyes on the bell through stand." },
    ],
  },
];

// --- Default daily meals (used as today's seed) ---
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
      eaten: false,
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
      eaten: false,
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
      eaten: false,
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
      eaten: false,
    },
  ];
}

// --- Meal library: pre-made templates the user can browse and pick from ---
export type MealTemplate = {
  id: string;
  name: string;
  category: "breakfast" | "lunch" | "snack" | "dinner";
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  ingredients: string[];
  emoji: string;
};

export const MEAL_LIBRARY: MealTemplate[] = [
  { id: "lib-1", name: "Avocado Toast & Egg",    category: "breakfast", calories: 380, protein: 18, carbs: 38, fat: 18, emoji: "🥑",
    ingredients: ["Sourdough 60g", "Avocado 1/2", "Egg 1", "Chili flakes", "Olive oil"] },
  { id: "lib-2", name: "Protein Smoothie Bowl",  category: "breakfast", calories: 450, protein: 32, carbs: 50, fat: 10, emoji: "🍓",
    ingredients: ["Frozen berries 150g", "Banana 1", "Whey 30g", "Almond milk 250ml", "Granola 20g"] },
  { id: "lib-3", name: "Quinoa Buddha Bowl",     category: "lunch", calories: 590, protein: 24, carbs: 70, fat: 22, emoji: "🥗",
    ingredients: ["Quinoa 90g", "Chickpeas 100g", "Roasted veg 150g", "Tahini 1 tbsp", "Lemon"] },
  { id: "lib-4", name: "Turkey Wrap",            category: "lunch", calories: 520, protein: 38, carbs: 45, fat: 18, emoji: "🌯",
    ingredients: ["Whole-wheat wrap", "Turkey 120g", "Hummus 2 tbsp", "Spinach", "Tomato"] },
  { id: "lib-5", name: "Almond Butter Apple",    category: "snack", calories: 220, protein: 6,  carbs: 24, fat: 12, emoji: "🍏",
    ingredients: ["Apple 1", "Almond butter 1 tbsp"] },
  { id: "lib-6", name: "Cottage Cheese & Berries", category: "snack", calories: 180, protein: 18, carbs: 14, fat: 4, emoji: "🫐",
    ingredients: ["Cottage cheese 150g", "Blueberries 80g", "Honey 1 tsp"] },
  { id: "lib-7", name: "Steak & Sweet Potato",   category: "dinner", calories: 720, protein: 52, carbs: 55, fat: 30, emoji: "🥩",
    ingredients: ["Sirloin 180g", "Sweet potato 200g", "Asparagus 100g", "Olive oil"] },
  { id: "lib-8", name: "Tofu Stir-fry",          category: "dinner", calories: 480, protein: 28, carbs: 48, fat: 18, emoji: "🥡",
    ingredients: ["Firm tofu 180g", "Brown rice 80g", "Mixed veg 200g", "Soy sauce", "Sesame oil"] },
];

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
      for (let i = 0; i < 7; i++) {
        const d = yesterdayStr(i);
        const base = defaultSleep(d);
        const jitter = (Math.random() - 0.5) * 1.2;
        sleepMap[d] = { ...base, totalHours: Math.max(5.5, Math.min(9, 7.5 + jitter)) };
      }
      await set(ref(db, `finnness/users/${uid}/sleep`), sleepMap);
    }
  } catch (e) {
    console.warn("seed error", e);
  }
}
