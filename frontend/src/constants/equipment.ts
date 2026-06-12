export const EQUIPMENT_OPTIONS = [
  { id: "bodyweight", label: "Bodyweight", emoji: "🤸" },
  { id: "dumbbells", label: "Dumbbells", emoji: "🏋️" },
  { id: "barbell", label: "Barbell", emoji: "🏋️‍♂️" },
  { id: "kettlebell", label: "Kettlebell", emoji: "🪨" },
  { id: "resistance_bands", label: "Resistance Bands", emoji: "🧵" },
  { id: "yoga_mat", label: "Yoga Mat", emoji: "🧘" },
  { id: "pull_up_bar", label: "Pull-up Bar", emoji: "🚪" },
  { id: "treadmill", label: "Treadmill", emoji: "🏃" },
  { id: "stationary_bike", label: "Stationary Bike", emoji: "🚴" },
  { id: "jump_rope", label: "Jump Rope", emoji: "🪢" },
] as const;

export type EquipmentId = (typeof EQUIPMENT_OPTIONS)[number]["id"];

export const GENDER_OPTIONS = ["Female", "Male", "Other"] as const;
export type Gender = (typeof GENDER_OPTIONS)[number];
