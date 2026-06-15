typedef EquipmentId = String;
typedef Difficulty = String;
typedef MealType = String;
typedef FitnessGoal = String;

const difficultyBeginner = 'Beginner';
const difficultyIntermediate = 'Intermediate';
const difficultyAdvanced = 'Advanced';

const mealTypeBreakfast = 'breakfast';
const mealTypeLunch = 'lunch';
const mealTypeSnack = 'snack';
const mealTypeDinner = 'dinner';

const fitnessGoalLoseWeight = 'lose_weight';
const fitnessGoalBuildMuscle = 'build_muscle';
const fitnessGoalIncreaseWeight = 'increase_weight';
const fitnessGoalMaintainMuscle = 'maintain_muscle';
const fitnessGoalMaintain = 'maintain';
const fitnessGoalImproveFitness = 'improve_fitness';

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.cue,
  });

  final String id;
  final String name;
  final int sets;
  final int reps;
  final int? restSeconds;
  final String? cue;

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: asString(json['id']),
      name: asString(json['name']),
      sets: asInt(json['sets']),
      reps: asInt(json['reps']),
      restSeconds: asNullableInt(json['restSeconds']),
      cue: json['cue'] as String?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'sets': sets,
      'reps': reps,
      if (restSeconds != null) 'restSeconds': restSeconds,
      if (cue != null) 'cue': cue,
    };
  }
}

class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.duration,
    required this.kcal,
    required this.difficulty,
    required this.description,
    required this.color,
    required this.exercises,
    this.equipment,
    this.tags,
  });

  final String id;
  final String name;
  final int duration;
  final int kcal;
  final Difficulty difficulty;
  final String description;
  final String color;
  final List<Exercise> exercises;
  final List<EquipmentId>? equipment;
  final List<String>? tags;

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: asString(json['id']),
      name: asString(json['name']),
      duration: asInt(json['duration']),
      kcal: asInt(json['kcal']),
      difficulty: asString(json['difficulty'], fallback: difficultyBeginner),
      description: asString(json['description']),
      color: asString(json['color']),
      exercises: asList(
        json['exercises'],
      ).map((item) => Exercise.fromJson(asStringMap(item))).toList(),
      equipment: asNullableStringList(json['equipment']),
      tags: asNullableStringList(json['tags']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'kcal': kcal,
      'difficulty': difficulty,
      'description': description,
      'color': color,
      'exercises': exercises.map((item) => item.toJson()).toList(),
      if (equipment != null) 'equipment': equipment,
      if (tags != null) 'tags': tags,
    };
  }
}

class Meal {
  const Meal({
    required this.id,
    required this.date,
    required this.type,
    required this.foodName,
    required this.time,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    this.notes,
    this.eaten,
  });

  final String id;
  final String date;
  final MealType type;
  final String foodName;
  final String time;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final String? notes;
  final bool? eaten;

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: asString(json['id']),
      date: asString(json['date']),
      type: asString(json['type']),
      foodName: asString(json['foodName']),
      time: asString(json['time']),
      calories: asInt(json['calories']),
      protein: asInt(json['protein']),
      carbs: asInt(json['carbs']),
      fat: asInt(json['fat']),
      ingredients: asStringList(json['ingredients']),
      notes: json['notes'] as String?,
      eaten: json['eaten'] as bool?,
    );
  }

  Meal copyWith({
    String? id,
    String? date,
    MealType? type,
    String? foodName,
    String? time,
    int? calories,
    int? protein,
    int? carbs,
    int? fat,
    List<String>? ingredients,
    String? notes,
    Object? eaten = _unset,
  }) {
    return Meal(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      foodName: foodName ?? this.foodName,
      time: time ?? this.time,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      ingredients: ingredients ?? this.ingredients,
      notes: notes ?? this.notes,
      eaten: identical(eaten, _unset) ? this.eaten : eaten as bool?,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'date': date,
      'type': type,
      'foodName': foodName,
      'time': time,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      if (notes != null) 'notes': notes,
      if (eaten != null) 'eaten': eaten,
    };
  }
}

const Object _unset = Object();

class Sleep {
  const Sleep({
    required this.id,
    required this.date,
    required this.bedtime,
    required this.wakeup,
    required this.totalHours,
    required this.deepSleep,
    required this.lightSleep,
    required this.remSleep,
  });

  final String id;
  final String date;
  final String bedtime;
  final String wakeup;
  final double totalHours;
  final double deepSleep;
  final double lightSleep;
  final double remSleep;

  factory Sleep.fromJson(Map<String, dynamic> json) {
    return Sleep(
      id: asString(json['id']),
      date: asString(json['date']),
      bedtime: asString(json['bedtime']),
      wakeup: asString(json['wakeup']),
      totalHours: asDouble(json['totalHours']),
      deepSleep: asDouble(json['deepSleep']),
      lightSleep: asDouble(json['lightSleep']),
      remSleep: asDouble(json['remSleep']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'date': date,
      'bedtime': bedtime,
      'wakeup': wakeup,
      'totalHours': totalHours,
      'deepSleep': deepSleep,
      'lightSleep': lightSleep,
      'remSleep': remSleep,
    };
  }
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.gender,
    this.dob,
    this.height,
    this.weight,
    this.equipment,
    this.photo,
    this.goal,
  });

  final String uid;
  final String name;
  final String email;
  final String? gender;
  final String? dob;
  final double? height;
  final double? weight;
  final List<EquipmentId>? equipment;
  final String? photo;
  final FitnessGoal? goal;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: asString(json['uid']),
      name: asString(json['name']),
      email: asString(json['email']),
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      height: asNullableDouble(json['height']),
      weight: asNullableDouble(json['weight']),
      equipment: asNullableStringList(json['equipment']),
      photo: json['photo'] as String?,
      goal: json['goal'] as String?,
    );
  }

  factory UserProfile.fromMap(Map<dynamic, dynamic> map) {
    return UserProfile.fromJson(asStringMap(map));
  }

  Map<String, Object?> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      if (gender != null) 'gender': gender,
      if (dob != null) 'dob': dob,
      if (height != null) 'height': height,
      if (weight != null) 'weight': weight,
      if (equipment != null) 'equipment': equipment,
      if (photo != null) 'photo': photo,
      if (goal != null) 'goal': goal,
    };
  }

  Map<String, Object?> toMap() => toJson();
}

class WorkoutLogEntry {
  const WorkoutLogEntry({
    required this.workoutId,
    required this.name,
    required this.kcal,
    required this.duration,
    required this.completedAt,
  });

  final String workoutId;
  final String name;
  final int kcal;
  final int duration;
  final int completedAt;

  factory WorkoutLogEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutLogEntry(
      workoutId: asString(json['workoutId']),
      name: asString(json['name']),
      kcal: asInt(json['kcal']),
      duration: asInt(json['duration']),
      completedAt: asInt(json['completedAt']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'workoutId': workoutId,
      'name': name,
      'kcal': kcal,
      'duration': duration,
      'completedAt': completedAt,
    };
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
  final int createdAt;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: asString(json['id']),
      name: asString(json['name']),
      calories: asInt(json['calories']),
      protein: asInt(json['protein']),
      carbs: asInt(json['carbs']),
      fat: asInt(json['fat']),
      ingredients: asStringList(json['ingredients']),
      createdAt: asInt(json['createdAt']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'ingredients': ingredients,
      'createdAt': createdAt,
    };
  }
}

Map<String, dynamic> asStringMap(Object? value) {
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  return {};
}

List<dynamic> asList(Object? value) {
  if (value is List) return value;
  return const [];
}

String asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

int asInt(Object? value, {int fallback = 0}) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? asNullableInt(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double asDouble(Object? value, {double fallback = 0}) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? fallback;
}

double? asNullableDouble(Object? value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<String> asStringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return [];
}

List<String>? asNullableStringList(Object? value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return null;
}
