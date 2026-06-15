import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/meal_service.dart';
import '../../../widgets/primary_button.dart';
import 'meal_common.dart';

class RecipeCreatePage extends StatefulWidget {
  static const routeName = '/meal/recipe-new';

  const RecipeCreatePage({super.key});

  @override
  State<RecipeCreatePage> createState() => _RecipeCreatePageState();
}

class _RecipeCreatePageState extends State<RecipeCreatePage> {
  String _name = '';
  String _calories = '';
  String _protein = '';
  String _carbs = '';
  String _fat = '';
  List<String> _ingredients = [''];
  bool _saving = false;
  String? _error;

  final _service = MealService();

  void _setIngredient(int index, String value) {
    setState(() {
      _ingredients = [
        for (var i = 0; i < _ingredients.length; i += 1)
          i == index ? value : _ingredients[i],
      ];
    });
  }

  void _addIngredient() {
    setState(() => _ingredients = [..._ingredients, '']);
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients = [
        for (var i = 0; i < _ingredients.length; i += 1)
          if (i != index) _ingredients[i],
      ];
    });
  }

  Future<void> _save() async {
    final user = authService.currentUser;
    if (user == null) return;

    setState(() => _error = null);
    if (_name.trim().isEmpty) {
      setState(() => _error = 'Recipe needs a name.');
      return;
    }
    if (_calories.trim().isEmpty) {
      setState(() => _error = 'Add a calorie estimate.');
      return;
    }

    setState(() => _saving = true);
    final recipe = Recipe(
      id: 'r-${DateTime.now().millisecondsSinceEpoch}',
      name: _name.trim(),
      calories: int.tryParse(_calories) ?? 0,
      protein: int.tryParse(_protein) ?? 0,
      carbs: int.tryParse(_carbs) ?? 0,
      fat: int.tryParse(_fat) ?? 0,
      ingredients: _ingredients
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _service.saveRecipe(user.uid, recipe);
    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mealBackgroundColor,
      appBar: AppBar(
        backgroundColor: mealBackgroundColor,
        elevation: 0,
        foregroundColor: mealTextPrimaryColor,
        title: const Text('New Recipe'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Card(
            child: Column(
              children: [
                MealTextField(
                  label: 'Recipe Name',
                  hint: 'My Power Bowl',
                  value: _name,
                  onChanged: (value) => setState(() => _name = value),
                ),
                MealTextField(
                  label: 'Calories (kcal)',
                  hint: '500',
                  value: _calories,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => setState(() => _calories = value),
                ),
                Row(
                  children: [
                    Expanded(
                      child: MealTextField(
                        label: 'Protein (g)',
                        value: _protein,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _protein = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MealTextField(
                        label: 'Carbs (g)',
                        value: _carbs,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _carbs = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MealTextField(
                        label: 'Fat (g)',
                        value: _fat,
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _fat = value),
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
                for (var i = 0; i < _ingredients.length; i += 1)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: MealTextField(
                          value: _ingredients[i],
                          hint: 'e.g. 100g chicken breast',
                          onChanged: (value) => _setIngredient(i, value),
                        ),
                      ),
                      if (_ingredients.length > 1)
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
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: mealDangerColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save Recipe',
            color: mealLogColor,
            loading: _saving,
            onPress: _save,
            testID: 'recipe-save-button',
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
