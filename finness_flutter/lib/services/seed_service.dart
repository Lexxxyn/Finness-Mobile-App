import 'dart:math';

import '../models/models.dart' hide asStringMap;
import 'firebase_service.dart';

const seedVersion = 4;

class SeedService {
  SeedService({FirebaseService? firebaseService, Random? random})
    : _firebase = firebaseService ?? FirebaseService.instance,
      _random = random ?? Random();

  final FirebaseService _firebase;
  final Random _random;

  Future<void> seedUserIfEmpty(String uid) async {
    try {
      final existing = asStringMap(
        await _firebase.getValue('finnness/users/$uid'),
      );
      final meta = asStringMap(existing['_meta']);
      final currentVersion = asInt(meta['workouts_version']);
      final needsWorkoutSeed =
          existing['workouts'] == null || currentVersion < seedVersion;

      if (needsWorkoutSeed) {
        final workoutMap = <String, Object?>{};
        for (final workout in seedWorkouts) {
          workoutMap[workout.id] = workout.toJson();
        }
        await _firebase.setValue('finnness/users/$uid/workouts', workoutMap);
        await _firebase.setValue(
          'finnness/users/$uid/_meta/workouts_version',
          seedVersion,
        );
      }

      final today = _dateString(DateTime.now());
      final meals = asStringMap(existing['meals']);
      if (meals[today] == null) {
        final profile = asStringMap(existing['profile']);
        final goal = asString(profile['goal'], fallback: fitnessGoalMaintain);
        final mealMap = <String, Object?>{};
        for (final meal in defaultMealsForDate(today, goal: goal)) {
          mealMap[meal.type] = meal.toJson();
        }
        await _firebase.setValue('finnness/users/$uid/meals/$today', mealMap);
      }

      if (existing['sleep'] == null) {
        final sleepMap = <String, Object?>{};
        for (var i = 0; i < 7; i += 1) {
          final date = _dateString(DateTime.now().subtract(Duration(days: i)));
          final base = defaultSleep(date);
          final jitter = (_random.nextDouble() - 0.5) * 1.2;
          sleepMap[date] = Sleep(
            id: base.id,
            date: base.date,
            bedtime: base.bedtime,
            wakeup: base.wakeup,
            totalHours: (7.5 + jitter).clamp(5.5, 9).toDouble(),
            deepSleep: base.deepSleep,
            lightSleep: base.lightSleep,
            remSleep: base.remSleep,
          ).toJson();
        }
        await _firebase.setValue('finnness/users/$uid/sleep', sleepMap);
      }
    } catch (_) {
      // Seeding should never block auth or app startup.
    }
  }
}

String _dateString(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

const seedWorkouts = [
  Workout(
    id: 'w-yoga',
    name: 'Morning Yoga',
    duration: 30,
    kcal: 150,
    difficulty: difficultyBeginner,
    description:
        'Start your day with mindful flow and gentle stretches to awaken your body and calm your mind.',
    color: '#A17FD4',
    equipment: ['yoga_mat', 'bodyweight'],
    tags: ['flexibility', 'mindfulness', 'morning'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Sun Salutation',
        sets: 3,
        reps: 5,
        restSeconds: 30,
        cue:
            'Flow from standing to forward fold, lunge, downward dog, and back.',
      ),
      Exercise(
        id: 'e2',
        name: 'Downward Dog Flow',
        sets: 3,
        reps: 8,
        restSeconds: 30,
        cue: 'Press hips up and back, lengthen the spine, and pedal the heels.',
      ),
      Exercise(
        id: 'e3',
        name: 'Warrior II',
        sets: 2,
        reps: 10,
        restSeconds: 30,
        cue:
            'Bend the front knee over the ankle and reach strongly through both arms.',
      ),
      Exercise(
        id: 'e4',
        name: "Child's Pose",
        sets: 1,
        reps: 5,
        restSeconds: 0,
        cue: 'Sit hips to heels, stretch arms forward, and breathe slowly.',
      ),
    ],
  ),
  Workout(
    id: 'w-hiit',
    name: 'HIIT Training',
    duration: 20,
    kcal: 280,
    difficulty: difficultyAdvanced,
    description:
        'High intensity interval training to torch calories and boost endurance in a short, intense burst.',
    color: '#F07070',
    equipment: ['bodyweight'],
    tags: ['cardio', 'fat-burn', 'endurance'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Burpees',
        sets: 4,
        reps: 12,
        restSeconds: 30,
        cue: 'Drop to plank, lower the chest, return to standing, and jump.',
      ),
      Exercise(
        id: 'e2',
        name: 'Mountain Climbers',
        sets: 4,
        reps: 20,
        restSeconds: 30,
        cue:
            'Drive alternating knees toward the chest while holding a strong plank.',
      ),
      Exercise(
        id: 'e3',
        name: 'Jump Squats',
        sets: 4,
        reps: 15,
        restSeconds: 45,
        cue: 'Squat, jump explosively, and land softly into the next rep.',
      ),
      Exercise(
        id: 'e4',
        name: 'Plank to Push-up',
        sets: 3,
        reps: 10,
        restSeconds: 45,
        cue:
            'Move between forearm plank and high plank without rocking the hips.',
      ),
    ],
  ),
  Workout(
    id: 'w-run',
    name: 'Evening Run',
    duration: 45,
    kcal: 420,
    difficulty: difficultyIntermediate,
    description:
        'A steady-paced outdoor run to build cardiovascular endurance and clear your head after a long day.',
    color: '#42C8F5',
    equipment: ['bodyweight', 'treadmill'],
    tags: ['cardio', 'endurance', 'outdoor'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Warm-up Walk',
        sets: 1,
        reps: 5,
        restSeconds: 0,
        cue: 'Walk briskly and loosen your hips and shoulders.',
      ),
      Exercise(
        id: 'e2',
        name: 'Easy Jog',
        sets: 1,
        reps: 10,
        restSeconds: 0,
        cue: 'Jog at a conversational pace with relaxed shoulders.',
      ),
      Exercise(
        id: 'e3',
        name: 'Tempo Run',
        sets: 1,
        reps: 25,
        restSeconds: 0,
        cue: 'Hold a comfortably hard pace with steady breathing.',
      ),
      Exercise(
        id: 'e4',
        name: 'Cool Down Walk',
        sets: 1,
        reps: 5,
        restSeconds: 0,
        cue: 'Slow to a walk and let your heart rate settle.',
      ),
    ],
  ),
  Workout(
    id: 'w-strength',
    name: 'Strength Training',
    duration: 40,
    kcal: 320,
    difficulty: difficultyIntermediate,
    description:
        'Compound lifts and accessory work to build lean muscle and functional strength.',
    color: '#F5A742',
    equipment: ['dumbbells', 'barbell'],
    tags: ['strength', 'muscle', 'gym'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Squats',
        sets: 4,
        reps: 10,
        restSeconds: 90,
        cue:
            'Brace your core, sit hips back and down, then drive up through mid-foot.',
      ),
      Exercise(
        id: 'e2',
        name: 'Bench Press',
        sets: 4,
        reps: 8,
        restSeconds: 90,
        cue: 'Pin shoulder blades, lower with control, then press straight up.',
      ),
      Exercise(
        id: 'e3',
        name: 'Deadlifts',
        sets: 3,
        reps: 6,
        restSeconds: 120,
        cue: 'Hinge, brace, keep a neutral spine, and push the floor away.',
      ),
      Exercise(
        id: 'e4',
        name: 'Pull-ups',
        sets: 3,
        reps: 8,
        restSeconds: 75,
        cue: 'Pull elbows down and bring the chest toward the bar.',
      ),
    ],
  ),
  Workout(
    id: 'w-pilates',
    name: 'Pilates',
    duration: 35,
    kcal: 200,
    difficulty: difficultyBeginner,
    description:
        'Core-focused mat work emphasizing control, breath, and posture for a strong and stable centre.',
    color: '#5CBF7A',
    equipment: ['yoga_mat', 'bodyweight'],
    tags: ['core', 'stability', 'low-impact'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Hundred',
        sets: 1,
        reps: 10,
        restSeconds: 20,
        cue:
            'Curl up, extend the arms, and pump them while breathing in sets of five.',
      ),
      Exercise(
        id: 'e2',
        name: 'Roll Up',
        sets: 2,
        reps: 8,
        restSeconds: 30,
        cue: 'Peel the spine up and lower back down with control.',
      ),
      Exercise(
        id: 'e3',
        name: 'Single Leg Stretch',
        sets: 2,
        reps: 12,
        restSeconds: 30,
        cue: 'Alternate legs smoothly while keeping the low back grounded.',
      ),
      Exercise(
        id: 'e4',
        name: 'Teaser',
        sets: 2,
        reps: 6,
        restSeconds: 45,
        cue: 'Balance in a V shape and lower slowly.',
      ),
    ],
  ),
  Workout(
    id: 'w-bands',
    name: 'Resistance Band Burn',
    duration: 25,
    kcal: 180,
    difficulty: difficultyBeginner,
    description:
        'Full-body activation using just a resistance band, perfect for travel or quick home sessions.',
    color: '#6BC4D8',
    equipment: ['resistance_bands'],
    tags: ['mobility', 'travel', 'full-body'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Banded Squats',
        sets: 3,
        reps: 15,
        restSeconds: 45,
        cue: 'Push knees out against the band and drive through your heels.',
      ),
      Exercise(
        id: 'e2',
        name: 'Banded Rows',
        sets: 3,
        reps: 12,
        restSeconds: 45,
        cue: 'Pull elbows back and squeeze the shoulder blades.',
      ),
      Exercise(
        id: 'e3',
        name: 'Banded Glute Bridge',
        sets: 3,
        reps: 15,
        restSeconds: 45,
        cue: 'Lift the hips and squeeze glutes hard at the top.',
      ),
      Exercise(
        id: 'e4',
        name: 'Banded Press',
        sets: 3,
        reps: 12,
        restSeconds: 45,
        cue: 'Press overhead while keeping ribs tucked.',
      ),
    ],
  ),
  Workout(
    id: 'w-kettlebell',
    name: 'Kettlebell Power',
    duration: 30,
    kcal: 340,
    difficulty: difficultyIntermediate,
    description:
        'Explosive ballistic moves to build power, grip, and conditioning with a single kettlebell.',
    color: '#E29C6A',
    equipment: ['kettlebell'],
    tags: ['power', 'conditioning', 'full-body'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Kettlebell Swing',
        sets: 5,
        reps: 15,
        restSeconds: 60,
        cue: 'Hinge, hike the bell back, then snap hips forward to float it.',
      ),
      Exercise(
        id: 'e2',
        name: 'Goblet Squat',
        sets: 4,
        reps: 10,
        restSeconds: 60,
        cue: 'Hold the bell at the chest and squat between the elbows.',
      ),
      Exercise(
        id: 'e3',
        name: 'Single-Arm Clean',
        sets: 3,
        reps: 8,
        restSeconds: 60,
        cue: 'Pull the bell close and catch softly in the rack position.',
      ),
      Exercise(
        id: 'e4',
        name: 'Turkish Get-up',
        sets: 2,
        reps: 3,
        restSeconds: 90,
        cue:
            'Stand up and return to the floor slowly with the bell locked out.',
      ),
    ],
  ),
  Workout(
    id: 'w-muscle-upper',
    name: 'Upper Body Muscle Builder',
    duration: 42,
    kcal: 330,
    difficulty: difficultyIntermediate,
    description:
        'Hypertrophy-focused upper-body work for chest, back, shoulders, and arms.',
    color: '#D94686',
    equipment: ['dumbbells', 'barbell', 'bodyweight'],
    tags: ['muscle', 'strength', 'hypertrophy', 'weight-gain'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Dumbbell Bench Press',
        sets: 4,
        reps: 10,
        restSeconds: 75,
        cue: 'Lower with control, pause briefly, then press strongly.',
      ),
      Exercise(
        id: 'e2',
        name: 'Bent-over Row',
        sets: 4,
        reps: 10,
        restSeconds: 75,
        cue: 'Hinge at the hips and pull elbows toward your ribs.',
      ),
      Exercise(
        id: 'e3',
        name: 'Shoulder Press',
        sets: 3,
        reps: 10,
        restSeconds: 60,
        cue: 'Brace your core and press overhead without leaning back.',
      ),
      Exercise(
        id: 'e4',
        name: 'Biceps Curl to Triceps Extension',
        sets: 3,
        reps: 12,
        restSeconds: 45,
        cue: 'Move smoothly and keep the upper arm stable.',
      ),
    ],
  ),
  Workout(
    id: 'w-lower-glutes',
    name: 'Lower Body Strength',
    duration: 38,
    kcal: 360,
    difficulty: difficultyIntermediate,
    description:
        'Leg and glute session built around progressive strength and muscle maintenance.',
    color: '#8B5CF6',
    equipment: ['dumbbells', 'barbell', 'bodyweight'],
    tags: ['strength', 'muscle', 'glutes', 'maintain-muscle'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Goblet Squat',
        sets: 4,
        reps: 12,
        restSeconds: 75,
        cue: 'Keep chest proud and sit between your knees.',
      ),
      Exercise(
        id: 'e2',
        name: 'Romanian Deadlift',
        sets: 4,
        reps: 10,
        restSeconds: 75,
        cue: 'Push hips back and feel tension through the hamstrings.',
      ),
      Exercise(
        id: 'e3',
        name: 'Reverse Lunge',
        sets: 3,
        reps: 10,
        restSeconds: 60,
        cue: 'Step back softly and drive up through the front heel.',
      ),
      Exercise(
        id: 'e4',
        name: 'Hip Thrust',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        cue: 'Tuck ribs down and squeeze glutes at the top.',
      ),
    ],
  ),
  Workout(
    id: 'w-fat-loss-circuit',
    name: 'Fat Loss Circuit',
    duration: 28,
    kcal: 390,
    difficulty: difficultyIntermediate,
    description:
        'Fast full-body circuit for calorie burn while keeping movement simple.',
    color: '#EF4444',
    equipment: ['bodyweight', 'jump_rope'],
    tags: ['fat-burn', 'cardio', 'conditioning', 'lose-weight'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Jump Rope',
        sets: 5,
        reps: 60,
        restSeconds: 30,
        cue: 'Stay tall and keep the jumps light.',
      ),
      Exercise(
        id: 'e2',
        name: 'Push-up',
        sets: 4,
        reps: 12,
        restSeconds: 30,
        cue: 'Keep a straight line from shoulders to heels.',
      ),
      Exercise(
        id: 'e3',
        name: 'Alternating Lunges',
        sets: 4,
        reps: 20,
        restSeconds: 30,
        cue: 'Step long enough that the front knee tracks over the ankle.',
      ),
      Exercise(
        id: 'e4',
        name: 'High Knees',
        sets: 4,
        reps: 30,
        restSeconds: 30,
        cue: 'Drive knees up and pump the arms.',
      ),
    ],
  ),
  Workout(
    id: 'w-health-mobility',
    name: 'Healthy Mobility Reset',
    duration: 24,
    kcal: 120,
    difficulty: difficultyBeginner,
    description:
        'Joint-friendly mobility and posture work for maintaining everyday health.',
    color: '#10B981',
    equipment: ['bodyweight', 'yoga_mat'],
    tags: ['mobility', 'maintain', 'low-impact', 'health'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Cat Cow',
        sets: 2,
        reps: 10,
        restSeconds: 15,
        cue: 'Move slowly through the spine with your breath.',
      ),
      Exercise(
        id: 'e2',
        name: 'World Greatest Stretch',
        sets: 2,
        reps: 6,
        restSeconds: 20,
        cue: 'Lunge, rotate toward the front leg, then switch sides.',
      ),
      Exercise(
        id: 'e3',
        name: 'Glute Bridge',
        sets: 3,
        reps: 12,
        restSeconds: 30,
        cue: 'Press through heels and lift hips without arching the back.',
      ),
      Exercise(
        id: 'e4',
        name: 'Dead Bug',
        sets: 3,
        reps: 10,
        restSeconds: 30,
        cue: 'Keep ribs down as opposite arm and leg extend.',
      ),
    ],
  ),
  Workout(
    id: 'w-fitness-endurance',
    name: 'Endurance Builder',
    duration: 36,
    kcal: 410,
    difficulty: difficultyIntermediate,
    description:
        'A mixed cardio session to improve stamina, pacing, and recovery.',
    color: '#0EA5E9',
    equipment: ['bodyweight', 'treadmill', 'stationary_bike'],
    tags: ['endurance', 'cardio', 'improve-fitness', 'conditioning'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Easy Warm-up',
        sets: 1,
        reps: 6,
        restSeconds: 0,
        cue: 'Move at a relaxed pace until breathing feels steady.',
      ),
      Exercise(
        id: 'e2',
        name: 'Moderate Intervals',
        sets: 6,
        reps: 2,
        restSeconds: 60,
        cue: 'Push to a strong but repeatable pace.',
      ),
      Exercise(
        id: 'e3',
        name: 'Steady Pace',
        sets: 1,
        reps: 12,
        restSeconds: 0,
        cue: 'Settle into a rhythm you can hold.',
      ),
      Exercise(
        id: 'e4',
        name: 'Cool Down',
        sets: 1,
        reps: 6,
        restSeconds: 0,
        cue: 'Slow gradually and breathe through the nose.',
      ),
    ],
  ),
  Workout(
    id: 'w-weight-gain-hypertrophy',
    name: 'Weight Gain Hypertrophy Split',
    duration: 45,
    kcal: 360,
    difficulty: difficultyIntermediate,
    description:
        'A muscle-building session with moderate reps and enough volume to support healthy weight gain.',
    color: '#C026D3',
    equipment: ['dumbbells', 'barbell'],
    tags: ['hypertrophy', 'muscle', 'weight-gain', 'strength'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Front Squat',
        sets: 4,
        reps: 8,
        restSeconds: 90,
        cue: 'Keep elbows high, brace, and drive up through the mid-foot.',
      ),
      Exercise(
        id: 'e2',
        name: 'Incline Dumbbell Press',
        sets: 4,
        reps: 10,
        restSeconds: 75,
        cue: 'Lower slowly and press up without shrugging the shoulders.',
      ),
      Exercise(
        id: 'e3',
        name: 'One-arm Dumbbell Row',
        sets: 4,
        reps: 10,
        restSeconds: 75,
        cue: 'Pull elbow toward the hip and pause at the top.',
      ),
      Exercise(
        id: 'e4',
        name: 'Walking Lunge',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        cue: 'Take controlled steps and keep the front knee stable.',
      ),
    ],
  ),
  Workout(
    id: 'w-maintain-muscle-fullbody',
    name: 'Maintain Muscle Full Body',
    duration: 34,
    kcal: 280,
    difficulty: difficultyIntermediate,
    description:
        'Efficient full-body strength maintenance for keeping muscle while staying fresh.',
    color: '#2563EB',
    equipment: ['bodyweight', 'dumbbells', 'resistance_bands'],
    tags: ['maintain-muscle', 'strength', 'muscle', 'full-body'],
    exercises: [
      Exercise(
        id: 'e1',
        name: 'Dumbbell Romanian Deadlift',
        sets: 3,
        reps: 10,
        restSeconds: 75,
        cue: 'Hinge back and keep tension through the hamstrings.',
      ),
      Exercise(
        id: 'e2',
        name: 'Push-up',
        sets: 3,
        reps: 12,
        restSeconds: 60,
        cue: 'Keep ribs tucked and press the floor away.',
      ),
      Exercise(
        id: 'e3',
        name: 'Band Row',
        sets: 3,
        reps: 14,
        restSeconds: 60,
        cue: 'Squeeze shoulder blades together without arching.',
      ),
      Exercise(
        id: 'e4',
        name: 'Split Squat',
        sets: 3,
        reps: 10,
        restSeconds: 60,
        cue: 'Lower straight down and drive through the front heel.',
      ),
    ],
  ),
];

List<Meal> defaultMealsForDate(String date, {FitnessGoal? goal}) {
  final templates = switch (goal) {
    fitnessGoalLoseWeight => _loseWeightMeals,
    fitnessGoalIncreaseWeight => _increaseWeightMeals,
    fitnessGoalMaintainMuscle => _maintainMuscleMeals,
    fitnessGoalBuildMuscle => _buildMuscleMeals,
    fitnessGoalImproveFitness => _improveFitnessMeals,
    fitnessGoalMaintain || _ => _maintainHealthMeals,
  };

  return [
    for (final template in templates)
      Meal(
        id: 'm-$date-${template.category}',
        date: date,
        type: template.category,
        foodName: template.name,
        time: _defaultTimeForMeal(template.category),
        calories: template.calories,
        protein: template.protein,
        carbs: template.carbs,
        fat: template.fat,
        ingredients: template.ingredients,
        notes: _goalMealNote(goal),
        eaten: false,
      ),
  ];
}

String _defaultTimeForMeal(MealType type) {
  switch (type) {
    case mealTypeBreakfast:
      return '8:00 AM';
    case mealTypeLunch:
      return '12:30 PM';
    case mealTypeSnack:
      return '3:00 PM';
    case mealTypeDinner:
      return '7:00 PM';
    default:
      return '12:00 PM';
  }
}

String _goalMealNote(FitnessGoal? goal) {
  switch (goal) {
    case fitnessGoalLoseWeight:
      return 'Indonesian meal plan tuned for a lighter calorie target.';
    case fitnessGoalBuildMuscle:
      return 'Indonesian meal plan tuned for weight gain and higher protein.';
    case fitnessGoalIncreaseWeight:
      return 'Indonesian meal plan tuned for a calorie surplus and steady weight gain.';
    case fitnessGoalMaintainMuscle:
      return 'Indonesian meal plan tuned for maintaining muscle with high protein.';
    case fitnessGoalImproveFitness:
      return 'Indonesian meal plan tuned for training energy and recovery.';
    case fitnessGoalMaintain:
    default:
      return 'Balanced Indonesian meal plan for maintaining daily health.';
  }
}

const _loseWeightMeals = [
  MealTemplate(
    id: 'plan-cut-breakfast',
    name: 'Bubur Ayam Oat Telur',
    category: mealTypeBreakfast,
    calories: 330,
    protein: 24,
    carbs: 38,
    fat: 9,
    ingredients: [
      'Oat 45g',
      'Dada ayam suwir 80g',
      'Telur rebus 1',
      'Daun bawang',
      'Kaldu rendah garam',
    ],
  ),
  MealTemplate(
    id: 'plan-cut-lunch',
    name: 'Gado-gado Ayam Tanpa Lontong',
    category: mealTypeLunch,
    calories: 460,
    protein: 36,
    carbs: 34,
    fat: 20,
    ingredients: [
      'Dada ayam 140g',
      'Sayur rebus 200g',
      'Tahu 60g',
      'Saus kacang 2 sdm',
      'Telur 1/2',
    ],
  ),
  MealTemplate(
    id: 'plan-cut-snack',
    name: 'Rujak Buah Yogurt',
    category: mealTypeSnack,
    calories: 180,
    protein: 10,
    carbs: 30,
    fat: 2,
    ingredients: [
      'Pepaya 100g',
      'Bengkuang 80g',
      'Nanas 60g',
      'Greek yogurt 100g',
      'Cabai bubuk sedikit',
    ],
  ),
  MealTemplate(
    id: 'plan-cut-dinner',
    name: 'Pepes Ikan Nasi Merah',
    category: mealTypeDinner,
    calories: 430,
    protein: 34,
    carbs: 45,
    fat: 12,
    ingredients: [
      'Ikan kembung 150g',
      'Nasi merah 120g',
      'Lalapan',
      'Tumis kangkung sedikit minyak',
      'Bumbu pepes',
    ],
  ),
];

const _buildMuscleMeals = [
  MealTemplate(
    id: 'plan-bulk-breakfast',
    name: 'Nasi Uduk Telur Tempe',
    category: mealTypeBreakfast,
    calories: 610,
    protein: 28,
    carbs: 78,
    fat: 22,
    ingredients: [
      'Nasi uduk 180g',
      'Telur dadar 2',
      'Tempe 80g',
      'Timun',
      'Sambal sedikit',
    ],
  ),
  MealTemplate(
    id: 'plan-bulk-lunch',
    name: 'Nasi Padang Ayam Bakar',
    category: mealTypeLunch,
    calories: 820,
    protein: 52,
    carbs: 92,
    fat: 28,
    ingredients: [
      'Nasi putih 220g',
      'Ayam bakar 180g',
      'Telur balado 1',
      'Daun singkong',
      'Kuah gulai sedikit',
    ],
  ),
  MealTemplate(
    id: 'plan-bulk-snack',
    name: 'Pisang Susu Kacang',
    category: mealTypeSnack,
    calories: 360,
    protein: 18,
    carbs: 52,
    fat: 10,
    ingredients: [
      'Pisang 2',
      'Susu tinggi protein 250ml',
      'Kacang tanah 20g',
      'Madu 1 sdt',
    ],
  ),
  MealTemplate(
    id: 'plan-bulk-dinner',
    name: 'Sate Ayam Lontong',
    category: mealTypeDinner,
    calories: 760,
    protein: 56,
    carbs: 84,
    fat: 20,
    ingredients: [
      'Sate ayam 12 tusuk',
      'Lontong 180g',
      'Saus kacang',
      'Acar timun',
      'Sayur bening',
    ],
  ),
];

const _increaseWeightMeals = [
  MealTemplate(
    id: 'plan-gain-breakfast',
    name: 'Bubur Manado Telur Tempe',
    category: mealTypeBreakfast,
    calories: 620,
    protein: 30,
    carbs: 86,
    fat: 18,
    ingredients: [
      'Bubur Manado 1 mangkuk besar',
      'Telur rebus 2',
      'Tempe goreng 70g',
      'Jagung manis',
      'Sambal roa sedikit',
    ],
  ),
  MealTemplate(
    id: 'plan-gain-lunch',
    name: 'Rawon Daging Nasi',
    category: mealTypeLunch,
    calories: 860,
    protein: 48,
    carbs: 96,
    fat: 32,
    ingredients: [
      'Nasi putih 240g',
      'Rawon daging 180g',
      'Telur asin 1/2',
      'Tauge pendek',
      'Kerupuk kecil',
    ],
  ),
  MealTemplate(
    id: 'plan-gain-snack',
    name: 'Martabak Telur Mini',
    category: mealTypeSnack,
    calories: 420,
    protein: 20,
    carbs: 38,
    fat: 22,
    ingredients: [
      'Martabak telur porsi kecil',
      'Acar timun',
      'Susu rendah lemak 200ml',
    ],
  ),
  MealTemplate(
    id: 'plan-gain-dinner',
    name: 'Nasi Ayam Taliwang',
    category: mealTypeDinner,
    calories: 820,
    protein: 58,
    carbs: 88,
    fat: 24,
    ingredients: [
      'Nasi putih 220g',
      'Ayam taliwang 180g',
      'Plecing kangkung',
      'Tahu bakar',
      'Sambal secukupnya',
    ],
  ),
];

const _maintainMuscleMeals = [
  MealTemplate(
    id: 'plan-maintain-muscle-breakfast',
    name: 'Ketoprak Telur Ekstra Tahu',
    category: mealTypeBreakfast,
    calories: 520,
    protein: 30,
    carbs: 58,
    fat: 18,
    ingredients: [
      'Ketoprak porsi sedang',
      'Telur rebus 2',
      'Tahu 100g',
      'Bumbu kacang sedang',
      'Kerupuk sedikit',
    ],
  ),
  MealTemplate(
    id: 'plan-maintain-muscle-lunch',
    name: 'Nasi Rames Ayam Tempe',
    category: mealTypeLunch,
    calories: 680,
    protein: 52,
    carbs: 72,
    fat: 20,
    ingredients: [
      'Nasi merah 170g',
      'Ayam panggang 170g',
      'Tempe bacem 70g',
      'Sayur lodeh ringan',
      'Lalapan',
    ],
  ),
  MealTemplate(
    id: 'plan-maintain-muscle-snack',
    name: 'Tahu Kukus Sambal Kecap',
    category: mealTypeSnack,
    calories: 260,
    protein: 22,
    carbs: 18,
    fat: 12,
    ingredients: [
      'Tahu kukus 180g',
      'Kecap manis 1 sdt',
      'Cabai rawit',
      'Tomat',
      'Jeruk limau',
    ],
  ),
  MealTemplate(
    id: 'plan-maintain-muscle-dinner',
    name: 'Sup Iga Lean Nasi Merah',
    category: mealTypeDinner,
    calories: 700,
    protein: 55,
    carbs: 66,
    fat: 24,
    ingredients: [
      'Sup iga daging lean 180g',
      'Nasi merah 160g',
      'Wortel dan kentang',
      'Tumis buncis',
      'Bawang goreng sedikit',
    ],
  ),
];

const _maintainHealthMeals = [
  MealTemplate(
    id: 'plan-maintain-breakfast',
    name: 'Nasi Kuning Telur Sayur',
    category: mealTypeBreakfast,
    calories: 470,
    protein: 22,
    carbs: 62,
    fat: 15,
    ingredients: [
      'Nasi kuning 150g',
      'Telur rebus 1',
      'Tempe orek 50g',
      'Timun',
      'Perkedel kecil 1',
    ],
  ),
  MealTemplate(
    id: 'plan-maintain-lunch',
    name: 'Soto Ayam Nasi',
    category: mealTypeLunch,
    calories: 560,
    protein: 36,
    carbs: 68,
    fat: 14,
    ingredients: [
      'Soto ayam 1 mangkuk',
      'Nasi putih 150g',
      'Telur 1/2',
      'Kol dan tauge',
      'Jeruk nipis',
    ],
  ),
  MealTemplate(
    id: 'plan-maintain-snack',
    name: 'Kacang Hijau Ringan',
    category: mealTypeSnack,
    calories: 240,
    protein: 11,
    carbs: 42,
    fat: 4,
    ingredients: [
      'Kacang hijau 120g',
      'Santan light 40ml',
      'Gula merah sedikit',
      'Jahe',
    ],
  ),
  MealTemplate(
    id: 'plan-maintain-dinner',
    name: 'Ayam Panggang Urap',
    category: mealTypeDinner,
    calories: 590,
    protein: 42,
    carbs: 58,
    fat: 20,
    ingredients: [
      'Ayam panggang 160g',
      'Nasi merah 150g',
      'Urap sayur',
      'Tahu kukus',
      'Sambal tomat',
    ],
  ),
];

const _improveFitnessMeals = [
  MealTemplate(
    id: 'plan-fit-breakfast',
    name: 'Lontong Sayur Telur',
    category: mealTypeBreakfast,
    calories: 520,
    protein: 24,
    carbs: 70,
    fat: 17,
    ingredients: [
      'Lontong 160g',
      'Telur rebus 1',
      'Sayur labu',
      'Tahu 60g',
      'Kuah santan ringan',
    ],
  ),
  MealTemplate(
    id: 'plan-fit-lunch',
    name: 'Nasi Pecel Ayam',
    category: mealTypeLunch,
    calories: 650,
    protein: 42,
    carbs: 78,
    fat: 18,
    ingredients: [
      'Nasi putih 170g',
      'Ayam panggang 150g',
      'Sayur pecel 180g',
      'Bumbu kacang 2 sdm',
      'Tempe 50g',
    ],
  ),
  MealTemplate(
    id: 'plan-fit-snack',
    name: 'Ubi Rebus Keju Susu',
    category: mealTypeSnack,
    calories: 280,
    protein: 12,
    carbs: 48,
    fat: 5,
    ingredients: [
      'Ubi rebus 180g',
      'Susu rendah lemak 180ml',
      'Keju parut 10g',
      'Kayu manis',
    ],
  ),
  MealTemplate(
    id: 'plan-fit-dinner',
    name: 'Ikan Bakar Nasi Merah',
    category: mealTypeDinner,
    calories: 620,
    protein: 46,
    carbs: 70,
    fat: 16,
    ingredients: [
      'Ikan nila bakar 180g',
      'Nasi merah 170g',
      'Sayur asem',
      'Lalapan',
      'Sambal kecap sedikit',
    ],
  ),
];

Sleep defaultSleep(String date) {
  return Sleep(
    id: 's-$date',
    date: date,
    bedtime: '10:30 PM',
    wakeup: '6:00 AM',
    totalHours: 7.5,
    deepSleep: 0.35,
    lightSleep: 0.5,
    remSleep: 0.15,
  );
}

class MealTemplate {
  const MealTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
  });

  final String id;
  final String name;
  final MealType category;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final List<String> ingredients;
}

const mealLibrary = [
  MealTemplate(
    id: 'lib-1',
    name: 'Avocado Toast & Egg',
    category: mealTypeBreakfast,
    calories: 380,
    protein: 18,
    carbs: 38,
    fat: 18,
    ingredients: [
      'Sourdough 60g',
      'Avocado 1/2',
      'Egg 1',
      'Chili flakes',
      'Olive oil',
    ],
  ),
  MealTemplate(
    id: 'lib-2',
    name: 'Protein Smoothie Bowl',
    category: mealTypeBreakfast,
    calories: 450,
    protein: 32,
    carbs: 50,
    fat: 10,
    ingredients: [
      'Frozen berries 150g',
      'Banana 1',
      'Whey 30g',
      'Almond milk 250ml',
      'Granola 20g',
    ],
  ),
  MealTemplate(
    id: 'lib-3',
    name: 'Quinoa Buddha Bowl',
    category: mealTypeLunch,
    calories: 590,
    protein: 24,
    carbs: 70,
    fat: 22,
    ingredients: [
      'Quinoa 90g',
      'Chickpeas 100g',
      'Roasted veg 150g',
      'Tahini 1 tbsp',
      'Lemon',
    ],
  ),
  MealTemplate(
    id: 'lib-4',
    name: 'Turkey Wrap',
    category: mealTypeLunch,
    calories: 520,
    protein: 38,
    carbs: 45,
    fat: 18,
    ingredients: [
      'Whole-wheat wrap',
      'Turkey 120g',
      'Hummus 2 tbsp',
      'Spinach',
      'Tomato',
    ],
  ),
  MealTemplate(
    id: 'lib-5',
    name: 'Almond Butter Apple',
    category: mealTypeSnack,
    calories: 220,
    protein: 6,
    carbs: 24,
    fat: 12,
    ingredients: ['Apple 1', 'Almond butter 1 tbsp'],
  ),
  MealTemplate(
    id: 'lib-6',
    name: 'Cottage Cheese & Berries',
    category: mealTypeSnack,
    calories: 180,
    protein: 18,
    carbs: 14,
    fat: 4,
    ingredients: ['Cottage cheese 150g', 'Blueberries 80g', 'Honey 1 tsp'],
  ),
  MealTemplate(
    id: 'lib-7',
    name: 'Steak & Sweet Potato',
    category: mealTypeDinner,
    calories: 720,
    protein: 52,
    carbs: 55,
    fat: 30,
    ingredients: [
      'Sirloin 180g',
      'Sweet potato 200g',
      'Asparagus 100g',
      'Olive oil',
    ],
  ),
  MealTemplate(
    id: 'lib-8',
    name: 'Tofu Stir-fry',
    category: mealTypeDinner,
    calories: 480,
    protein: 28,
    carbs: 48,
    fat: 18,
    ingredients: [
      'Firm tofu 180g',
      'Brown rice 80g',
      'Mixed veg 200g',
      'Soy sauce',
      'Sesame oil',
    ],
  ),
  MealTemplate(
    id: 'lib-id-1',
    name: 'Bubur Ayam Oat Telur',
    category: mealTypeBreakfast,
    calories: 330,
    protein: 24,
    carbs: 38,
    fat: 9,
    ingredients: [
      'Oat 45g',
      'Dada ayam suwir 80g',
      'Telur rebus 1',
      'Daun bawang',
      'Kaldu rendah garam',
    ],
  ),
  MealTemplate(
    id: 'lib-id-2',
    name: 'Nasi Uduk Telur Tempe',
    category: mealTypeBreakfast,
    calories: 610,
    protein: 28,
    carbs: 78,
    fat: 22,
    ingredients: [
      'Nasi uduk 180g',
      'Telur dadar 2',
      'Tempe 80g',
      'Timun',
      'Sambal sedikit',
    ],
  ),
  MealTemplate(
    id: 'lib-id-3',
    name: 'Lontong Sayur Telur',
    category: mealTypeBreakfast,
    calories: 520,
    protein: 24,
    carbs: 70,
    fat: 17,
    ingredients: [
      'Lontong 160g',
      'Telur rebus 1',
      'Sayur labu',
      'Tahu 60g',
      'Kuah santan ringan',
    ],
  ),
  MealTemplate(
    id: 'lib-id-4',
    name: 'Soto Ayam Nasi',
    category: mealTypeLunch,
    calories: 560,
    protein: 36,
    carbs: 68,
    fat: 14,
    ingredients: [
      'Soto ayam 1 mangkuk',
      'Nasi putih 150g',
      'Telur 1/2',
      'Kol dan tauge',
      'Jeruk nipis',
    ],
  ),
  MealTemplate(
    id: 'lib-id-5',
    name: 'Gado-gado Ayam',
    category: mealTypeLunch,
    calories: 510,
    protein: 38,
    carbs: 42,
    fat: 22,
    ingredients: [
      'Dada ayam 140g',
      'Sayur rebus 200g',
      'Tahu 60g',
      'Saus kacang',
      'Telur 1/2',
    ],
  ),
  MealTemplate(
    id: 'lib-id-6',
    name: 'Nasi Pecel Ayam',
    category: mealTypeLunch,
    calories: 650,
    protein: 42,
    carbs: 78,
    fat: 18,
    ingredients: [
      'Nasi putih 170g',
      'Ayam panggang 150g',
      'Sayur pecel 180g',
      'Bumbu kacang 2 sdm',
      'Tempe 50g',
    ],
  ),
  MealTemplate(
    id: 'lib-id-7',
    name: 'Nasi Padang Ayam Bakar',
    category: mealTypeLunch,
    calories: 820,
    protein: 52,
    carbs: 92,
    fat: 28,
    ingredients: [
      'Nasi putih 220g',
      'Ayam bakar 180g',
      'Telur balado 1',
      'Daun singkong',
      'Kuah gulai sedikit',
    ],
  ),
  MealTemplate(
    id: 'lib-id-8',
    name: 'Rujak Buah Yogurt',
    category: mealTypeSnack,
    calories: 180,
    protein: 10,
    carbs: 30,
    fat: 2,
    ingredients: [
      'Pepaya 100g',
      'Bengkuang 80g',
      'Nanas 60g',
      'Greek yogurt 100g',
      'Cabai bubuk sedikit',
    ],
  ),
  MealTemplate(
    id: 'lib-id-9',
    name: 'Kacang Hijau Ringan',
    category: mealTypeSnack,
    calories: 240,
    protein: 11,
    carbs: 42,
    fat: 4,
    ingredients: [
      'Kacang hijau 120g',
      'Santan light 40ml',
      'Gula merah sedikit',
      'Jahe',
    ],
  ),
  MealTemplate(
    id: 'lib-id-10',
    name: 'Pisang Susu Kacang',
    category: mealTypeSnack,
    calories: 360,
    protein: 18,
    carbs: 52,
    fat: 10,
    ingredients: [
      'Pisang 2',
      'Susu tinggi protein 250ml',
      'Kacang tanah 20g',
      'Madu 1 sdt',
    ],
  ),
  MealTemplate(
    id: 'lib-id-11',
    name: 'Pepes Ikan Nasi Merah',
    category: mealTypeDinner,
    calories: 430,
    protein: 34,
    carbs: 45,
    fat: 12,
    ingredients: [
      'Ikan kembung 150g',
      'Nasi merah 120g',
      'Lalapan',
      'Tumis kangkung sedikit minyak',
      'Bumbu pepes',
    ],
  ),
  MealTemplate(
    id: 'lib-id-12',
    name: 'Ayam Panggang Urap',
    category: mealTypeDinner,
    calories: 590,
    protein: 42,
    carbs: 58,
    fat: 20,
    ingredients: [
      'Ayam panggang 160g',
      'Nasi merah 150g',
      'Urap sayur',
      'Tahu kukus',
      'Sambal tomat',
    ],
  ),
  MealTemplate(
    id: 'lib-id-13',
    name: 'Ikan Bakar Nasi Merah',
    category: mealTypeDinner,
    calories: 620,
    protein: 46,
    carbs: 70,
    fat: 16,
    ingredients: [
      'Ikan nila bakar 180g',
      'Nasi merah 170g',
      'Sayur asem',
      'Lalapan',
      'Sambal kecap sedikit',
    ],
  ),
  MealTemplate(
    id: 'lib-id-14',
    name: 'Sate Ayam Lontong',
    category: mealTypeDinner,
    calories: 760,
    protein: 56,
    carbs: 84,
    fat: 20,
    ingredients: [
      'Sate ayam 12 tusuk',
      'Lontong 180g',
      'Saus kacang',
      'Acar timun',
      'Sayur bening',
    ],
  ),
  MealTemplate(
    id: 'lib-id-15',
    name: 'Rawon Daging Nasi',
    category: mealTypeLunch,
    calories: 860,
    protein: 48,
    carbs: 96,
    fat: 32,
    ingredients: [
      'Nasi putih 240g',
      'Rawon daging 180g',
      'Telur asin 1/2',
      'Tauge pendek',
      'Kerupuk kecil',
    ],
  ),
  MealTemplate(
    id: 'lib-id-16',
    name: 'Ketoprak Telur Ekstra Tahu',
    category: mealTypeBreakfast,
    calories: 520,
    protein: 30,
    carbs: 58,
    fat: 18,
    ingredients: [
      'Ketoprak porsi sedang',
      'Telur rebus 2',
      'Tahu 100g',
      'Bumbu kacang sedang',
      'Kerupuk sedikit',
    ],
  ),
  MealTemplate(
    id: 'lib-id-17',
    name: 'Nasi Ayam Taliwang',
    category: mealTypeDinner,
    calories: 820,
    protein: 58,
    carbs: 88,
    fat: 24,
    ingredients: [
      'Nasi putih 220g',
      'Ayam taliwang 180g',
      'Plecing kangkung',
      'Tahu bakar',
      'Sambal secukupnya',
    ],
  ),
  MealTemplate(
    id: 'lib-id-18',
    name: 'Tahu Kukus Sambal Kecap',
    category: mealTypeSnack,
    calories: 260,
    protein: 22,
    carbs: 18,
    fat: 12,
    ingredients: [
      'Tahu kukus 180g',
      'Kecap manis 1 sdt',
      'Cabai rawit',
      'Tomat',
      'Jeruk limau',
    ],
  ),
];

final seedService = SeedService();
