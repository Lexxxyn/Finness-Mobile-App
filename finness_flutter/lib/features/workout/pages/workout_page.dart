import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/workout_service.dart';
import 'workout_detail_page.dart';

const _primaryColor = Color(0xFF42C8F5);
const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _textPrimaryColor = Color(0xFF1F2937);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);

class WorkoutPage extends StatefulWidget {
  static const routeName = '/workout';

  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final _service = WorkoutService();
  final _searchController = TextEditingController();

  List<Workout> _items = [];
  List<String> _equipment = const ['bodyweight'];
  String _goal = 'maintain';
  bool _loading = true;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final user = authService.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);

    try {
      final profile = await authService.loadProfile(user);
      final workouts = await _service.fetchWorkouts(user.uid);

      if (!mounted) return;
      setState(() {
        _equipment = profile.equipment == null || profile.equipment!.isEmpty
            ? const ['bodyweight']
            : profile.equipment!;
        _goal = profile.goal ?? 'maintain';
        _items = workouts;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  ({List<Workout> recommended, List<Workout> others}) get _sections {
    final q = _query.trim().toLowerCase();
    final filtered = _items.where((workout) {
      if (q.isEmpty) return true;
      return workout.name.toLowerCase().contains(q);
    });

    final recommended = <Workout>[];
    final others = <Workout>[];

    for (final workout in filtered) {
      final required = workout.equipment ?? const ['bodyweight'];
      final fits = required.any(_equipment.contains);
      if (fits) {
        recommended.add(workout);
      } else {
        others.add(workout);
      }
    }

    recommended.sort((a, b) => _goalScore(b).compareTo(_goalScore(a)));
    others.sort((a, b) => _goalScore(b).compareTo(_goalScore(a)));

    return (recommended: recommended, others: others);
  }

  int _goalScore(Workout workout) {
    final haystack = [
      workout.name,
      workout.difficulty,
      ...(workout.tags ?? const []),
    ].join(' ').toLowerCase();

    switch (_goal) {
      case 'lose_weight':
        if (haystack.contains('hiit') ||
            haystack.contains('cardio') ||
            haystack.contains('run') ||
            haystack.contains('fat-burn')) {
          return 3;
        }
        return workout.kcal >= 300 ? 2 : 1;
      case 'build_muscle':
        if (haystack.contains('strength') ||
            haystack.contains('muscle') ||
            haystack.contains('power')) {
          return 3;
        }
        return workout.difficulty == 'Intermediate' ? 2 : 1;
      case 'increase_weight':
        if (haystack.contains('weight-gain') ||
            haystack.contains('hypertrophy') ||
            haystack.contains('muscle')) {
          return 4;
        }
        return haystack.contains('strength') ? 3 : 1;
      case 'maintain_muscle':
        if (haystack.contains('maintain-muscle') ||
            haystack.contains('strength') ||
            haystack.contains('muscle')) {
          return 4;
        }
        return haystack.contains('mobility') ? 2 : 1;
      case 'improve_fitness':
        if (haystack.contains('endurance') ||
            haystack.contains('conditioning') ||
            haystack.contains('full-body')) {
          return 3;
        }
        return 2;
      case 'maintain':
      default:
        if (workout.difficulty == 'Beginner' ||
            haystack.contains('mindfulness') ||
            haystack.contains('mobility')) {
          return 3;
        }
        return 2;
    }
  }

  void _openWorkout(Workout workout) {
    Navigator.pushNamed(
      context,
      WorkoutDetailPage.routeFor(workout.id),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final sections = _sections;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textPrimaryColor,
        title: const Text('Workouts'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const Text(
                    'Choose your training session',
                    style: TextStyle(color: _textTertiaryColor, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _SearchField(controller: _searchController),
                  if (sections.recommended.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const _SectionTitle(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Recommended for You',
                    ),
                    Text(
                      'Based on your equipment and goal: ${_goalLabel(_goal)}',
                      style: const TextStyle(
                        color: _textTertiaryColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final workout in sections.recommended) ...[
                      _WorkoutCard(
                        workout: workout,
                        onTap: () => _openWorkout(workout),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  if (sections.others.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    const Text(
                      'Browse All Workouts',
                      style: TextStyle(
                        color: _textPrimaryColor,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Text(
                      'You can still try these without recommended equipment.',
                      style: TextStyle(color: _textTertiaryColor, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    for (final workout in sections.others) ...[
                      _WorkoutCard(
                        workout: workout,
                        onTap: () => _openWorkout(workout),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                  if (sections.recommended.isEmpty && sections.others.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'No workouts found.',
                          style: TextStyle(color: _textTertiaryColor),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

String _goalLabel(String goal) {
  switch (goal) {
    case 'lose_weight':
      return 'Lose weight';
    case 'build_muscle':
      return 'Build muscle';
    case 'increase_weight':
      return 'Increase weight';
    case 'maintain_muscle':
      return 'Maintain muscle';
    case 'improve_fitness':
      return 'Improve fitness';
    case 'maintain':
    default:
      return 'Maintain health';
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: TextField(
        key: const Key('workout-search-input'),
        controller: controller,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: _textTertiaryColor),
          hintText: 'Search workouts...',
          hintStyle: TextStyle(color: _textTertiaryColor),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _primaryColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _textPrimaryColor,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({required this.workout, required this.onTap});

  final Workout workout;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = parseColor(workout.color);

    return InkWell(
      key: Key('workout-card-${workout.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.fitness_center_rounded, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: const TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.difficulty} · ${workout.duration} min · ${workout.kcal} kcal',
                    style: const TextStyle(
                      color: _textTertiaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: _textTertiaryColor),
          ],
        ),
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

Color parseColor(String value) {
  final hex = value.trim().replaceFirst('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  if (hex.length == 8) {
    return Color(int.parse(hex, radix: 16));
  }
  return _primaryColor;
}
