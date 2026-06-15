import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/seed_service.dart';
import '../../services/sleep_service.dart';
import '../../widgets/progress_bar.dart';

const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _sleepHeroColor = Color(0xFF7B7FD4);
const _textPrimaryColor = Color(0xFF1F2937);
const _textSecondaryColor = Color(0xFF4B5563);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _sunColor = Color(0xFFF5A742);

class SleepPage extends StatefulWidget {
  static const routeName = '/sleep';

  const SleepPage({super.key});

  @override
  State<SleepPage> createState() => _SleepPageState();
}

class _SleepPageState extends State<SleepPage> {
  final _service = SleepService();

  Map<String, Sleep> _data = const {};
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
    final all = await _service.fetchAllSleep(user.uid);
    if (!mounted) return;
    setState(() {
      _data = all ?? {_todayString(): defaultSleep(_todayString())};
      _loading = false;
    });
  }

  Sleep get _today {
    final today = _todayString();
    return _data[today] ?? defaultSleep(today);
  }

  double get _weeklyAverage {
    if (_data.isEmpty) return 7.2;
    final total = _data.values.fold<double>(
      0,
      (sum, item) => sum + item.totalHours,
    );
    return total / _data.length;
  }

  @override
  Widget build(BuildContext context) {
    final today = _today;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textPrimaryColor,
        title: const Text('Sleep Tracker'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  const Text(
                    'Monitor your sleep quality',
                    style: TextStyle(color: _textTertiaryColor, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  _HeroCard(sleep: today),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _TimeCard(
                          icon: Icons.wb_sunny_rounded,
                          label: 'Bedtime',
                          value: today.bedtime,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TimeCard(
                          icon: Icons.wb_twilight_rounded,
                          label: 'Wake Up',
                          value: today.wakeup,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _QualityCard(sleep: today),
                  const SizedBox(height: 14),
                  _WeeklyCard(average: _weeklyAverage),
                ],
              ),
            ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.sleep});

  final Sleep sleep;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sleep-hero-card'),
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(color: _sleepHeroColor, radius: 8),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.dark_mode_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'TOTAL SLEEP DURATION',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${sleep.totalHours.toStringAsFixed(1)} hours',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Last night',
            style: TextStyle(color: Color(0xCCFFFFFF), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE3CC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _sunColor),
          ),
          const SizedBox(height: 10),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: _textTertiaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: _textPrimaryColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  const _QualityCard({required this.sleep});

  final Sleep sleep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Sleep Quality',
                style: TextStyle(
                  color: _textPrimaryColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8E6FA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: _sleepHeroColor,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SleepStageRow(
            label: 'Deep Sleep',
            value: sleep.deepSleep,
            color: const Color(0xFF4F46E5),
          ),
          const SizedBox(height: 14),
          _SleepStageRow(
            label: 'Light Sleep',
            value: sleep.lightSleep,
            color: _sleepHeroColor,
          ),
          const SizedBox(height: 14),
          _SleepStageRow(
            label: 'REM Sleep',
            value: sleep.remSleep,
            color: const Color(0xFFA78BFA),
          ),
        ],
      ),
    );
  }
}

class _SleepStageRow extends StatelessWidget {
  const _SleepStageRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _textSecondaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(clamped * 100).round()}%',
              style: const TextStyle(
                color: _textPrimaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ProgressBar(value: clamped, color: color),
      ],
    );
  }
}

class _WeeklyCard extends StatelessWidget {
  const _WeeklyCard({required this.average});

  final double average;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('sleep-weekly-card'),
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(
        radius: 8,
        gradient: const LinearGradient(
          colors: [Color(0xFF9B7FD4), Color(0xFF7B7FD4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WEEKLY AVERAGE',
            style: TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${average.toStringAsFixed(1)} hours/night',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration({
  Color color = _cardColor,
  double radius = 8,
  Gradient? gradient,
}) {
  return BoxDecoration(
    color: gradient == null ? color : null,
    gradient: gradient,
    borderRadius: BorderRadius.circular(radius),
    border: gradient == null ? Border.all(color: _borderColor) : null,
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
