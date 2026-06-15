import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/meal_service.dart';
import '../../../services/seed_service.dart';
import 'meal_common.dart';
import 'recipe_create_page.dart';

class MealLibraryPage extends StatefulWidget {
  static const routeName = '/meal/library';

  const MealLibraryPage({super.key});

  @override
  State<MealLibraryPage> createState() => _MealLibraryPageState();
}

class _MealLibraryPageState extends State<MealLibraryPage> {
  final _service = MealService();
  final _searchController = TextEditingController();
  List<Recipe> _recipes = const [];
  String _query = '';
  String _category = 'all';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
    _loadRecipes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    final user = authService.currentUser;
    if (user == null) return;
    final recipes = await _service.fetchRecipes(user.uid);
    if (!mounted) return;
    setState(() => _recipes = recipes);
  }

  List<MealTemplate> get _filteredTemplates {
    final q = _query.trim().toLowerCase();
    return mealLibrary.where((template) {
      if (_category != 'all' && template.category != _category) return false;
      if (q.isEmpty) return true;
      return template.name.toLowerCase().contains(q);
    }).toList();
  }

  List<Recipe> get _filteredRecipes {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _recipes;
    return _recipes
        .where((recipe) => recipe.name.toLowerCase().contains(q))
        .toList();
  }

  Meal _mealFromTemplate(MealTemplate template) {
    final date = todayString();
    return Meal(
      id: 'm-$date-${template.category}-${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      type: template.category,
      foodName: template.name,
      time: defaultTimeForMeal(template.category),
      calories: template.calories,
      protein: template.protein,
      carbs: template.carbs,
      fat: template.fat,
      ingredients: template.ingredients,
      notes: 'Added from library',
      eaten: false,
    );
  }

  Meal _mealFromRecipe(Recipe recipe) {
    final date = todayString();
    const type = mealTypeLunch;
    return Meal(
      id: 'm-$date-$type-${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      type: type,
      foodName: recipe.name,
      time: defaultTimeForMeal(type),
      calories: recipe.calories,
      protein: recipe.protein,
      carbs: recipe.carbs,
      fat: recipe.fat,
      ingredients: recipe.ingredients,
      notes: 'My recipe',
      eaten: false,
    );
  }

  Future<void> _previewMeal(Meal meal) async {
    final added = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealPreviewSheet(
        meal: meal,
        onAdd: () async {
          await _addMeal(meal);
          if (mounted) Navigator.pop(context, true);
        },
      ),
    );
    if (added == true && mounted) Navigator.pop(context);
  }

  Future<void> _addMeal(Meal meal) async {
    final user = authService.currentUser;
    if (user == null) return;
    await _service.saveMeal(user.uid, meal);
  }

  Future<void> _newRecipe() async {
    await Navigator.pushNamed(context, RecipeCreatePage.routeName);
    await _loadRecipes();
  }

  @override
  Widget build(BuildContext context) {
    final templates = _filteredTemplates;
    final recipes = _filteredRecipes;

    return Scaffold(
      backgroundColor: mealBackgroundColor,
      appBar: AppBar(
        backgroundColor: mealBackgroundColor,
        elevation: 0,
        foregroundColor: mealTextPrimaryColor,
        title: const Text('Meal Library'),
        actions: [
          IconButton(
            onPressed: _newRecipe,
            tooltip: 'New recipe',
            icon: const Icon(Icons.add_rounded, color: mealLogColor),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: mealCardDecoration(),
              child: TextField(
                key: const Key('library-search-input'),
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: mealTextTertiaryColor,
                  ),
                  hintText: 'Search meals or recipes...',
                  hintStyle: TextStyle(color: mealTextTertiaryColor),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                for (final category in const [
                  'all',
                  mealTypeBreakfast,
                  mealTypeLunch,
                  mealTypeSnack,
                  mealTypeDinner,
                ]) ...[
                  _CategoryChip(
                    label: category == 'all' ? 'All' : mealLabel(category),
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              children: [
                if (recipes.isNotEmpty) ...[
                  const _SectionTitle('My Recipes'),
                  for (final recipe in recipes) ...[
                    _RecipeCard(
                      recipe: recipe,
                      onTap: () => _previewMeal(_mealFromRecipe(recipe)),
                    ),
                    const SizedBox(height: 10),
                  ],
                  const SizedBox(height: 8),
                ],
                const _SectionTitle('Browse'),
                for (final template in templates) ...[
                  _TemplateCard(
                    template: template,
                    onTap: () => _previewMeal(_mealFromTemplate(template)),
                  ),
                  const SizedBox(height: 10),
                ],
                if (templates.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'No meals found in this category.',
                        style: TextStyle(color: mealTextTertiaryColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealPreviewSheet extends StatelessWidget {
  const _MealPreviewSheet({required this.meal, required this.onAdd});

  final Meal meal;
  final Future<void> Function() onAdd;

  @override
  Widget build(BuildContext context) {
    final color = mealColor(meal.type);

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: mealCardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(mealIcon(meal.type), color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mealLabel(meal.type).toUpperCase(),
                          style: const TextStyle(
                            color: mealTextTertiaryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          meal.foodName,
                          style: const TextStyle(
                            color: mealTextPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _PreviewMacro(label: 'Calories', value: '${meal.calories}'),
                  const SizedBox(width: 8),
                  _PreviewMacro(label: 'Protein', value: '${meal.protein}g'),
                  const SizedBox(width: 8),
                  _PreviewMacro(label: 'Carbs', value: '${meal.carbs}g'),
                  const SizedBox(width: 8),
                  _PreviewMacro(label: 'Fat', value: '${meal.fat}g'),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Ingredients',
                style: TextStyle(
                  color: mealTextPrimaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              for (final ingredient in meal.ingredients)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 7, color: color),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ingredient)),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAdd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text(
                    'Add Meal',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewMacro extends StatelessWidget {
  const _PreviewMacro({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: mealBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: mealTextPrimaryColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: mealTextTertiaryColor,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: mealLogColor,
      labelStyle: TextStyle(
        color: selected ? Colors.white : mealTextSecondaryColor,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: mealTextPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({required this.template, required this.onTap});

  final MealTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _LibraryCard(
      icon: mealIcon(template.category),
      iconColor: mealColor(template.category),
      kind: mealLabel(template.category),
      name: template.name,
      meta:
          '${template.calories} kcal - P ${template.protein}g - C ${template.carbs}g - F ${template.fat}g',
      onTap: onTap,
    );
  }
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.recipe, required this.onTap});

  final Recipe recipe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _LibraryCard(
      icon: Icons.receipt_long_rounded,
      iconColor: mealLogColor,
      name: recipe.name,
      meta:
          '${recipe.calories} kcal - P ${recipe.protein}g - C ${recipe.carbs}g - F ${recipe.fat}g',
      onTap: onTap,
    );
  }
}

class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.meta,
    required this.onTap,
    this.kind,
  });

  final IconData icon;
  final Color iconColor;
  final String name;
  final String meta;
  final VoidCallback onTap;
  final String? kind;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: mealCardDecoration(),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (kind != null)
                    Text(
                      kind!.toUpperCase(),
                      style: const TextStyle(
                        color: mealTextTertiaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mealTextPrimaryColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    meta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mealTextTertiaryColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: mealTextTertiaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
