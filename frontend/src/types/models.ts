export type Exercise = {
  id: string;
  name: string;
  sets: number;
  reps: number;
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
};
