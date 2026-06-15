import '../models/models.dart';

class SqliteService {
  SqliteService._();

  static final SqliteService instance = SqliteService._();

  Future<List<Meal>> fetchMealsForDate(String uid, String date) async {
    return const [];
  }

  Future<void> saveMeal(String uid, Meal meal) async {}

  Future<void> saveMeals(String uid, Iterable<Meal> meals) async {}

  Future<void> deleteMeal(String uid, Meal meal) async {}

  Future<List<Workout>> fetchWorkouts(String uid) async {
    return const [];
  }

  Future<void> saveWorkout(String uid, Workout workout) async {}

  Future<void> saveWorkouts(String uid, Iterable<Workout> workouts) async {}

  Future<List<WorkoutLogEntry>> fetchWorkoutLogForDate(
    String uid,
    String date,
  ) async {
    return const [];
  }

  Future<void> saveWorkoutLogEntry(
    String uid,
    String date,
    WorkoutLogEntry entry,
  ) async {}

  Future<void> saveWorkoutLogEntries(
    String uid,
    String date,
    Iterable<WorkoutLogEntry> entries,
  ) async {}

  Future<Sleep?> fetchSleepForDate(String uid, String date) async {
    return null;
  }

  Future<Map<String, Sleep>> fetchAllSleep(String uid) async {
    return const {};
  }

  Future<void> saveSleep(String uid, Sleep sleep) async {}

  Future<void> saveAllSleep(String uid, Iterable<Sleep> records) async {}
}
