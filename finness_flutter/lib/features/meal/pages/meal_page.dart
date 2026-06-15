import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/meal_service.dart';
import '../../../services/seed_service.dart';
import '../../../widgets/progress_bar.dart';
import 'meal_common.dart';
import 'meal_library_page.dart';
import 'meal_type_page.dart';
import 'recipe_create_page.dart';

class MealPage extends StatefulWidget {
  static const routeName = '/meal';

  const MealPage({super.key});

  @override
  State<MealPage> createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> {
  final _service = MealService();
  List<Meal> _meals = const [];
  String _goal = 'maintain';
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

    setState(() => _loading = true);
    try {
      final today = todayString();
      final profile = await authService.currentProfile;
      final selectedGoal = profile?.goal ?? 'maintain';
      var list = await _service.fetchMealsForDate(user.uid, today);
      if (list.isEmpty) {
        list = defaultMealsForDate(today, goal: selectedGoal);
        for (final meal in list) {
          _service.saveMeal(user.uid, meal);
        }
      }

      if (!mounted) return;
      setState(() {
        _goal = selectedGoal;
        _meals = list;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Meal> get _ordered {
    final planned = <Meal>[];
    final extras = [..._meals];

    for (final type in mealOrder) {
      var index = extras.indexWhere(
        (meal) => meal.id == 'm-${meal.date}-$type',
      );
      if (index == -1) {
        index = extras.indexWhere((meal) => meal.type == type);
      }
      if (index != -1) {
        planned.add(extras.removeAt(index));
      }
    }

    extras.sort((a, b) => a.time.compareTo(b.time));
    return [...planned, ...extras];
  }

  int get _eatenIntake {
    return _meals
        .where((meal) => meal.eaten ?? false)
        .fold(0, (sum, meal) => sum + meal.calories);
  }

  int get _plannedIntake {
    return _meals.fold(0, (sum, meal) => sum + meal.calories);
  }

  Future<void> _toggle(Meal meal, bool eaten) async {
    final user = authService.currentUser;
    if (user == null) return;

    setState(() {
      _meals = [
        for (final item in _meals)
          item.id == meal.id ? item.copyWith(eaten: eaten) : item,
      ];
    });

    await _service.toggleMealEaten(user.uid, meal, eaten);
  }

  Future<void> _open(String route) async {
    await Navigator.pushNamed(context, route);
    await _load();
  }

  Future<void> _regeneratePlan() async {
    final user = authService.currentUser;
    if (user == null) return;

    final today = todayString();
    final meals = defaultMealsForDate(today, goal: _goal);
    for (final meal in meals) {
      await _service.saveMeal(user.uid, meal);
    }
    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meal plan regenerated from your goal.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mealBackgroundColor,
      appBar: AppBar(
        backgroundColor: mealBackgroundColor,
        elevation: 0,
        foregroundColor: mealTextPrimaryColor,
        title: const Text('Meal Planner'),
        actions: [
          IconButton(
            onPressed: _regeneratePlan,
            tooltip: 'Regenerate plan',
            icon: const Icon(Icons.auto_awesome_rounded, color: mealLogColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const Text(
                    'Check off meals as you eat them. Intake updates live.',
                    style: TextStyle(
                      color: mealTextTertiaryColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _IntakeCard(
                    intake: _eatenIntake,
                    planCalories: _plannedIntake,
                    calorieBudget: _calorieGoal,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.menu_book_rounded,
                          iconColor: mealPrimaryColor,
                          title: 'Browse Library',
                          subtitle: 'Pick from saved meals',
                          onTap: () => _open(MealLibraryPage.routeName),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionTile(
                          icon: Icons.add_rounded,
                          iconColor: mealLogColor,
                          title: 'Create Recipe',
                          subtitle: 'Add your own meal',
                          onTap: () => _open(RecipeCreatePage.routeName),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    "Today's Plan",
                    style: TextStyle(
                      color: mealTextPrimaryColor,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final meal in _ordered) ...[
                    _MealCard(
                      meal: meal,
                      onTap: () => _open(MealTypePage.routeFor(meal.id)),
                      onToggle: (next) => _toggle(meal, next),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
    );
  }

  int get _calorieGoal {
    switch (_goal) {
      case 'lose_weight':
        return 1700;
      case 'build_muscle':
        return 2400;
      case 'increase_weight':
        return 2700;
      case 'maintain_muscle':
        return 2300;
      case 'improve_fitness':
        return 2200;
      case 'maintain':
      default:
        return 2000;
    }
  }
}

class _IntakeCard extends StatelessWidget {
  const _IntakeCard({
    required this.intake,
    required this.planCalories,
    required this.calorieBudget,
  });

  final int intake;
  final int planCalories;
  final int calorieBudget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: mealCardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Metric(label: 'Eaten Today', value: '$intake kcal'),
              _Metric(
                label: 'Plan',
                value: '$planCalories kcal',
                crossAxisAlignment: CrossAxisAlignment.end,
                valueColor: mealLogColor,
                valueSize: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ProgressBar(
            value: intake / (planCalories == 0 ? calorieBudget : planCalories),
            color: mealLogColor,
            trackColor: mealBackgroundColor,
          ),
          const SizedBox(height: 8),
          Text(
            'Daily budget: $calorieBudget kcal',
            style: const TextStyle(
              color: mealTextTertiaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (intake > calorieBudget) ...[
            const SizedBox(height: 10),
            _CalorieWarning(intake: intake, goal: calorieBudget),
          ],
        ],
      ),
    );
  }
}

class _CalorieWarning extends StatelessWidget {
  const _CalorieWarning({required this.intake, required this.goal});

  final int intake;
  final int goal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFF97316)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF97316),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You are ${intake - goal} kcal over your daily goal.',
              style: const TextStyle(
                color: Color(0xFF9A3412),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.valueColor = mealTextPrimaryColor,
    this.valueSize = 24,
  });

  final String label;
  final String value;
  final CrossAxisAlignment crossAxisAlignment;
  final Color valueColor;
  final double valueSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: mealTextTertiaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: valueSize,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mealTextPrimaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: mealTextTertiaryColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.onTap,
    required this.onToggle,
  });

  final Meal meal;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    final color = mealColor(meal.type);
    final eaten = meal.eaten ?? false;

    return InkWell(
      key: Key('meal-card-${meal.type}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Opacity(
        opacity: eaten ? 0.78 : 1,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: mealCardDecoration(color: color),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(mealIcon(meal.type), color: Colors.white, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealLabel(meal.type).toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xEEFFFFFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meal.foodName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: eaten ? const Color(0xDDFFFFFF) : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        decoration: eaten ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    Text(
                      '${meal.time} - ${meal.calories} kcal',
                      style: const TextStyle(
                        color: Color(0xDDFFFFFF),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: Key('meal-card-${meal.type}-check'),
                onPressed: () => onToggle(!eaten),
                tooltip: eaten ? 'Mark not eaten' : 'Mark eaten',
                style: IconButton.styleFrom(
                  fixedSize: const Size(36, 36),
                  backgroundColor: eaten ? Colors.white : Colors.transparent,
                  foregroundColor: eaten ? color : Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                icon: eaten
                    ? const Icon(Icons.check_rounded, size: 20)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
