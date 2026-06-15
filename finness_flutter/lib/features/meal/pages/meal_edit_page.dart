import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/meal_service.dart';
import '../../../services/seed_service.dart';
import '../../../widgets/primary_button.dart';
import 'meal_common.dart';

class MealEditPage extends StatefulWidget {
  static const routePrefix = '/meal/edit/';

  const MealEditPage({super.key, required this.mealType});

  final MealType mealType;

  static String routeFor(MealType mealType) => '$routePrefix$mealType';

  @override
  State<MealEditPage> createState() => _MealEditPageState();
}

class _MealEditPageState extends State<MealEditPage> {
  final _service = MealService();
  Meal? _meal;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    final today = todayString();
    var list = await _service.fetchMealsForDate(user.uid, today);
    if (list.isEmpty) list = defaultMealsForDate(today);

    if (!mounted) return;
    setState(() {
      _meal = list.where((meal) => meal.type == widget.mealType).firstOrNull;
      _loading = false;
    });
  }

  void _setMeal(Meal meal) {
    setState(() => _meal = meal);
  }

  void _setIngredient(int index, String value) {
    final meal = _meal;
    if (meal == null) return;
    final ingredients = [...meal.ingredients];
    ingredients[index] = value;
    _setMeal(meal.copyWith(ingredients: ingredients));
  }

  void _addIngredient() {
    final meal = _meal;
    if (meal == null) return;
    _setMeal(meal.copyWith(ingredients: [...meal.ingredients, '']));
  }

  void _removeIngredient(int index) {
    final meal = _meal;
    if (meal == null) return;
    _setMeal(
      meal.copyWith(
        ingredients: [
          for (var i = 0; i < meal.ingredients.length; i += 1)
            if (i != index) meal.ingredients[i],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final user = authService.currentUser;
    final meal = _meal;
    if (user == null || meal == null) return;

    setState(() => _saving = true);
    final cleaned = meal.copyWith(
      foodName: meal.foodName.trim(),
      time: meal.time.trim(),
      ingredients: meal.ingredients
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
    );

    await _service.saveMeal(user.uid, cleaned);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final meal = _meal;

    if (_loading || meal == null) {
      return const Scaffold(
        backgroundColor: mealBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: mealBackgroundColor,
      appBar: AppBar(
        backgroundColor: mealBackgroundColor,
        elevation: 0,
        foregroundColor: mealTextPrimaryColor,
        title: const Text('Edit Meal'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Card(
            child: Column(
              children: [
                MealTextField(
                  label: 'Food Name',
                  value: meal.foodName,
                  onChanged: (value) =>
                      _setMeal(meal.copyWith(foodName: value)),
                ),
                MealTextField(
                  label: 'Time',
                  value: meal.time,
                  hint: 'e.g. 8:00 AM',
                  prefixIcon: Icons.schedule_rounded,
                  onChanged: (value) => _setMeal(meal.copyWith(time: value)),
                ),
                MealTextField(
                  label: 'Calories',
                  value: '${meal.calories}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _setMeal(
                    meal.copyWith(calories: int.tryParse(value) ?? 0),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: MealTextField(
                        label: 'Protein (g)',
                        value: '${meal.protein}',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _setMeal(
                          meal.copyWith(protein: int.tryParse(value) ?? 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MealTextField(
                        label: 'Carbs (g)',
                        value: '${meal.carbs}',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _setMeal(
                          meal.copyWith(carbs: int.tryParse(value) ?? 0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MealTextField(
                        label: 'Fat (g)',
                        value: '${meal.fat}',
                        keyboardType: TextInputType.number,
                        onChanged: (value) => _setMeal(
                          meal.copyWith(fat: int.tryParse(value) ?? 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        color: mealTextPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                for (var i = 0; i < meal.ingredients.length; i += 1)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MealTextField(
                          value: meal.ingredients[i],
                          hint: 'Ingredient',
                          onChanged: (value) => _setIngredient(i, value),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeIngredient(i),
                        tooltip: 'Delete ingredient',
                        color: mealDangerColor,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save Changes',
            loading: _saving,
            onPress: _save,
            testID: 'edit-meal-save',
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: mealCardDecoration(),
      child: child,
    );
  }
}
