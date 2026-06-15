import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/workout_service.dart';
import '../../../widgets/primary_button.dart';
import 'workout_edit_page.dart';
import 'workout_page.dart';
import 'workout_play.dart';

class WorkoutDetailPage extends StatefulWidget {
  static const routePrefix = '/workout/';

  const WorkoutDetailPage({super.key, required this.workoutId});

  final String workoutId;

  static String routeFor(String workoutId) => '$routePrefix$workoutId';

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  final _service = WorkoutService();
  Workout? _workout;
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

    final workout = await _service.fetchWorkout(user.uid, widget.workoutId);
    if (!mounted) return;
    setState(() {
      _workout = workout;
      _loading = false;
    });
  }

  Future<void> _edit() async {
    final workout = _workout;
    if (workout == null) return;
    await Navigator.pushNamed(context, WorkoutEditPage.routeFor(workout.id));
    await _load();
  }

  void _start() {
    final workout = _workout;
    if (workout == null) return;
    Navigator.pushNamed(context, WorkoutPlayPage.routeFor(workout.id));
  }

  @override
  Widget build(BuildContext context) {
    final workout = _workout;

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEF3F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (workout == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFEEF3F8),
        appBar: AppBar(title: const Text('Workout')),
        body: const Center(child: Text('Workout not found.')),
      );
    }

    final color = parseColor(workout.color);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F8),
      body: Column(
        children: [
          _Hero(workout: workout, color: color, onEdit: _edit),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                Transform.translate(
                  offset: const Offset(0, -16),
                  child: Row(
                    children: [
                      _StatChip(
                        icon: Icons.schedule_rounded,
                        value: '${workout.duration}m',
                        label: 'Duration',
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.local_fire_department_rounded,
                        value: '${workout.kcal}',
                        label: 'kcal',
                        color: color,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        icon: Icons.show_chart_rounded,
                        value: workout.difficulty.substring(0, 3),
                        label: 'Level',
                        color: color,
                      ),
                    ],
                  ),
                ),
                const _SectionHeader('About'),
                Text(
                  workout.description,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const _SectionHeader('Exercises'),
                for (var i = 0; i < workout.exercises.length; i += 1) ...[
                  _ExerciseRow(
                    exercise: workout.exercises[i],
                    index: i,
                    color: color,
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                label: 'Start Workout',
                color: color,
                onPress: _start,
                testID: 'workout-detail-start',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.workout,
    required this.color,
    required this.onEdit,
  });

  final Workout workout;
  final Color color;
  final VoidCallback onEdit;

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
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
              ),
              _HeaderButton(
                icon: Icons.edit_rounded,
                onPressed: onEdit,
                tooltip: 'Edit',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            workout.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${workout.difficulty} · ${workout.duration} minutes',
            style: const TextStyle(
              color: Color(0xDDFFFFFF),
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
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

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

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.exercise,
    required this.index,
    required this.color,
  });

  final Exercise exercise;
  final int index;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('workout-exercise-${exercise.id}'),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${exercise.sets} sets x ${exercise.reps} reps',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
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

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: const Color(0xFF1F2937).withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}
