import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/meal_service.dart';
import '../../../services/seed_service.dart';
import 'meal_common.dart';
import 'meal_edit_page.dart';

class MealTypePage extends StatefulWidget {
  static const routePrefix = '/meal/';

  const MealTypePage({super.key, required this.mealIdentifier});

  final String mealIdentifier;

  static String routeFor(String mealIdentifier) =>
      '$routePrefix$mealIdentifier';

  @override
  State<MealTypePage> createState() => _MealTypePageState();
}

class _MealTypePageState extends State<MealTypePage> {
  final _service = MealService();
  Meal? _meal;
  bool _loading = true;

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
      _meal = list
          .where(
            (meal) =>
                meal.id == widget.mealIdentifier ||
                meal.type == widget.mealIdentifier,
          )
          .firstOrNull;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final meal = _meal;
    if (meal == null) return;
    await Navigator.pushNamed(context, MealEditPage.routeFor(meal.type));
    await _load();
  }

  Future<void> _delete() async {
    final user = authService.currentUser;
    final meal = _meal;
    if (user == null || meal == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove meal?'),
        content: Text('Remove ${meal.foodName} from today?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: mealDangerColor),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    await _service.deleteMeal(user.uid, meal);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final meal = _meal;

    if (_loading) {
      return const Scaffold(
        backgroundColor: mealBackgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (meal == null) {
      return Scaffold(
        backgroundColor: mealBackgroundColor,
        appBar: AppBar(title: const Text('Meal')),
        body: const Center(child: Text('Meal not found.')),
      );
    }

    final color = mealColor(meal.type);

    return Scaffold(
      backgroundColor: mealBackgroundColor,
      body: Column(
        children: [
          _Hero(meal: meal, color: color, onEdit: _edit, onDelete: _delete),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                Row(
                  children: [
                    _MacroCard(
                      value: '${meal.protein}g',
                      label: 'Protein',
                      color: const Color(0xFF1D4ED8),
                      backgroundColor: const Color(0xFFDCEEFE),
                    ),
                    const SizedBox(width: 10),
                    _MacroCard(
                      value: '${meal.carbs}g',
                      label: 'Carbs',
                      color: const Color(0xFFC2410C),
                      backgroundColor: const Color(0xFFFFE6CC),
                    ),
                    const SizedBox(width: 10),
                    _MacroCard(
                      value: '${meal.fat}g',
                      label: 'Fat',
                      color: const Color(0xFFB91C1C),
                      backgroundColor: const Color(0xFFFEE2E2),
                    ),
                  ],
                ),
                const _SectionHeader('Ingredients'),
                for (final ingredient in meal.ingredients) ...[
                  _IngredientRow(text: ingredient, color: color),
                  const SizedBox(height: 8),
                ],
                if ((meal.notes ?? '').isNotEmpty) ...[
                  const _SectionHeader('Notes'),
                  Text(
                    meal.notes!,
                    style: const TextStyle(
                      color: mealTextSecondaryColor,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.meal,
    required this.color,
    required this.onEdit,
    required this.onDelete,
  });

  final Meal meal;
  final Color color;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        16,
        28,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _HeaderButton(
                icon: Icons.arrow_back_rounded,
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
              ),
              _HeaderButton(
                icon: Icons.edit_rounded,
                tooltip: 'Edit meal',
                onPressed: onEdit,
              ),
              _HeaderButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Remove meal',
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            mealLabel(meal.type).toUpperCase(),
            style: const TextStyle(
              color: Color(0xEEFFFFFF),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            meal.foodName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${meal.time} - ${meal.calories} kcal',
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.25),
        foregroundColor: Colors.white,
      ),
      icon: Icon(icon),
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.value,
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String value;
  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: mealTextSecondaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: mealTextPrimaryColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: mealCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: mealTextPrimaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
