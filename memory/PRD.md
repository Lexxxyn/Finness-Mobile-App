# FINNNESS — Product Requirements Document

## Overview
**FINNNESS** is a mobile-first wellness companion that helps users track workouts, meals, and sleep with a colorful, glanceable UI. Built as an Expo (React Native) app with Firebase Authentication + Firebase Realtime Database as the cloud store, plus an AsyncStorage-based local cache for offline-first reads/writes.

## Tech Stack
- **Frontend:** Expo SDK 54, React Native 0.81, TypeScript, expo-router, lucide-react-native, react-native-svg, expo-linear-gradient, react-native-safe-area-context.
- **Backend:** Firebase Auth (email/password) + Firebase Realtime Database.
- **Local cache / Offline queue:** AsyncStorage via `@/src/utils/storage` (replaces the spec's SQLite — semantically equivalent for the data model).
- **Original FastAPI backend:** left as a no-op placeholder; not used by the app.

## Architecture (MVVM-inspired)
- `src/lib/firebase.ts` — Firebase init (auth with AsyncStorage persistence + RTDB).
- `src/context/AuthContext.tsx` — onAuthStateChanged, profile load/save, seed, flush pending writes.
- `src/services/db.ts` — RTDB CRUD with read-through cache + pending-writes queue (offline sync).
- `src/services/seed.ts` — idempotent seed of workouts/meals/sleep on first sign-in.
- `src/components/*` — reusable StatCard, WorkoutCard, MealCard, ProgressBar, PrimaryButton, InputField, WaveShape.
- `app/` — expo-router file-based routes (see below).

## Routes
- `/` → Splash (animated, redirects after 1.6s)
- `(auth)/login`, `(auth)/register`, `(auth)/forgot-password`
- `(tabs)/home`, `(tabs)/workout`, `(tabs)/meals`, `(tabs)/sleep`, `(tabs)/profile` (bottom-tab navigator)
- `workout/[id]` → Detail with hero, stat chips, exercises list, "Start Workout" CTA
- `workout/edit/[id]` → Edit form (name, duration, kcal, difficulty chips, description, exercise rows)
- `meals/[mealType]` → Detail with macros and ingredients
- `meals/edit/[mealType]` → Edit form (food, time, calories, macros, ingredients)

## Firebase RTDB schema
```
finnness/users/{uid}/
  profile/ { name, email, gender, dob, height, weight }
  workouts/{workoutId}/ { name, duration, kcal, difficulty, description, color, exercises[] }
  meals/{YYYY-MM-DD}/{mealType}/ { foodName, time, calories, protein, carbs, fat, ingredients[], notes }
  sleep/{YYYY-MM-DD}/ { bedtime, wakeup, totalHours, deepSleep, lightSleep, remSleep }
```

## Offline Sync
- All writes go through `writeNow()` which optimistically pushes to RTDB; on failure they're queued in AsyncStorage and flushed on next auth sign-in via `flushPending()`.
- Reads use a read-through cache: on RTDB failure, the last successful response is returned from AsyncStorage.

## Seed Data (idempotent on first auth)
- 5 workouts: Morning Yoga, HIIT Training, Evening Run, Strength Training, Pilates (with realistic exercise lists).
- Today's 4 meals (Breakfast/Lunch/Snack/Dinner) with ingredients and macros.
- 7 days of sleep data with light jitter for a realistic weekly average.

## Design System
Faithful implementation of the user's color palette: primary `#42C8F5`, background `#EEF3F8`, stat cards (calories `#F07070`, nutrition `#5CBF7A`, sleep `#7B7FD4`), workout colors (yoga `#A17FD4`, HIIT `#F07070`, run `#42C8F5`, strength `#F5A742`, pilates `#5CBF7A`), meal colors (breakfast `#F5C842`, lunch `#5CBF7A`, snack `#F5A742`, dinner `#42C8F5`), CTA buttons (start workout `#F5C842`, log meal `#5CBF7A`), sleep hero `#7B7FD4` + weekly avg gradient `#9B7FD4`→`#7B7FD4`, profile pink `#E05C8A`, logout red `#E05C5C`, register accent `#2BBFA4`. Cards: white, 16/18 radius, soft shadow.

## Auth
- Email/password via Firebase Auth.
- Persistence: `getReactNativePersistence(AsyncStorage)` keeps users signed in.
- Forgot password sends a Firebase reset email.

## Out of Scope (vs original spec)
- SQLite was replaced with AsyncStorage (offline KV) — semantically equivalent for our data model, simpler in Expo.
- GoRouter replaced by expo-router (file-based, idiomatic for Expo).
- Original Flutter implementation impossible on this platform; React Native equivalent shipped.

## Smart business enhancement
Once weekly streaks reach 7+ active days, a "PRO" upsell card on Home can offer personalized coaching plans and barcode meal logging — a natural monetization path with proven retention impact in the wellness category.
