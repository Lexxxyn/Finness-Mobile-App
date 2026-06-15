import 'package:flutter/material.dart';

import '../../core/app_language.dart';
import '../dashboard/dashboard_page.dart';
import '../meal/pages/meal_page.dart';
import '../profile/profile_page.dart';
import '../sleep/sleep_page.dart';
import '../workout/pages/workout_page.dart';

const _activeColor = Color(0xFF2BBFA4);
const _inactiveColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);

class MainShell extends StatefulWidget {
  static const routeName = '/';

  const MainShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index;
  int _dashboardRefreshSignal = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, 4);
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _index = widget.initialIndex.clamp(0, 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          DashboardPage(refreshSignal: _dashboardRefreshSignal),
          const WorkoutPage(),
          const MealPage(),
          const SleepPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: _borderColor)),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: _index,
            onTap: (value) => setState(() {
              _index = value;
              if (value == 0) {
                _dashboardRefreshSignal += 1;
              }
            }),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: _activeColor,
            unselectedItemColor: _inactiveColor,
            selectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            elevation: 0,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_rounded),
                label: t.tr('app.home'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.fitness_center_rounded),
                label: t.tr('app.workout'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.restaurant_rounded),
                label: t.tr('app.meals'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.dark_mode_rounded),
                label: t.tr('app.sleep'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_rounded),
                label: t.tr('app.profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
