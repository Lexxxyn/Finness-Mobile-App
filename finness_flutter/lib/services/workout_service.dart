import '../models/models.dart' hide asStringMap;
import 'firebase_service.dart';
import 'seed_service.dart' show seedWorkouts;
import 'sqlite_service.dart';

export '../models/models.dart' show Exercise, Workout, WorkoutLogEntry;

class WorkoutService {
  WorkoutService({
    FirebaseService? firebaseService,
    SqliteService? sqliteService,
  }) : _firebase = firebaseService ?? FirebaseService.instance,
       _sqlite = sqliteService ?? SqliteService.instance;

  final FirebaseService _firebase;
  final SqliteService _sqlite;

  Future<List<Workout>> fetchWorkouts(String uid) async {
    final data = await _firebase.cachedFetch<Map<String, dynamic>>(
      uid: uid,
      kind: 'workouts',
      path: 'finnness/users/$uid/workouts',
      fromValue: asStringMap,
    );

    if (data == null) {
      final local = await _sqlite.fetchWorkouts(uid);
      if (local.isNotEmpty) return local;
      return _saveSeedWorkouts(uid);
    }

    final workouts = data.values
        .map((item) => Workout.fromJson(asStringMap(item)))
        .toList();
    if (workouts.isEmpty) return _saveSeedWorkouts(uid);

    await _sqlite.saveWorkouts(uid, workouts);
    return workouts;
  }

  Future<List<Workout>> _saveSeedWorkouts(String uid) async {
    await _sqlite.saveWorkouts(uid, seedWorkouts);
    await _firebase.updateCache(uid, 'workouts', {
      for (final workout in seedWorkouts) workout.id: workout.toJson(),
    });
    await _firebase.setValue('finnness/users/$uid/workouts', {
      for (final workout in seedWorkouts) workout.id: workout.toJson(),
    });
    return seedWorkouts;
  }

  Future<Workout?> fetchWorkout(String uid, String workoutId) async {
    final list = await fetchWorkouts(uid);

    for (final workout in list) {
      if (workout.id == workoutId) return workout;
    }

    return null;
  }

  Future<void> saveWorkout(String uid, Workout workout) async {
    await _sqlite.saveWorkout(uid, workout);

    await _firebase.setValue(
      'finnness/users/$uid/workouts/${workout.id}',
      workout.toJson(),
    );

    final list = await fetchWorkouts(uid);
    final map = <String, Object?>{};
    var replaced = false;

    for (final item in list) {
      if (item.id == workout.id) {
        map[item.id] = workout.toJson();
        replaced = true;
      } else {
        map[item.id] = item.toJson();
      }
    }

    if (!replaced) {
      map[workout.id] = workout.toJson();
    }

    await _firebase.updateCache(uid, 'workouts', map);
  }

  Future<void> logWorkoutCompletion(String uid, WorkoutLogEntry entry) async {
    final date = DateTime.fromMillisecondsSinceEpoch(
      entry.completedAt,
    ).toIso8601String().split('T').first;
    final key = '${entry.workoutId}-${entry.completedAt}';

    await _sqlite.saveWorkoutLogEntry(uid, date, entry);

    await _firebase.setValue(
      'finnness/users/$uid/workout_log/$date/$key',
      entry.toJson(),
    );

    final list = await fetchWorkoutLogForDate(uid, date);
    final map = <String, Object?>{key: entry.toJson()};
    for (final item in list) {
      final itemKey = '${item.workoutId}-${item.completedAt}';
      map[itemKey] = item.toJson();
    }

    await _firebase.updateCache(uid, 'log:$date', map);
  }

  Future<List<WorkoutLogEntry>> fetchWorkoutLogForDate(
    String uid,
    String date,
  ) async {
    final data = await _firebase.cachedFetch<Map<String, dynamic>>(
      uid: uid,
      kind: 'log:$date',
      path: 'finnness/users/$uid/workout_log/$date',
      fromValue: asStringMap,
    );

    if (data == null) return _sqlite.fetchWorkoutLogForDate(uid, date);

    final entries = data.values
        .map((item) => WorkoutLogEntry.fromJson(asStringMap(item)))
        .toList();

    entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    await _sqlite.saveWorkoutLogEntries(uid, date, entries);
    return entries;
  }
}
