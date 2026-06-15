import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class SqliteService {
  SqliteService._();

  static final SqliteService instance = SqliteService._();

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) return existing;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'finness.db');

    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _create,
    );

    _database = db;
    return db;
  }

  Future<void> _create(Database db, int version) async {
    await db.execute('''
      CREATE TABLE meals (
        uid TEXT NOT NULL,
        id TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        foodName TEXT NOT NULL,
        time TEXT NOT NULL,
        calories INTEGER NOT NULL,
        protein INTEGER NOT NULL,
        carbs INTEGER NOT NULL,
        fat INTEGER NOT NULL,
        ingredients TEXT NOT NULL,
        notes TEXT,
        eaten INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (uid, id)
      )
    ''');

    await db.execute('''
      CREATE TABLE workouts (
        uid TEXT NOT NULL,
        id TEXT NOT NULL,
        name TEXT NOT NULL,
        duration INTEGER NOT NULL,
        kcal INTEGER NOT NULL,
        difficulty TEXT NOT NULL,
        description TEXT NOT NULL,
        color TEXT NOT NULL,
        exercises TEXT NOT NULL,
        equipment TEXT,
        tags TEXT,
        PRIMARY KEY (uid, id)
      )
    ''');

    await db.execute('''
      CREATE TABLE workout_log (
        uid TEXT NOT NULL,
        id TEXT NOT NULL,
        date TEXT NOT NULL,
        workoutId TEXT NOT NULL,
        name TEXT NOT NULL,
        kcal INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        completedAt INTEGER NOT NULL,
        PRIMARY KEY (uid, id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sleep (
        uid TEXT NOT NULL,
        id TEXT NOT NULL,
        date TEXT NOT NULL,
        bedtime TEXT NOT NULL,
        wakeup TEXT NOT NULL,
        totalHours REAL NOT NULL,
        deepSleep REAL NOT NULL,
        lightSleep REAL NOT NULL,
        remSleep REAL NOT NULL,
        PRIMARY KEY (uid, date)
      )
    ''');

    await db.execute('CREATE INDEX meals_date_idx ON meals(uid, date)');
    await db.execute(
      'CREATE INDEX workout_log_date_idx ON workout_log(uid, date)',
    );
  }

  Future<List<Meal>> fetchMealsForDate(String uid, String date) async {
    final db = await database;
    final rows = await db.query(
      'meals',
      where: 'uid = ? AND date = ?',
      whereArgs: [uid, date],
      orderBy: 'time ASC',
    );

    return rows.map(_mealFromRow).toList();
  }

  Future<void> saveMeal(String uid, Meal meal) async {
    final db = await database;
    await db.insert(
      'meals',
      _mealToRow(uid, meal),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveMeals(String uid, Iterable<Meal> meals) async {
    final db = await database;
    final batch = db.batch();
    for (final meal in meals) {
      batch.insert(
        'meals',
        _mealToRow(uid, meal),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteMeal(String uid, Meal meal) async {
    final db = await database;
    await db.delete(
      'meals',
      where: 'uid = ? AND id = ?',
      whereArgs: [uid, meal.id],
    );
  }

  Future<List<Workout>> fetchWorkouts(String uid) async {
    final db = await database;
    final rows = await db.query(
      'workouts',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'name ASC',
    );

    return rows.map(_workoutFromRow).toList();
  }

  Future<void> saveWorkout(String uid, Workout workout) async {
    final db = await database;
    await db.insert(
      'workouts',
      _workoutToRow(uid, workout),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveWorkouts(String uid, Iterable<Workout> workouts) async {
    final db = await database;
    final batch = db.batch();
    for (final workout in workouts) {
      batch.insert(
        'workouts',
        _workoutToRow(uid, workout),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<WorkoutLogEntry>> fetchWorkoutLogForDate(
    String uid,
    String date,
  ) async {
    final db = await database;
    final rows = await db.query(
      'workout_log',
      where: 'uid = ? AND date = ?',
      whereArgs: [uid, date],
      orderBy: 'completedAt DESC',
    );

    return rows.map(_workoutLogFromRow).toList();
  }

  Future<void> saveWorkoutLogEntry(
    String uid,
    String date,
    WorkoutLogEntry entry,
  ) async {
    final db = await database;
    await db.insert(
      'workout_log',
      _workoutLogToRow(uid, date, entry),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveWorkoutLogEntries(
    String uid,
    String date,
    Iterable<WorkoutLogEntry> entries,
  ) async {
    final db = await database;
    final batch = db.batch();
    for (final entry in entries) {
      batch.insert(
        'workout_log',
        _workoutLogToRow(uid, date, entry),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<Sleep?> fetchSleepForDate(String uid, String date) async {
    final db = await database;
    final rows = await db.query(
      'sleep',
      where: 'uid = ? AND date = ?',
      whereArgs: [uid, date],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return _sleepFromRow(rows.first);
  }

  Future<Map<String, Sleep>> fetchAllSleep(String uid) async {
    final db = await database;
    final rows = await db.query(
      'sleep',
      where: 'uid = ?',
      whereArgs: [uid],
      orderBy: 'date DESC',
    );

    return {for (final row in rows) row['date'] as String: _sleepFromRow(row)};
  }

  Future<void> saveSleep(String uid, Sleep sleep) async {
    final db = await database;
    await db.insert(
      'sleep',
      _sleepToRow(uid, sleep),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAllSleep(String uid, Iterable<Sleep> records) async {
    final db = await database;
    final batch = db.batch();
    for (final sleep in records) {
      batch.insert(
        'sleep',
        _sleepToRow(uid, sleep),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}

Map<String, Object?> _mealToRow(String uid, Meal meal) {
  return {
    'uid': uid,
    'id': meal.id,
    'date': meal.date,
    'type': meal.type,
    'foodName': meal.foodName,
    'time': meal.time,
    'calories': meal.calories,
    'protein': meal.protein,
    'carbs': meal.carbs,
    'fat': meal.fat,
    'ingredients': jsonEncode(meal.ingredients),
    'notes': meal.notes,
    'eaten': (meal.eaten ?? false) ? 1 : 0,
  };
}

Meal _mealFromRow(Map<String, Object?> row) {
  return Meal.fromJson({
    'id': row['id'],
    'date': row['date'],
    'type': row['type'],
    'foodName': row['foodName'],
    'time': row['time'],
    'calories': row['calories'],
    'protein': row['protein'],
    'carbs': row['carbs'],
    'fat': row['fat'],
    'ingredients': _decodeList(row['ingredients']),
    'notes': row['notes'],
    'eaten': row['eaten'] == 1,
  });
}

Map<String, Object?> _workoutToRow(String uid, Workout workout) {
  return {
    'uid': uid,
    'id': workout.id,
    'name': workout.name,
    'duration': workout.duration,
    'kcal': workout.kcal,
    'difficulty': workout.difficulty,
    'description': workout.description,
    'color': workout.color,
    'exercises': jsonEncode(workout.exercises.map((e) => e.toJson()).toList()),
    'equipment': workout.equipment == null
        ? null
        : jsonEncode(workout.equipment),
    'tags': workout.tags == null ? null : jsonEncode(workout.tags),
  };
}

Workout _workoutFromRow(Map<String, Object?> row) {
  return Workout.fromJson({
    'id': row['id'],
    'name': row['name'],
    'duration': row['duration'],
    'kcal': row['kcal'],
    'difficulty': row['difficulty'],
    'description': row['description'],
    'color': row['color'],
    'exercises': _decodeList(row['exercises']),
    'equipment': _decodeList(row['equipment']),
    'tags': _decodeList(row['tags']),
  });
}

Map<String, Object?> _workoutLogToRow(
  String uid,
  String date,
  WorkoutLogEntry entry,
) {
  return {
    'uid': uid,
    'id': '${entry.workoutId}-${entry.completedAt}',
    'date': date,
    'workoutId': entry.workoutId,
    'name': entry.name,
    'kcal': entry.kcal,
    'duration': entry.duration,
    'completedAt': entry.completedAt,
  };
}

WorkoutLogEntry _workoutLogFromRow(Map<String, Object?> row) {
  return WorkoutLogEntry.fromJson({
    'workoutId': row['workoutId'],
    'name': row['name'],
    'kcal': row['kcal'],
    'duration': row['duration'],
    'completedAt': row['completedAt'],
  });
}

Map<String, Object?> _sleepToRow(String uid, Sleep sleep) {
  return {
    'uid': uid,
    'id': sleep.id,
    'date': sleep.date,
    'bedtime': sleep.bedtime,
    'wakeup': sleep.wakeup,
    'totalHours': sleep.totalHours,
    'deepSleep': sleep.deepSleep,
    'lightSleep': sleep.lightSleep,
    'remSleep': sleep.remSleep,
  };
}

Sleep _sleepFromRow(Map<String, Object?> row) {
  return Sleep.fromJson({
    'id': row['id'],
    'date': row['date'],
    'bedtime': row['bedtime'],
    'wakeup': row['wakeup'],
    'totalHours': row['totalHours'],
    'deepSleep': row['deepSleep'],
    'lightSleep': row['lightSleep'],
    'remSleep': row['remSleep'],
  });
}

List<Object?> _decodeList(Object? value) {
  if (value == null) return const [];
  if (value is List) return value;
  if (value is String && value.isNotEmpty) {
    final decoded = jsonDecode(value);
    if (decoded is List) return decoded;
  }
  return const [];
}
