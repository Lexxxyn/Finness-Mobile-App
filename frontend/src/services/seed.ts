import { ref, get, set } from "firebase/database";
import { db } from "@/src/lib/firebase";
import type { Workout, Meal, Sleep } from "@/src/types/models";
import { COLORS } from "@/src/constants/theme";

// Bump this whenever the canonical workout list changes so existing users get the update.
const SEED_VERSION = 2;

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
      { id: "e1", name: "Sun Salutation",        sets: 3, reps: 5,  restSeconds: 30, cue: "Stand tall at the front of your mat, feet hip-width. Inhale as you sweep your arms overhead. Exhale and fold forward, then step back into a low lunge and downward dog. Flow back to standing with a controlled rise." },
      { id: "e2", name: "Downward Dog Flow",     sets: 3, reps: 8,  restSeconds: 30, cue: "Start on hands and knees with palms shoulder-width. Tuck toes and press hips up and back into an inverted V. Lengthen through your spine and pedal each heel toward the floor. Hold for 1 breath per rep." },
      { id: "e3", name: "Warrior II",            sets: 2, reps: 10, restSeconds: 30, cue: "Step your feet wide and turn the front toes forward. Bend the front knee directly over the ankle. Extend arms in a T-shape and gaze past your front fingertips. Hold a strong stance, then switch sides." },
      { id: "e4", name: "Child's Pose",          sets: 1, reps: 5,  restSeconds: 0,  cue: "Kneel on the mat with big toes touching. Sit your hips back to your heels and walk your hands forward. Rest your forehead on the mat. Breathe slowly for 5 full breaths." },
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
      { id: "e1", name: "Burpees",            sets: 4, reps: 12, restSeconds: 30, cue: "Stand tall, then squat down and place hands on the floor. Jump or step your feet back into a plank. Lower your chest to the floor, then push back up. Hop your feet forward and explode straight up with arms overhead." },
      { id: "e2", name: "Mountain Climbers",  sets: 4, reps: 20, restSeconds: 30, cue: "Start in a high plank with shoulders over wrists. Drive your right knee toward your chest. Switch quickly so the left knee comes forward as the right leg extends back. Keep hips low and core tight throughout. Count both legs together." },
      { id: "e3", name: "Jump Squats",        sets: 4, reps: 15, restSeconds: 45, cue: "Stand with feet shoulder-width and toes slightly out. Sit your hips back into a squat. Drive through your heels and jump explosively. Land soft with bent knees and immediately drop into the next rep." },
      { id: "e4", name: "Plank to Push-up",   sets: 3, reps: 10, restSeconds: 45, cue: "Start in a forearm plank with elbows under shoulders. Push up one hand at a time into a high plank. Lower one elbow at a time back to forearm plank. Keep hips level — no rocking side to side." },
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
      { id: "e1", name: "Warm-up Walk", sets: 1, reps: 5,  restSeconds: 0, cue: "Walk at a brisk but comfortable pace for 5 minutes. Swing your arms naturally. Take deep breaths in through your nose. Loosen up your hips and shoulders as you walk." },
      { id: "e2", name: "Easy Jog",     sets: 1, reps: 10, restSeconds: 0, cue: "Transition into a conversational-pace jog. Land mid-foot under your hips, not out in front. Keep your shoulders relaxed and elbows at 90 degrees. Breathe in rhythm with your steps." },
      { id: "e3", name: "Tempo Run",    sets: 1, reps: 25, restSeconds: 0, cue: "Pick up the pace to a 7/10 effort — comfortably hard. Maintain steady breathing and good posture. Focus on a smooth cadence around 170-180 steps per minute. Hold this pace for the full block." },
      { id: "e4", name: "Cool Down Walk", sets: 1, reps: 5, restSeconds: 0, cue: "Slow to a steady walk for 5 minutes. Let your heart rate gradually drop. Take long, even breaths. Finish with a 2 minute standing stretch for calves and quads." },
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
      { id: "e1", name: "Squats",      sets: 4, reps: 10, restSeconds: 90,  cue: "Set the bar on your upper back and brace your core. Step back and stand with feet shoulder-width. Sit your hips back and down, chest up, knees tracking over your toes. Drive through mid-foot to stand tall." },
      { id: "e2", name: "Bench Press", sets: 4, reps: 8,  restSeconds: 90,  cue: "Lie back with eyes under the bar. Pinch your shoulder blades together and plant your feet. Unrack and lower the bar with control to your lower chest. Press straight up until elbows lock out." },
      { id: "e3", name: "Deadlifts",   sets: 3, reps: 6,  restSeconds: 120, cue: "Stand with feet hip-width and the bar over mid-foot. Hinge at the hips and grip the bar just outside your knees. Brace your core, keep your spine neutral, and push the floor away. Lower under control — don't bounce." },
      { id: "e4", name: "Pull-ups",    sets: 3, reps: 8,  restSeconds: 75,  cue: "Hang from the bar with hands slightly wider than shoulders. Engage your lats and pull your elbows down. Bring your chest toward the bar. Lower with control to a full hang — use a band if needed." },
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
      { id: "e1", name: "Hundred",            sets: 1, reps: 10, restSeconds: 20, cue: "Lie on your back with knees in table-top. Curl your head and shoulders off the mat. Extend your arms long by your sides and pump them small and fast. Inhale 5 pumps, exhale 5 pumps — that's one set of ten." },
      { id: "e2", name: "Roll Up",            sets: 2, reps: 8,  restSeconds: 30, cue: "Lie flat with arms reaching overhead. Inhale to lift arms, then exhale and peel the spine off the mat one vertebra at a time. Reach long over your legs at the top. Lower back down with the same control." },
      { id: "e3", name: "Single Leg Stretch", sets: 2, reps: 12, restSeconds: 30, cue: "Lie on your back and lift your head and shoulders. Hug your right knee in while your left leg extends straight at a 45° angle. Switch legs in a smooth scissor. Keep your low back pressed into the mat throughout." },
      { id: "e4", name: "Teaser",             sets: 2, reps: 6,  restSeconds: 45, cue: "Lie back with legs extended at a 45° angle. Inhale and lift your torso to balance on your tailbone in a V-shape. Reach long through your fingertips toward your toes. Lower down slowly with control." },
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
      { id: "e1", name: "Banded Squats",      sets: 3, reps: 15, restSeconds: 45, cue: "Loop the band just above your knees. Stand with feet shoulder-width. Sit your hips back into a squat, pushing your knees out against the band. Drive through your heels to stand tall." },
      { id: "e2", name: "Banded Rows",        sets: 3, reps: 12, restSeconds: 45, cue: "Anchor the band at chest height or step on it with both feet. Hinge slightly forward with a flat back. Pull the band toward your ribs, drawing your elbows back. Squeeze your shoulder blades, then return with control." },
      { id: "e3", name: "Banded Glute Bridge", sets: 3, reps: 15, restSeconds: 45, cue: "Lie on your back with the band above your knees and feet flat on the floor. Press your heels down and lift your hips. Squeeze your glutes hard at the top, knees pushing out into the band. Lower with control." },
      { id: "e4", name: "Banded Press",       sets: 3, reps: 12, restSeconds: 45, cue: "Stand on the band with feet hip-width. Hold the ends at your shoulders. Press both hands straight up overhead, keeping your ribs tucked. Lower the hands back to your shoulders with control." },
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
      { id: "e1", name: "Kettlebell Swing",    sets: 5, reps: 15, restSeconds: 60, cue: "Stand with feet shoulder-width, kettlebell on the floor in front. Hinge at the hips and grab the bell with both hands. Hike it back between your legs, then snap your hips forward. The bell floats to chest height — keep your arms relaxed." },
      { id: "e2", name: "Goblet Squat",        sets: 4, reps: 10, restSeconds: 60, cue: "Hold the kettlebell vertically at your chest, elbows pointing down. Stand with feet shoulder-width. Squat down between your elbows, keeping your chest tall. Drive through mid-foot to stand." },
      { id: "e3", name: "Single-Arm Clean",    sets: 3, reps: 8,  restSeconds: 60, cue: "Set the bell between your feet. Hinge at the hips and grip with one hand. Pull the bell tight to your body as you stand. Catch it softly in the rack position at your shoulder — no banging on the forearm." },
      { id: "e4", name: "Turkish Get-up",      sets: 2, reps: 3,  restSeconds: 90, cue: "Lie on your back with the bell pressed straight up. Bend the same-side knee and roll up onto your opposite elbow, then hand. Sweep your back leg through to a lunge and stand tall. Reverse the entire sequence — slow and deliberate." },
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

// Seed only if missing — idempotent. Re-seeds workouts when SEED_VERSION changes.
export async function seedUserIfEmpty(uid: string) {
  try {
    const root = ref(db, `finnness/users/${uid}`);
    const snap = await get(root);
    const existing = snap.exists() ? snap.val() : {};

    const currentVersion = existing?._meta?.workouts_version ?? 0;
    const needsWorkoutSeed = !existing.workouts || currentVersion < SEED_VERSION;

    if (needsWorkoutSeed) {
      const map: Record<string, Workout> = {};
      for (const w of SEED_WORKOUTS) map[w.id] = w;
      await set(ref(db, `finnness/users/${uid}/workouts`), map);
      await set(ref(db, `finnness/users/${uid}/_meta/workouts_version`), SEED_VERSION);
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
