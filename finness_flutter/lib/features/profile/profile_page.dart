import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/app_language.dart';
import '../../services/auth_service.dart';
import '../auth/pages/auth_layout.dart';
import 'profile_edit_page.dart';

const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _accentColor = Color(0xFFD94686);
const _textPrimaryColor = Color(0xFF1F2937);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _dangerColor = Color(0xFFE05C5C);

class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _profile;
  String? _email;
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

    final profile = await authService.loadProfile(user);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _email = user.email;
      _loading = false;
    });
  }

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await authService.logout();
    if (!mounted) return;
    navigator.pushNamedAndRemoveUntil(AuthLayout.loginRoute, (_) => false);
  }

  Future<void> _editProfile() async {
    await Navigator.pushNamed(context, ProfileEditPage.routeName);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final t = context.t;
    final languageController = AppLanguageScope.controllerOf(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textPrimaryColor,
        title: Text(t.tr('app.profile')),
        actions: [
          TextButton.icon(
            onPressed: _editProfile,
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: Text(t.tr('app.edit')),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Text(
                    t.tr('profile.manage'),
                    style: const TextStyle(
                      color: _textTertiaryColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: _accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: _ProfilePhoto(
                          photo: profile?.photo ?? '',
                          fallback: const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 52,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile?.name ?? 'User',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textPrimaryColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _email ?? profile?.email ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textTertiaryColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _InfoRow(
                    icon: Icons.person_outline_rounded,
                    label: t.tr('profile.gender'),
                    value: profile?.gender ?? '-',
                    onTap: _editProfile,
                  ),
                  _InfoRow(
                    icon: Icons.flag_rounded,
                    label: t.tr('profile.goal'),
                    value: _goalLabel(context, profile?.goal),
                    onTap: _editProfile,
                  ),
                  _InfoRow(
                    icon: Icons.calendar_today_rounded,
                    label: t.tr('profile.dob'),
                    value: profile?.dob ?? '-',
                    onTap: _editProfile,
                  ),
                  _InfoRow(
                    icon: Icons.height_rounded,
                    label: t.tr('profile.height'),
                    value: profile?.height == null
                        ? '-'
                        : '${profile!.height!.toStringAsFixed(0)} cm',
                    onTap: _editProfile,
                  ),
                  _InfoRow(
                    icon: Icons.monitor_weight_outlined,
                    label: t.tr('profile.weight'),
                    value: profile?.weight == null
                        ? '-'
                        : '${profile!.weight!.toStringAsFixed(0)} kg',
                    onTap: _editProfile,
                  ),
                  _InfoRow(
                    icon: Icons.fitness_center_rounded,
                    label: t.tr('profile.equipment'),
                    value: (profile?.equipment ?? const []).isEmpty
                        ? '-'
                        : profile!.equipment!.join(', '),
                    onTap: _editProfile,
                  ),
                  _LanguageRow(
                    controller: languageController,
                    label: t.tr('app.language'),
                    englishLabel: t.tr('app.english'),
                    indonesianLabel: t.tr('app.indonesian'),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      key: const Key('profile-logout-button'),
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: Text(
                        t.tr('app.logout'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _accentColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: const TextStyle(
                      color: _textTertiaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _textPrimaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
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

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.photo, required this.fallback});

  final String photo;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final bytes = _dataUriBytes(photo);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    return fallback;
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

Uint8List? _dataUriBytes(String value) {
  final comma = value.indexOf(',');
  if (!value.startsWith('data:image/') || comma == -1) return null;

  try {
    return base64Decode(value.substring(comma + 1));
  } catch (_) {
    return null;
  }
}

String _goalLabel(BuildContext context, String? goal) {
  final t = context.t;
  switch (goal) {
    case 'lose_weight':
      return t.tr('goal.lose_weight');
    case 'build_muscle':
      return t.tr('goal.build_muscle');
    case 'increase_weight':
      return t.tr('goal.increase_weight');
    case 'maintain_muscle':
      return t.tr('goal.maintain_muscle');
    case 'improve_fitness':
      return t.tr('goal.improve_fitness');
    case 'maintain':
      return t.tr('goal.maintain');
    default:
      return '-';
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.controller,
    required this.label,
    required this.englishLabel,
    required this.indonesianLabel,
  });

  final AppLanguageController controller;
  final String label;
  final String englishLabel;
  final String indonesianLabel;

  @override
  Widget build(BuildContext context) {
    final languageCode = controller.value.languageCode;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.language_rounded,
              color: _accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: _textTertiaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'en', label: Text(englishLabel)),
                    ButtonSegment(value: 'id', label: Text(indonesianLabel)),
                  ],
                  selected: {languageCode == 'id' ? 'id' : 'en'},
                  onSelectionChanged: (selection) {
                    controller.setLanguage(Locale(selection.first));
                  },
                  showSelectedIcon: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
