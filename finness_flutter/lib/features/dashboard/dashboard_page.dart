import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../core/app_language.dart';
import '../../services/auth_service.dart';
import '../../services/meal_service.dart';
import '../../services/seed_service.dart';
import '../../services/sleep_service.dart';
import '../../services/workout_service.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/progress_bar.dart';
import '../../widgets/stat_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key, this.refreshSignal = 0});

  final int refreshSignal;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String? _name;
  int _workoutCount = 0;
  int _caloriesBurned = 0;
  int _nutritionCalories = 0;
  int _mealsLogged = 0;
  int _mealGoal = 4;
  double? _sleepHours;
  bool _loading = true;

  final _workoutService = WorkoutService();
  final _mealService = MealService();
  final _sleepService = SleepService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshSignal != widget.refreshSignal) {
      _loadData();
    }
  }

  String _greeting(AppText t) {
    final h = DateTime.now().hour;
    if (h < 12) return t.tr('dashboard.goodMorning');
    if (h < 18) return t.tr('dashboard.goodAfternoon');
    return t.tr('dashboard.goodEvening');
  }

  Future<void> _loadData() async {
    final user = authService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final today = DateTime.now().toIso8601String().split('T').first;

      final profile = await authService.loadProfile(user);
      final workouts = await _workoutService.fetchWorkoutLogForDate(
        user.uid,
        today,
      );
      final meals = await _mealService.fetchMealsForDate(user.uid, today);
      final sleep = await _sleepService.fetchSleepForDate(user.uid, today);
      final plannedMeals = meals.isEmpty
          ? defaultMealsForDate(today, goal: profile.goal)
          : meals;

      var caloriesBurned = 0;
      for (final workout in workouts) {
        caloriesBurned += workout.kcal;
      }

      var nutritionCalories = 0;
      var mealsLogged = 0;
      for (final meal in meals) {
        if (meal.eaten ?? false) {
          nutritionCalories += meal.calories;
          mealsLogged += 1;
        }
      }

      if (!mounted) return;
      setState(() {
        _name = profile.name.split(' ').first;
        _workoutCount = workouts.length;
        _caloriesBurned = caloriesBurned;
        _nutritionCalories = nutritionCalories;
        _mealsLogged = mealsLogged;
        _mealGoal = plannedMeals.isEmpty ? 1 : plannedMeals.length;
        _sleepHours = sleep?.totalHours;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _name ??= user.displayName ?? user.email?.split('@').first;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final friend = t.tr('dashboard.friend');

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tr('app.dashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await authService.logout();
              if (!mounted) return;
              navigator.pushReplacementNamed('/auth/login');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(t),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t
                          .tr('dashboard.hi')
                          .replaceAll('{name}', _name ?? friend),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              '/summary/calories',
                            );
                            await _loadData();
                          },
                          child: StatCard(
                            title: t.tr('dashboard.caloriesBurned'),
                            value: '$_caloriesBurned kcal',
                            subtitle: _workoutCount > 0
                                ? t
                                      .tr('dashboard.todayWorkouts')
                                      .replaceAll('{count}', '$_workoutCount')
                                      .replaceAll(
                                        '{workout}',
                                        t.tr(
                                          _workoutCount > 1
                                              ? 'dashboard.workouts'
                                              : 'dashboard.workout',
                                        ),
                                      )
                                : t.tr('dashboard.tapWorkouts'),
                            color: AppColors.statsCalories,
                            icon: const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(
                              context,
                              '/summary/nutrition',
                            );
                            await _loadData();
                          },
                          child: StatCard(
                            title: t.tr('dashboard.nutrition'),
                            value: '$_nutritionCalories kcal',
                            subtitle: _mealsLogged > 0
                                ? t
                                      .tr('dashboard.mealsEaten')
                                      .replaceAll('{count}', '$_mealsLogged')
                                      .replaceAll(
                                        '{meal}',
                                        t.tr(
                                          _mealsLogged > 1
                                              ? 'dashboard.meals'
                                              : 'dashboard.meal',
                                        ),
                                      )
                                : t.tr('dashboard.tapMeals'),
                            color: AppColors.statsNutrition,
                            icon: const Icon(Icons.apple, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            await Navigator.pushNamed(context, '/sleep');
                            await _loadData();
                          },
                          child: StatCard(
                            title: t.tr('dashboard.sleep'),
                            value: _sleepHours == null
                                ? '-'
                                : '${_sleepHours!.toStringAsFixed(1)} hrs',
                            subtitle: t.tr('dashboard.lastNight'),
                            color: AppColors.statsSleep,
                            icon: const Icon(
                              Icons.bedtime,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [shadowCard],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                t.tr('dashboard.dailyProgress'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Icon(Icons.trending_up, color: AppColors.primary),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.tr('dashboard.workoutGoal'),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ProgressBar(
                            value: (_workoutCount / 1).clamp(0.0, 1.0),
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.tr('dashboard.mealsLogged'),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ProgressBar(
                            value: (_mealsLogged / _mealGoal).clamp(0.0, 1.0),
                            color: AppColors.statsNutrition,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            t.tr('dashboard.sleepQuality'),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ProgressBar(
                            value: (_sleepHours ?? 0) / 8.0,
                            color: AppColors.statsSleep,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: t.tr('dashboard.startWorkout'),
                            color: AppColors.ctaStart,
                            textColor: Colors.white,
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/workout');
                              await _loadData();
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: t.tr('dashboard.logMeal'),
                            color: AppColors.ctaLogMeal,
                            textColor: Colors.white,
                            onPressed: () async {
                              await Navigator.pushNamed(context, '/meal');
                              await _loadData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
