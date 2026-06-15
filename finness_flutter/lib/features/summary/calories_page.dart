import 'package:flutter/material.dart';

import '../../core/app_language.dart';
import '../../services/auth_service.dart';
import '../../services/workout_service.dart';
import '../../widgets/primary_button.dart';
import '../workout/pages/workout_page.dart';

const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _caloriesColor = Color(0xFFF97316);
const _textPrimaryColor = Color(0xFF1F2937);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);

class CaloriesPage extends StatefulWidget {
  static const routeName = '/summary/calories';

  const CaloriesPage({super.key});

  @override
  State<CaloriesPage> createState() => _CaloriesPageState();
}

class _CaloriesPageState extends State<CaloriesPage> {
  final _service = WorkoutService();

  List<WorkoutLogEntry> _entries = const [];
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
    final entries = await _service.fetchWorkoutLogForDate(
      user.uid,
      _todayString(),
    );
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  int get _totalCalories {
    return _entries.fold(0, (sum, entry) => sum + entry.kcal);
  }

  int get _totalMinutes {
    return _entries.fold(0, (sum, entry) => sum + entry.duration);
  }

  Future<void> _startWorkout() async {
    await Navigator.pushReplacementNamed(context, WorkoutPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      backgroundColor: _caloriesColor,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              title: t.tr('dashboard.caloriesBurned'),
              onBack: () => Navigator.pop(context),
            ),
            _Hero(
              total: _totalCalories,
              workouts: _entries.length,
              minutes: _totalMinutes,
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
                    Text(
                      t.tr('summary.completedToday'),
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
                          : _entries.isEmpty
                          ? _EmptyState(onStartWorkout: _startWorkout)
                          : RefreshIndicator(
                              onRefresh: _load,
                              child: ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: _entries.length,
                                itemBuilder: (context, index) {
                                  return _WorkoutRow(
                                    entry: _entries[index],
                                    index: index,
                                  );
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
    required this.total,
    required this.workouts,
    required this.minutes,
  });

  final int total;
  final int workouts;
  final int minutes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            '$total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            context.t.tr('summary.kcalToday'),
            style: const TextStyle(
              color: Color(0xDDFFFFFF),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$workouts workouts - $minutes min total',
            style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onStartWorkout});

  final VoidCallback onStartWorkout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Text(
            context.t.tr('summary.noWorkouts'),
            style: const TextStyle(color: _textTertiaryColor, fontSize: 14),
          ),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: context.t.tr('summary.startWorkout'),
          color: _caloriesColor,
          onPressed: onStartWorkout,
          testID: 'summary-start-workout',
        ),
      ],
    );
  }
}

class _WorkoutRow extends StatelessWidget {
  const _WorkoutRow({required this.entry, required this.index});

  final WorkoutLogEntry entry;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('summary-workout-$index'),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              color: _caloriesColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPrimaryColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      color: _textTertiaryColor,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.duration} min',
                      style: const TextStyle(
                        color: _textTertiaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        _timeAgo(entry.completedAt),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _textTertiaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${entry.kcal} kcal',
            style: const TextStyle(
              color: _caloriesColor,
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

String _todayString() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

String _timeAgo(int milliseconds) {
  final completed = DateTime.fromMillisecondsSinceEpoch(milliseconds);
  final diff = DateTime.now().difference(completed);
  final minutes = diff.inMinutes.round();
  if (minutes < 1) return 'Just now';
  if (minutes < 60) return '${minutes}m ago';
  final hours = (minutes / 60).round();
  if (hours < 24) return '${hours}h ago';
  return '${completed.month}/${completed.day}/${completed.year}';
}
