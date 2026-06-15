import 'dart:async';

import 'package:flutter/material.dart';

import '../../../services/auth_service.dart';
import '../../../services/workout_service.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/progress_bar.dart';
import 'workout_page.dart';

enum _Phase { exercise, rest, done }

class WorkoutPlayPage extends StatefulWidget {
  static const routePrefix = '/workout/play/';

  const WorkoutPlayPage({super.key, required this.workoutId});

  final String workoutId;

  static String routeFor(String workoutId) => '$routePrefix$workoutId';

  @override
  State<WorkoutPlayPage> createState() => _WorkoutPlayPageState();
}

class _WorkoutPlayPageState extends State<WorkoutPlayPage> {
  final _service = WorkoutService();
  final _startedAt = DateTime.now();

  Timer? _timer;
  Workout? _workout;
  _Phase _phase = _Phase.exercise;
  int _exerciseIndex = 0;
  int _setIndex = 0;
  int _secondsLeft = 0;
  bool _paused = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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

  Exercise? get _currentExercise =>
      _workout?.exercises.elementAtOrNull(_exerciseIndex);

  int get _totalSets {
    final workout = _workout;
    if (workout == null) return 0;
    return workout.exercises.fold(0, (sum, exercise) => sum + exercise.sets);
  }

  int get _completedSets {
    final workout = _workout;
    if (workout == null) return 0;
    var count = 0;
    for (var i = 0; i < _exerciseIndex; i += 1) {
      count += workout.exercises[i].sets;
    }
    return count + _setIndex;
  }

  double get _progress => _totalSets == 0 ? 0 : _completedSets / _totalSets;

  void _completeSet() {
    final workout = _workout;
    final exercise = _currentExercise;
    if (workout == null || exercise == null) return;

    final nextSet = _setIndex + 1;
    final isLastSetOfExercise = nextSet >= exercise.sets;
    final isLastExercise = _exerciseIndex >= workout.exercises.length - 1;

    if (isLastSetOfExercise && isLastExercise) {
      _finishWorkout();
      return;
    }

    final restSeconds = exercise.restSeconds ?? 30;
    if (restSeconds > 0) {
      setState(() {
        _phase = _Phase.rest;
        _secondsLeft = restSeconds;
        _paused = false;
      });
      _startTimer();
    } else {
      _advance();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _paused) return;
      if (_secondsLeft <= 1) {
        timer.cancel();
        _skipRest();
        return;
      }
      setState(() => _secondsLeft -= 1);
    });
  }

  void _advance() {
    final exercise = _currentExercise;
    if (exercise == null) return;
    final isLastSetOfExercise = _setIndex + 1 >= exercise.sets;
    setState(() {
      if (isLastSetOfExercise) {
        _setIndex = 0;
        _exerciseIndex += 1;
      } else {
        _setIndex += 1;
      }
      _phase = _Phase.exercise;
      _secondsLeft = 0;
      _paused = false;
    });
  }

  void _skipRest() {
    _timer?.cancel();
    _advance();
  }

  Future<void> _finishWorkout() async {
    _timer?.cancel();
    final user = authService.currentUser;
    final workout = _workout;
    setState(() => _phase = _Phase.done);
    if (user == null || workout == null) return;

    final elapsedSeconds = DateTime.now().difference(_startedAt).inSeconds;
    final elapsedMinutes = (elapsedSeconds / 60).round().clamp(1, 10000);
    final ratio =
        (elapsedMinutes / (workout.duration == 0 ? 1 : workout.duration))
            .clamp(0.5, 1.5)
            .toDouble();
    final kcal = (workout.kcal * ratio).round();

    await _service.logWorkoutCompletion(
      user.uid,
      WorkoutLogEntry(
        workoutId: workout.id,
        name: workout.name,
        kcal: kcal,
        duration: elapsedMinutes,
        completedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = _workout;

    if (_loading || workout == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFEEF3F8),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final color = parseColor(workout.color);

    return switch (_phase) {
      _Phase.done => _DoneView(
        workout: workout,
        color: color,
        totalSets: _totalSets,
      ),
      _Phase.rest => _RestView(
        workout: workout,
        color: color,
        secondsLeft: _secondsLeft,
        nextExerciseName: _nextExerciseName(workout),
        paused: _paused,
        onBack: () => Navigator.pop(context),
        onTogglePause: () => setState(() => _paused = !_paused),
        onSkip: _skipRest,
      ),
      _Phase.exercise => _ExerciseView(
        workout: workout,
        color: color,
        exercise: _currentExercise!,
        exerciseIndex: _exerciseIndex,
        setIndex: _setIndex,
        totalExercises: workout.exercises.length,
        progress: _progress,
        isLastSet:
            _setIndex + 1 >= _currentExercise!.sets &&
            _exerciseIndex >= workout.exercises.length - 1,
        onBack: () => Navigator.pop(context),
        onComplete: _completeSet,
      ),
    };
  }

  String _nextExerciseName(Workout workout) {
    final exercise = _currentExercise;
    if (exercise == null) return 'Done';
    final nextExerciseIndex = _setIndex + 1 >= exercise.sets
        ? _exerciseIndex + 1
        : _exerciseIndex;
    return workout.exercises.elementAtOrNull(nextExerciseIndex)?.name ?? 'Done';
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({
    required this.workout,
    required this.color,
    required this.totalSets,
  });

  final Workout workout;
  final Color color;
  final int totalSets;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_rounded, color: color, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Great job!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'You completed ${workout.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xDDFFFFFF), fontSize: 14),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DoneStat('${workout.exercises.length}', 'Exercises'),
                  const SizedBox(width: 24),
                  _DoneStat('$totalSets', 'Sets'),
                  const SizedBox(width: 24),
                  _DoneStat('${workout.kcal}', 'Kcal'),
                ],
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'Back to Workouts',
                  color: Colors.white,
                  textColor: color,
                  onPress: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      WorkoutPage.routeName,
                      ModalRoute.withName('/'),
                    );
                  },
                  testID: 'play-done-back',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RestView extends StatelessWidget {
  const _RestView({
    required this.workout,
    required this.color,
    required this.secondsLeft,
    required this.nextExerciseName,
    required this.paused,
    required this.onBack,
    required this.onTogglePause,
    required this.onSkip,
  });

  final Workout workout;
  final Color color;
  final int secondsLeft;
  final String nextExerciseName;
  final bool paused;
  final VoidCallback onBack;
  final VoidCallback onTogglePause;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: workout.name, onBack: onBack),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'REST',
                    style: TextStyle(
                      color: Color(0xCCFFFFFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3.5,
                    ),
                  ),
                  Text(
                    '${secondsLeft}s',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 104,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    'Next up: $nextExerciseName',
                    style: const TextStyle(
                      color: Color(0xDDFFFFFF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RestButton(
                        icon: paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        label: paused ? 'Resume' : 'Pause',
                        onTap: onTogglePause,
                      ),
                      const SizedBox(width: 12),
                      _RestButton(
                        icon: Icons.chevron_right_rounded,
                        label: 'Skip Rest',
                        onTap: onSkip,
                        color: Colors.white,
                        textColor: color,
                      ),
                    ],
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

class _ExerciseView extends StatelessWidget {
  const _ExerciseView({
    required this.workout,
    required this.color,
    required this.exercise,
    required this.exerciseIndex,
    required this.setIndex,
    required this.totalExercises,
    required this.progress,
    required this.isLastSet,
    required this.onBack,
    required this.onComplete,
  });

  final Workout workout;
  final Color color;
  final Exercise exercise;
  final int exerciseIndex;
  final int setIndex;
  final int totalExercises;
  final double progress;
  final bool isLastSet;
  final VoidCallback onBack;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final steps = (exercise.cue ?? '')
        .split(RegExp(r'(?<=[.!?])\s+'))
        .map((step) => step.trim())
        .where((step) => step.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: workout.name, onBack: onBack),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressBar(
                    value: progress,
                    color: Colors.white,
                    trackColor: Colors.white.withValues(alpha: 0.25),
                    height: 6,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Exercise ${exerciseIndex + 1} of $totalExercises  ·  Set ${setIndex + 1} of ${exercise.sets}',
                    style: const TextStyle(
                      color: Color(0xDDFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '#${exerciseIndex + 1}',
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      exercise.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 36,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${exercise.reps}',
                            style: TextStyle(
                              color: color,
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Text(
                            'REPS',
                            style: TextStyle(
                              color: Color(0xFF4B5563),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (steps.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6FA),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'STEP-BY-STEP',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            for (var i = 0; i < steps.length; i += 1)
                              _StepRow(index: i, text: steps[i], color: color),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: isLastSet ? 'Finish Workout' : 'Complete Set',
                  color: Colors.white,
                  textColor: color,
                  icon: Icon(Icons.check_rounded, color: color),
                  onPress: onComplete,
                  testID: 'play-complete-set',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBack});

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
            onPressed: onBack,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.22),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _RestButton extends StatelessWidget {
  const _RestButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor = Colors.white,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        decoration: BoxDecoration(
          color: color ?? Colors.white.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneStat extends StatelessWidget {
  const _DoneStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Color(0xCCFFFFFF),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.index,
    required this.text,
    required this.color,
  });

  final int index;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
