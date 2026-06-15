import 'package:flutter/material.dart';

import '../../../models/models.dart';
import '../../../services/auth_service.dart';
import '../../../services/workout_service.dart';
import '../../../widgets/primary_button.dart';

const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _textPrimaryColor = Color(0xFF1F2937);
const _textSecondaryColor = Color(0xFF4B5563);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _inputColor = Color(0xFFF3F6FA);
const _primaryColor = Color(0xFF42C8F5);
const _dangerColor = Color(0xFFE05C5C);

class WorkoutEditPage extends StatefulWidget {
  static const routePrefix = '/workout/edit/';

  const WorkoutEditPage({super.key, required this.workoutId});

  final String workoutId;

  static String routeFor(String workoutId) => '$routePrefix$workoutId';

  @override
  State<WorkoutEditPage> createState() => _WorkoutEditPageState();
}

class _WorkoutEditPageState extends State<WorkoutEditPage> {
  final _service = WorkoutService();

  Workout? _workout;
  bool _loading = true;
  bool _saving = false;
  String? _error;

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

  void _setWorkout(Workout workout) {
    setState(() {
      _workout = workout;
      _error = null;
    });
  }

  void _setExercise(int index, Exercise exercise) {
    final workout = _workout;
    if (workout == null) return;
    final list = [...workout.exercises];
    list[index] = exercise;
    _setWorkout(_copyWorkout(workout, exercises: list));
  }

  void _addExercise() {
    final workout = _workout;
    if (workout == null) return;
    _setWorkout(
      _copyWorkout(
        workout,
        exercises: [
          ...workout.exercises,
          Exercise(
            id: 'ex-${DateTime.now().millisecondsSinceEpoch}',
            name: '',
            sets: 3,
            reps: 10,
          ),
        ],
      ),
    );
  }

  void _removeExercise(int index) {
    final workout = _workout;
    if (workout == null) return;
    _setWorkout(
      _copyWorkout(
        workout,
        exercises: [
          for (var i = 0; i < workout.exercises.length; i += 1)
            if (i != index) workout.exercises[i],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final user = authService.currentUser;
    final workout = _workout;
    if (user == null || workout == null) return;

    if (workout.name.trim().isEmpty) {
      setState(() => _error = 'Workout name is required.');
      return;
    }
    if (workout.exercises.isEmpty) {
      setState(() => _error = 'Add at least one exercise.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.saveWorkout(user.uid, workout);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final workout = _workout;

    if (_loading || workout == null) {
      return const Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textPrimaryColor,
        title: const Text('Edit Workout'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TextField(
                  label: 'Workout Name',
                  value: workout.name,
                  onChanged: (value) =>
                      _setWorkout(_copyWorkout(workout, name: value)),
                ),
                _TextField(
                  label: 'Duration (min)',
                  value: '${workout.duration}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _setWorkout(
                    _copyWorkout(workout, duration: int.tryParse(value) ?? 0),
                  ),
                ),
                _TextField(
                  label: 'Calories (kcal)',
                  value: '${workout.kcal}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _setWorkout(
                    _copyWorkout(workout, kcal: int.tryParse(value) ?? 0),
                  ),
                ),
                const Text(
                  'Difficulty',
                  style: TextStyle(
                    color: _textSecondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (final difficulty in const [
                      difficultyBeginner,
                      difficultyIntermediate,
                      difficultyAdvanced,
                    ]) ...[
                      Expanded(
                        child: _ChoiceChipButton(
                          label: difficulty,
                          selected: workout.difficulty == difficulty,
                          onTap: () => _setWorkout(
                            _copyWorkout(workout, difficulty: difficulty),
                          ),
                        ),
                      ),
                      if (difficulty != difficultyAdvanced)
                        const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                _TextField(
                  label: 'Description',
                  value: workout.description,
                  maxLines: 4,
                  onChanged: (value) =>
                      _setWorkout(_copyWorkout(workout, description: value)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Exercises',
                      style: TextStyle(
                        color: _textPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addExercise,
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add'),
                    ),
                  ],
                ),
                for (var i = 0; i < workout.exercises.length; i += 1)
                  _ExerciseEditor(
                    index: i,
                    exercise: workout.exercises[i],
                    onChanged: (exercise) => _setExercise(i, exercise),
                    onDelete: () => _removeExercise(i),
                  ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: _dangerColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 18),
          PrimaryButton(
            label: 'Save Changes',
            loading: _saving,
            onPress: _save,
            testID: 'edit-workout-save',
          ),
        ],
      ),
    );
  }
}

class _ExerciseEditor extends StatelessWidget {
  const _ExerciseEditor({
    required this.index,
    required this.exercise,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final Exercise exercise;
  final ValueChanged<Exercise> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12),
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${index + 1}',
                style: const TextStyle(
                  color: _textTertiaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: _dangerColor,
                tooltip: 'Delete exercise',
              ),
            ],
          ),
          _TextField(
            label: 'Name',
            value: exercise.name,
            onChanged: (value) =>
                onChanged(_copyExercise(exercise, name: value)),
          ),
          Row(
            children: [
              Expanded(
                child: _TextField(
                  label: 'Sets',
                  value: '${exercise.sets}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => onChanged(
                    _copyExercise(exercise, sets: int.tryParse(value) ?? 0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _TextField(
                  label: 'Reps',
                  value: '${exercise.reps}',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => onChanged(
                    _copyExercise(exercise, reps: int.tryParse(value) ?? 0),
                  ),
                ),
              ),
            ],
          ),
          _TextField(
            label: 'Rest Seconds',
            value: '${exercise.restSeconds ?? 30}',
            keyboardType: TextInputType.number,
            onChanged: (value) => onChanged(
              _copyExercise(exercise, restSeconds: int.tryParse(value) ?? 0),
            ),
          ),
          _TextField(
            label: 'Cue',
            value: exercise.cue ?? '',
            maxLines: 3,
            onChanged: (value) => onChanged(
              _copyExercise(exercise, cue: value.trim().isEmpty ? null : value),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatefulWidget {
  const _TextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  State<_TextField> createState() => _TextFieldState();
}

class _TextFieldState extends State<_TextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant _TextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _controller,
        keyboardType: widget.keyboardType,
        maxLines: widget.maxLines,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          labelText: widget.label,
          filled: true,
          fillColor: _inputColor,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _primaryColor : _inputColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _primaryColor : _borderColor),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _textSecondaryColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
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
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: _textPrimaryColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

Workout _copyWorkout(
  Workout workout, {
  String? name,
  int? duration,
  int? kcal,
  String? difficulty,
  String? description,
  List<Exercise>? exercises,
}) {
  return Workout(
    id: workout.id,
    name: name ?? workout.name,
    duration: duration ?? workout.duration,
    kcal: kcal ?? workout.kcal,
    difficulty: difficulty ?? workout.difficulty,
    description: description ?? workout.description,
    color: workout.color,
    exercises: exercises ?? workout.exercises,
    equipment: workout.equipment,
    tags: workout.tags,
  );
}

Exercise _copyExercise(
  Exercise exercise, {
  String? name,
  int? sets,
  int? reps,
  int? restSeconds,
  String? cue,
}) {
  return Exercise(
    id: exercise.id,
    name: name ?? exercise.name,
    sets: sets ?? exercise.sets,
    reps: reps ?? exercise.reps,
    restSeconds: restSeconds ?? exercise.restSeconds,
    cue: cue ?? exercise.cue,
  );
}
