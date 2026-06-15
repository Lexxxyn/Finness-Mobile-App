import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/app_language.dart';
import 'firebase_options.dart';
import 'features/auth/pages/auth_layout.dart';
import 'features/auth/pages/login_page.dart';
import 'features/meal/pages/meal_edit_page.dart';
import 'features/meal/pages/meal_library_page.dart';
import 'features/meal/pages/meal_page.dart';
import 'features/meal/pages/meal_type_page.dart';
import 'features/navigation/main_shell.dart';
import 'features/profile/profile_page.dart';
import 'features/profile/profile_edit_page.dart';
import 'features/meal/pages/recipe_create_page.dart';
import 'features/sleep/sleep_page.dart';
import 'features/summary/calories_page.dart';
import 'features/summary/nutrition_page.dart';
import 'features/workout/pages/workout_detail_page.dart';
import 'features/workout/pages/workout_edit_page.dart';
import 'features/workout/pages/workout_page.dart';
import 'features/workout/pages/workout_play.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error, stackTrace) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Firebase initialization failed:\n\n$error',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
    debugPrint('$error\n$stackTrace');
    return;
  }

  final user = FirebaseAuth.instance.currentUser;
  await authService.handleAuthState(user);

  final initialRoute = user == null ? LoginPage.routeName : '/';

  final languageController = AppLanguageController();
  await languageController.load();

  runApp(
    AppLanguageScope(
      controller: languageController,
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.initialRoute = LoginPage.routeName});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final languageController = AppLanguageScope.controllerOf(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: languageController.value,
      supportedLocales: const [Locale('en'), Locale('id')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: initialRoute,
      routes: {
        ...AuthLayout.routes(homeBuilder: (_) => const MainShell()),
        WorkoutPage.routeName: (_) => const MainShell(initialIndex: 1),
        MealPage.routeName: (_) => const MainShell(initialIndex: 2),
        MealLibraryPage.routeName: (_) => const MealLibraryPage(),
        RecipeCreatePage.routeName: (_) => const RecipeCreatePage(),
        SleepPage.routeName: (_) => const MainShell(initialIndex: 3),
        ProfilePage.routeName: (_) => const MainShell(initialIndex: 4),
        ProfileEditPage.routeName: (_) => const ProfileEditPage(),
        CaloriesPage.routeName: (_) => const CaloriesPage(),
        NutritionPage.routeName: (_) => const NutritionPage(),
      },
      onGenerateRoute: _onGenerateRoute,
    );
  }
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  final name = settings.name ?? '';

  if (name.startsWith(WorkoutEditPage.routePrefix)) {
    final id = name.substring(WorkoutEditPage.routePrefix.length);
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => WorkoutEditPage(workoutId: id),
    );
  }

  if (name.startsWith(WorkoutPlayPage.routePrefix)) {
    final id = name.substring(WorkoutPlayPage.routePrefix.length);
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => WorkoutPlayPage(workoutId: id),
    );
  }

  if (name.startsWith(WorkoutDetailPage.routePrefix)) {
    final id = name.substring(WorkoutDetailPage.routePrefix.length);
    if (id.isNotEmpty && !id.contains('/')) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => WorkoutDetailPage(workoutId: id),
      );
    }
  }

  if (name.startsWith(MealEditPage.routePrefix)) {
    final type = name.substring(MealEditPage.routePrefix.length);
    if (type.isNotEmpty && !type.contains('/')) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => MealEditPage(mealType: type),
      );
    }
  }

  if (name.startsWith(MealTypePage.routePrefix)) {
    final type = name.substring(MealTypePage.routePrefix.length);
    if (type.isNotEmpty && !type.contains('/')) {
      return MaterialPageRoute(
        settings: settings,
        builder: (_) => MealTypePage(mealIdentifier: type),
      );
    }
  }

  return null;
}
