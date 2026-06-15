import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';

const _backgroundColor = Color(0xFFEEF3F8);
const _cardColor = Color(0xFFFFFFFF);
const _accentColor = Color(0xFFD94686);
const _primaryColor = Color(0xFF42C8F5);
const _textPrimaryColor = Color(0xFF1F2937);
const _textSecondaryColor = Color(0xFF4B5563);
const _textTertiaryColor = Color(0xFF9CA3AF);
const _borderColor = Color(0xFFE5E7EB);
const _inputColor = Color(0xFFF3F6FA);
const _dangerColor = Color(0xFFDC2626);

const _genderOptions = ['Female', 'Male', 'Other'];
const _goalOptions = [
  GoalOption('lose_weight', 'Lose weight', Icons.local_fire_department_rounded),
  GoalOption('build_muscle', 'Build muscle', Icons.fitness_center_rounded),
  GoalOption('increase_weight', 'Increase weight', Icons.add_circle_rounded),
  GoalOption(
    'maintain_muscle',
    'Maintain muscle',
    Icons.self_improvement_rounded,
  ),
  GoalOption('maintain', 'Maintain health', Icons.favorite_rounded),
  GoalOption('improve_fitness', 'Improve fitness', Icons.trending_up_rounded),
];

const _equipmentOptions = [
  EquipmentOption('bodyweight', 'Bodyweight', Icons.accessibility_new_rounded),
  EquipmentOption('dumbbells', 'Dumbbells', Icons.fitness_center_rounded),
  EquipmentOption('barbell', 'Barbell', Icons.fitness_center_rounded),
  EquipmentOption('kettlebell', 'Kettlebell', Icons.sports_gymnastics_rounded),
  EquipmentOption(
    'resistance_bands',
    'Resistance Bands',
    Icons.linear_scale_rounded,
  ),
  EquipmentOption('yoga_mat', 'Yoga Mat', Icons.self_improvement_rounded),
  EquipmentOption('pull_up_bar', 'Pull-up Bar', Icons.horizontal_rule_rounded),
  EquipmentOption('treadmill', 'Treadmill', Icons.directions_run_rounded),
  EquipmentOption(
    'stationary_bike',
    'Stationary Bike',
    Icons.directions_bike_rounded,
  ),
  EquipmentOption('jump_rope', 'Jump Rope', Icons.loop_rounded),
];

class ProfileEditPage extends StatefulWidget {
  static const routeName = '/profile/edit';

  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _photoController = TextEditingController();
  final _picker = ImagePicker();

  String _gender = 'Female';
  String _goal = 'maintain';
  String _dob = '';
  List<String> _equipment = const ['bodyweight'];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await authService.currentProfile;
    if (!mounted) return;

    _nameController.text = profile?.name ?? '';
    _gender = profile?.gender ?? 'Female';
    _goal = profile?.goal ?? 'maintain';
    _dob = profile?.dob ?? '';
    _heightController.text = profile?.height?.toStringAsFixed(0) ?? '';
    _weightController.text = profile?.weight?.toStringAsFixed(0) ?? '';
    _photoController.text = profile?.photo ?? '';
    _equipment = profile?.equipment == null || profile!.equipment!.isEmpty
        ? const ['bodyweight']
        : profile.equipment!;

    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final initial = _parseDate(_dob) ?? DateTime(1996);
    final selected = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(DateTime.now()) ? DateTime(1996) : initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected == null) return;
    setState(() => _dob = _formatDate(selected));
  }

  void _toggleEquipment(String id) {
    setState(() {
      if (_equipment.contains(id)) {
        _equipment = _equipment.where((item) => item != id).toList();
      } else {
        _equipment = [..._equipment, id];
      }
    });
  }

  Future<void> _pickPhoto() async {
    try {
      final image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 60,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final extension = image.name.toLowerCase().endsWith('.png')
          ? 'png'
          : 'jpeg';
      _photoController.text =
          'data:image/$extension;base64,${base64Encode(bytes)}';
      if (mounted) setState(() {});
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open photo picker: $error')),
      );
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    final name = _nameController.text.trim();
    final height = double.tryParse(_heightController.text.trim());
    final weight = double.tryParse(_weightController.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Please enter your name.');
      return;
    }
    if (height != null && (height < 80 || height > 250)) {
      setState(() => _error = 'Height must be 80-250 cm.');
      return;
    }
    if (weight != null && (weight < 25 || weight > 250)) {
      setState(() => _error = 'Weight must be 25-250 kg.');
      return;
    }

    setState(() => _saving = true);
    try {
      await authService.saveProfile({
        'name': name,
        'gender': _gender,
        'goal': _goal,
        'dob': _dob,
        'height': height,
        'weight': weight,
        'equipment': _equipment,
        'photo': _photoController.text.trim().isEmpty
            ? null
            : _photoController.text.trim(),
      });
      await authService.refreshProfile();
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        foregroundColor: _textPrimaryColor,
        title: const Text('Edit Profile'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _AvatarPreview(
                  name: _nameController.text,
                  photo: _photoController.text,
                  onTap: _pickPhoto,
                ),
                const SizedBox(height: 16),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        onChanged: (_) => setState(() {}),
                      ),
                      const Text(
                        'Gender',
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          for (final gender in _genderOptions) ...[
                            Expanded(
                              child: _ChoiceTile(
                                label: gender,
                                selected: _gender == gender,
                                onTap: () => setState(() => _gender = gender),
                              ),
                            ),
                            if (gender != _genderOptions.last)
                              const SizedBox(width: 8),
                          ],
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Goal',
                        style: TextStyle(
                          color: _textSecondaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in _goalOptions)
                            _GoalChip(
                              option: option,
                              selected: _goal == option.id,
                              onTap: () => setState(() => _goal = option.id),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _DateField(value: _dob, onTap: _pickDate),
                      Row(
                        children: [
                          Expanded(
                            child: _ProfileTextField(
                              label: 'Height (cm)',
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              icon: Icons.height_rounded,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ProfileTextField(
                              label: 'Weight (kg)',
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              icon: Icons.monitor_weight_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Equipment',
                        style: TextStyle(
                          color: _textPrimaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Used to recommend workouts that match your gear.',
                        style: TextStyle(
                          color: _textTertiaryColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final option in _equipmentOptions)
                            _EquipmentTile(
                              option: option,
                              selected: _equipment.contains(option.id),
                              onTap: () => _toggleEquipment(option.id),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _dangerColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                PrimaryButton(
                  label: 'Save Changes',
                  color: _accentColor,
                  loading: _saving,
                  onPressed: _save,
                  testID: 'edit-profile-save',
                ),
              ],
            ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    required this.name,
    required this.photo,
    required this.onTap,
  });

  final String name;
  final String photo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 110,
                height: 110,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: _accentColor,
                  shape: BoxShape.circle,
                ),
                child: _ProfilePhoto(photo: photo, initial: initial),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Tap to change photo',
          style: TextStyle(
            color: _textTertiaryColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.photo, required this.initial});

  final String photo;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final bytes = _dataUriBytes(photo);
    if (bytes != null) {
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Initial(initial: initial),
      );
    }

    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return Image.network(
        photo,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _Initial(initial: initial),
      );
    }

    return _Initial(initial: initial);
  }
}

class _Initial extends StatelessWidget {
  const _Initial({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 44,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date of Birth',
            style: TextStyle(
              color: _textSecondaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(minHeight: 50),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: _inputColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    color: _textTertiaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      value.isEmpty ? 'Tap to pick your birthday' : value,
                      style: TextStyle(
                        color: value.isEmpty
                            ? _textTertiaryColor
                            : _textPrimaryColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.icon,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? icon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon == null
              ? null
              : Icon(icon, color: _textTertiaryColor, size: 18),
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

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
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
          color: selected ? _accentColor : _inputColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _accentColor : _borderColor),
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

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final GoalOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(
        option.icon,
        size: 16,
        color: selected ? Colors.white : _textSecondaryColor,
      ),
      label: Text(option.label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: _accentColor,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : _textSecondaryColor,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _EquipmentTile extends StatelessWidget {
  const _EquipmentTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final EquipmentOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 56) / 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: const BoxConstraints(minHeight: 92),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFBE3EE) : _inputColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? _accentColor : _borderColor),
          ),
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.icon,
                      color: selected ? _accentColor : _textSecondaryColor,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? _accentColor : _textSecondaryColor,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Positioned(
                  top: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: _accentColor,
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
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
      decoration: _cardDecoration(),
      child: child,
    );
  }
}

class EquipmentOption {
  const EquipmentOption(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
}

class GoalOption {
  const GoalOption(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;
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

DateTime? _parseDate(String value) {
  if (value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
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
