export const COLORS = {
  primary: "#42C8F5",
  background: "#EEF3F8",
  card: "#FFFFFF",
  text: {
    primary: "#1F2937",
    secondary: "#4B5563",
    tertiary: "#9CA3AF",
  },
  nav: {
    active: "#42C8F5",
    inactive: "#9CA3AF",
  },
  stats: {
    calories: "#F07070",
    nutrition: "#5CBF7A",
    sleep: "#7B7FD4",
  },
  workouts: {
    yoga: "#A17FD4",
    hiit: "#F07070",
    run: "#42C8F5",
    strength: "#F5A742",
    pilates: "#5CBF7A",
  },
  meals: {
    breakfast: "#F5C842",
    lunch: "#5CBF7A",
    snack: "#F5A742",
    dinner: "#42C8F5",
  },
  cta: {
    startWorkout: "#F5C842",
    logMeal: "#5CBF7A",
    registerAccent: "#2BBFA4",
  },
  sleepHero: "#7B7FD4",
  sleepWeeklyGradient: ["#9B7FD4", "#7B7FD4"] as const,
  profile: {
    avatar: "#E05C8A",
    logout: "#E05C5C",
  },
  progressTrack: "#EEF3F8",
  border: "#E5E7EB",
};

// Cross-platform shadow via boxShadow (RN 0.76+). Replaces deprecated `shadow*` props.
// `elevation` stays for older Android fallback.
export const SHADOW_CARD = {
  boxShadow: "0px 8px 16px 0px rgba(31, 41, 55, 0.06)",
  elevation: 3,
};

export const SHADOW_BUTTON = {
  boxShadow: "0px 4px 8px 0px rgba(0, 0, 0, 0.10)",
  elevation: 2,
};

export const SPACING = {
  hPadding: 16,
  vPadding: 12,
  gapSm: 8,
  gapMd: 16,
  gapLg: 24,
  gapXl: 32,
};
