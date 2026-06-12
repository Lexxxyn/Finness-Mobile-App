import type { EquipmentId } from "@/src/constants/equipment";

export type Exercise = {
  id: string;
  name: string;
  sets: number;
  reps: number;
  /** seconds to rest between sets */
  restSeconds?: number;
  /** Optional cue / how-to */
  cue?: string;
};

export type Workout = {
  id: string;
  name: string;
  duration: number; // minutes
  kcal: number;
  difficulty: "Beginner" | "Intermediate" | "Advanced";
  description: string;
  color: string;
  exercises: Exercise[];
  /** equipment ids required (empty = bodyweight) */
  equipment?: EquipmentId[];
  /** focus tags used for recommendation */
  tags?: string[];
};

export type MealType = "breakfast" | "lunch" | "snack" | "dinner";

export type Meal = {
  id: string;
  date: string; // YYYY-MM-DD
  type: MealType;
  foodName: string;
  time: string; // e.g. "8:00 AM"
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  ingredients: string[];
  notes?: string;
  /** true once the user marks the meal as eaten */
  eaten?: boolean;
};

export type Sleep = {
  id: string;
  date: string; // YYYY-MM-DD
  bedtime: string;
  wakeup: string;
  totalHours: number;
  deepSleep: number; // fraction 0-1
  lightSleep: number;
  remSleep: number;
};

export type UserProfile = {
  uid: string;
  name: string;
  email: string;
  gender?: string;
  dob?: string;
  height?: number; // cm
  weight?: number; // kg
  equipment?: EquipmentId[];
  /** base64 data URI for profile photo */
  photo?: string;
};

export type WorkoutLogEntry = {
  workoutId: string;
  name: string;
  kcal: number;
  duration: number;
  completedAt: number; // epoch ms
};

export type Recipe = {
  id: string;
  name: string;
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
  ingredients: string[];
  createdAt: number;
};
