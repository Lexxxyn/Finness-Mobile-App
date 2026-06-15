import 'package:flutter/material.dart';

import '../../core/app_language.dart';
import '../../services/auth_service.dart';
import '../../services/meal_service.dart';
import '../../widgets/progress_bar.dart';
import '../meal/pages/meal_common.dart';

const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _nutritionColor = Color(0xFF10B981);
const _textPrimaryColor = Color(0xFF1F2937);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _goal = 2000;

class NutritionPage extends StatefulWidget {
  static const routeName = '/summary/nutrition';

  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final _service = MealService();

  List<Meal> _meals = const [];
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
    final meals = await _service.fetchMealsForDate(user.uid, todayString());
    if (!mounted) return;
    setState(() {
      _meals = meals;
      _loading = false;
    });
  }

  List<Meal> get _eaten {
    return _meals.where((meal) => meal.eaten ?? false).toList();
  }

  int get _intake {
    return _eaten.fold(0, (sum, meal) => sum + meal.calories);
  }

  int get _protein {
    return _eaten.fold(0, (sum, meal) => sum + meal.protein);
  }

  int get _carbs {
    return _eaten.fold(0, (sum, meal) => sum + meal.carbs);
  }

  int get _fat {
    return _eaten.fold(0, (sum, meal) => sum + meal.fat);
  }

  @override
  Widget build(BuildContext context) {
    final eaten = _eaten;
    final t = context.t;

    return Scaffold(
      backgroundColor: _nutritionColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: t.tr('dashboard.nutrition'),
              onBack: () => Navigator.pop(context),
            ),
            _Hero(
              intake: _intake,
              eatenCount: eaten.length,
              mealCount: _meals.length,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                decoration: const BoxDecoration(
                  color: _backgroundColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _MacroCard(
                          value: '${_protein}g',
                          label: t.tr('summary.protein'),
                          color: const Color(0xFF1D4ED8),
                          backgroundColor: const Color(0xFFDCEEFE),
                        ),
                        const SizedBox(width: 10),
                        _MacroCard(
                          value: '${_carbs}g',
                          label: t.tr('summary.carbs'),
                          color: const Color(0xFFC2410C),
                          backgroundColor: const Color(0xFFFFE6CC),
                        ),
                        const SizedBox(width: 10),
                        _MacroCard(
                          value: '${_fat}g',
                          label: t.tr('summary.fat'),
                          color: const Color(0xFFB91C1C),
                          backgroundColor: const Color(0xFFFEE2E2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      t.tr('summary.mealsEaten'),
                      style: const TextStyle(
                        color: _textPrimaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : eaten.isEmpty
                          ? const _EmptyState()
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: eaten.length,
                                itemBuilder: (context, index) {
                                  return _MealRow(meal: eaten[index]);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            key: const Key('summary-back'),
            onPressed: onBack,
            tooltip: context.t.tr('app.back'),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.intake,
    required this.eatenCount,
    required this.mealCount,
  });

  final int intake;
  final int eatenCount;
  final int mealCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          const Icon(Icons.apple_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 8),
          Text(
            '$intake',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            context.t.tr('summary.kcalEaten'),
            style: const TextStyle(
              color: Color(0xDDFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          ProgressBar(
            value: intake / _goal,
            color: Colors.white,
            trackColor: Colors.white24,
          ),
          const SizedBox(height: 8),
          Text(
            '$eatenCount/$mealCount ${context.t.tr('app.meals').toLowerCase()} - ${context.t.tr('summary.goal')} $_goal kcal',
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
          ),
          if (intake > _goal) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white54),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${intake - _goal} kcal over goal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
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
        padding: const EdgeInsets.symmetric(vertical: 14),
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
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            context.t.tr('summary.noMeals'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _textTertiaryColor,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final color = mealColor(meal.type);

    return Container(
      key: Key('summary-meal-${meal.type}'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${mealLabel(meal.type)} - ${meal.time}'.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textTertiaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  meal.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${meal.calories} kcal',
            style: const TextStyle(
              color: _nutritionColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: _cardColor,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: _borderColor),
    boxShadow: [
      BoxShadow(
        color: _textPrimaryColor.withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
