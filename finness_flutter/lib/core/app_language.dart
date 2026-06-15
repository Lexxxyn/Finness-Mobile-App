import 'package:flutter/material.dart';

import '../services/cache_helpers.dart'
    if (dart.library.html) '../services/cache_helpers_web.dart';

const _languageCacheKey = 'finnness:language';

class AppLanguageController extends ValueNotifier<Locale> {
  AppLanguageController() : super(const Locale('en'));

  Future<void> load() async {
    final cache = await readCache();
    final code = cache[_languageCacheKey] as String?;
    if (code == 'id') {
      value = const Locale('id');
    }
  }

  Future<void> setLanguage(Locale locale) async {
    final next = locale.languageCode == 'id'
        ? const Locale('id')
        : const Locale('en');
    if (value == next) return;

    value = next;
    final cache = await readCache();
    cache[_languageCacheKey] = next.languageCode;
    await writeCache(cache);
  }
}

class AppLanguageScope extends InheritedNotifier<AppLanguageController> {
  const AppLanguageScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLanguageController controllerOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppLanguageScope>();
    return scope!.notifier!;
  }

  static AppText textOf(BuildContext context) {
    final locale = controllerOf(context).value;
    return AppText(locale.languageCode == 'id' ? 'id' : 'en');
  }
}

extension AppTextExtension on BuildContext {
  AppText get t => AppLanguageScope.textOf(this);
}

class AppText {
  const AppText(this.languageCode);

  final String languageCode;

  bool get isIndonesian => languageCode == 'id';

  String tr(String key) {
    return (_strings[languageCode] ?? _strings['en']!)[key] ??
        _strings['en']![key] ??
        key;
  }
}

const _strings = {
  'en': {
    'app.dashboard': 'Dashboard',
    'app.profile': 'Profile',
    'app.workout': 'Workout',
    'app.meals': 'Meals',
    'app.sleep': 'Sleep',
    'app.home': 'Home',
    'app.logout': 'Logout',
    'app.edit': 'Edit',
    'app.back': 'Back',
    'app.language': 'Language',
    'app.english': 'English',
    'app.indonesian': 'Indonesian',
    'dashboard.goodMorning': 'Good Morning',
    'dashboard.goodAfternoon': 'Good Afternoon',
    'dashboard.goodEvening': 'Good Evening',
    'dashboard.friend': 'Friend',
    'dashboard.hi': 'Hi, {name}',
    'dashboard.caloriesBurned': 'Calories Burned',
    'dashboard.nutrition': 'Nutrition',
    'dashboard.sleep': 'Sleep',
    'dashboard.todayWorkouts': '{count} {workout} today',
    'dashboard.workout': 'workout',
    'dashboard.workouts': 'workouts',
    'dashboard.tapWorkouts': 'Tap to see workouts',
    'dashboard.tapMeals': 'Tap to log meals',
    'dashboard.mealsEaten': '{count} {meal} eaten',
    'dashboard.meal': 'meal',
    'dashboard.meals': 'meals',
    'dashboard.lastNight': 'Last night',
    'dashboard.dailyProgress': 'Daily Progress',
    'dashboard.workoutGoal': 'Workout Goal',
    'dashboard.mealsLogged': 'Meals Logged',
    'dashboard.sleepQuality': 'Sleep Quality',
    'dashboard.startWorkout': 'Start Workout',
    'dashboard.logMeal': 'Log Meal',
    'profile.manage': 'Manage your account',
    'profile.gender': 'Gender',
    'profile.goal': 'Goal',
    'profile.dob': 'Date of Birth',
    'profile.height': 'Height',
    'profile.weight': 'Weight',
    'profile.equipment': 'Equipment',
    'goal.lose_weight': 'Lose weight',
    'goal.build_muscle': 'Build muscle',
    'goal.increase_weight': 'Increase weight',
    'goal.maintain_muscle': 'Maintain muscle',
    'goal.improve_fitness': 'Improve fitness',
    'goal.maintain': 'Maintain health',
    'summary.completedToday': 'Completed Today',
    'summary.kcalToday': 'kcal today',
    'summary.kcalEaten': 'kcal eaten',
    'summary.noWorkouts': 'No workouts yet today.',
    'summary.startWorkout': 'Start a Workout',
    'summary.mealsEaten': 'Meals Eaten',
    'summary.noMeals':
        'No meals checked off yet. Open the Meals tab to mark them as eaten.',
    'summary.protein': 'Protein',
    'summary.carbs': 'Carbs',
    'summary.fat': 'Fat',
    'summary.goal': 'Goal',
    'time.justNow': 'Just now',
  },
  'id': {
    'app.dashboard': 'Dasbor',
    'app.profile': 'Profil',
    'app.workout': 'Latihan',
    'app.meals': 'Makanan',
    'app.sleep': 'Tidur',
    'app.home': 'Beranda',
    'app.logout': 'Keluar',
    'app.edit': 'Ubah',
    'app.back': 'Kembali',
    'app.language': 'Bahasa',
    'app.english': 'Inggris',
    'app.indonesian': 'Indonesia',
    'dashboard.goodMorning': 'Selamat Pagi',
    'dashboard.goodAfternoon': 'Selamat Siang',
    'dashboard.goodEvening': 'Selamat Malam',
    'dashboard.friend': 'Teman',
    'dashboard.hi': 'Hai, {name}',
    'dashboard.caloriesBurned': 'Kalori Terbakar',
    'dashboard.nutrition': 'Nutrisi',
    'dashboard.sleep': 'Tidur',
    'dashboard.todayWorkouts': '{count} {workout} hari ini',
    'dashboard.workout': 'latihan',
    'dashboard.workouts': 'latihan',
    'dashboard.tapWorkouts': 'Ketuk untuk melihat latihan',
    'dashboard.tapMeals': 'Ketuk untuk catat makanan',
    'dashboard.mealsEaten': '{count} {meal} dimakan',
    'dashboard.meal': 'makanan',
    'dashboard.meals': 'makanan',
    'dashboard.lastNight': 'Tadi malam',
    'dashboard.dailyProgress': 'Progress Harian',
    'dashboard.workoutGoal': 'Target Latihan',
    'dashboard.mealsLogged': 'Makanan Dicatat',
    'dashboard.sleepQuality': 'Kualitas Tidur',
    'dashboard.startWorkout': 'Mulai Latihan',
    'dashboard.logMeal': 'Catat Makanan',
    'profile.manage': 'Kelola akun Anda',
    'profile.gender': 'Jenis Kelamin',
    'profile.goal': 'Tujuan',
    'profile.dob': 'Tanggal Lahir',
    'profile.height': 'Tinggi',
    'profile.weight': 'Berat',
    'profile.equipment': 'Peralatan',
    'goal.lose_weight': 'Turunkan berat badan',
    'goal.build_muscle': 'Bangun otot',
    'goal.increase_weight': 'Naikkan berat badan',
    'goal.maintain_muscle': 'Pertahankan otot',
    'goal.improve_fitness': 'Tingkatkan kebugaran',
    'goal.maintain': 'Jaga kesehatan',
    'summary.completedToday': 'Selesai Hari Ini',
    'summary.kcalToday': 'kcal hari ini',
    'summary.kcalEaten': 'kcal dimakan',
    'summary.noWorkouts': 'Belum ada latihan hari ini.',
    'summary.startWorkout': 'Mulai Latihan',
    'summary.mealsEaten': 'Makanan Dimakan',
    'summary.noMeals':
        'Belum ada makanan yang dicentang. Buka tab Makanan untuk menandainya.',
    'summary.protein': 'Protein',
    'summary.carbs': 'Karbo',
    'summary.fat': 'Lemak',
    'summary.goal': 'Target',
    'time.justNow': 'Baru saja',
  },
};
