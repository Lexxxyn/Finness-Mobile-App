import '../models/models.dart' hide asStringMap;
import 'firebase_service.dart';
import 'sqlite_service.dart';

export '../models/models.dart' show Meal, Recipe;

class MealService {
  MealService({FirebaseService? firebaseService, SqliteService? sqliteService})
    : _firebase = firebaseService ?? FirebaseService.instance,
      _sqlite = sqliteService ?? SqliteService.instance;

  final FirebaseService _firebase;
  final SqliteService _sqlite;

  Future<List<Meal>> fetchMealsForDate(String uid, String date) async {
    final data = await _firebase.cachedFetch<Map<String, dynamic>>(
      uid: uid,
      kind: 'meals:$date',
      path: 'finnness/users/$uid/meals/$date',
      fromValue: asStringMap,
    );

    if (data == null) return _sqlite.fetchMealsForDate(uid, date);

    final meals = data.values
        .map((item) => Meal.fromJson(asStringMap(item)))
        .toList();
    await _sqlite.saveMeals(uid, meals);
    return meals;
  }

  Future<void> saveMeal(String uid, Meal meal) async {
    await _sqlite.saveMeal(uid, meal);

    await _firebase.setValue(
      'finnness/users/$uid/meals/${meal.date}/${meal.id}',
      meal.toJson(),
    );

    final list = await fetchMealsForDate(uid, meal.date);
    final map = <String, Object?>{};
    var replaced = false;

    for (final item in list) {
      if (item.id == meal.id) {
        map[item.id] = meal.toJson();
        replaced = true;
      } else {
        map[item.id] = item.toJson();
      }
    }

    if (!replaced) {
      map[meal.id] = meal.toJson();
    }

    await _firebase.updateCache(uid, 'meals:${meal.date}', map);
  }

  Future<void> toggleMealEaten(String uid, Meal meal, bool eaten) {
    return saveMeal(uid, meal.copyWith(eaten: eaten));
  }

  Future<void> deleteMeal(String uid, Meal meal) async {
    await _sqlite.deleteMeal(uid, meal);

    await _firebase.removeValue(
      'finnness/users/$uid/meals/${meal.date}/${meal.id}',
    );

    final list = await fetchMealsForDate(uid, meal.date);
    final map = <String, Object?>{};
    for (final item in list) {
      if (item.id != meal.id) {
        map[item.id] = item.toJson();
      }
    }

    await _firebase.updateCache(uid, 'meals:${meal.date}', map);
  }

  Future<List<Recipe>> fetchRecipes(String uid) async {
    final data = await _firebase.cachedFetch<Map<String, dynamic>>(
      uid: uid,
      kind: 'recipes',
      path: 'finnness/users/$uid/recipes',
      fromValue: asStringMap,
    );

    if (data == null) return [];

    final recipes = data.values
        .map((item) => Recipe.fromJson(asStringMap(item)))
        .toList();

    recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return recipes;
  }

  Future<void> saveRecipe(String uid, Recipe recipe) {
    return _firebase.setValue(
      'finnness/users/$uid/recipes/${recipe.id}',
      recipe.toJson(),
    );
  }
}
