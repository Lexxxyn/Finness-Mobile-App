import 'package:flutter/material.dart';

import '../../../models/models.dart';

export '../../../models/models.dart'
    show
        Meal,
        MealType,
        Recipe,
        mealTypeBreakfast,
        mealTypeLunch,
        mealTypeSnack,
        mealTypeDinner;

const mealBackgroundColor = Color(0xFFEEF3F8);
const mealCardColor = Color(0xFFFFFFFF);
const mealPrimaryColor = Color(0xFF42C8F5);
const mealTextPrimaryColor = Color(0xFF1F2937);
const mealTextSecondaryColor = Color(0xFF4B5563);
const mealTextTertiaryColor = Color(0xFF9CA3AF);
const mealBorderColor = Color(0xFFE5E7EB);
const mealInputColor = Color(0xFFF3F6FA);
const mealLogColor = Color(0xFFF97316);
const mealDangerColor = Color(0xFFE05C5C);

const mealOrder = [
  mealTypeBreakfast,
  mealTypeLunch,
  mealTypeSnack,
  mealTypeDinner,
];

String todayString() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}-$month-$day';
}

String mealLabel(MealType type) {
  switch (type) {
    case mealTypeBreakfast:
      return 'Breakfast';
    case mealTypeLunch:
      return 'Lunch';
    case mealTypeSnack:
      return 'Snack';
    case mealTypeDinner:
      return 'Dinner';
    default:
      return type;
  }
}

String defaultTimeForMeal(MealType type) {
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

Color mealColor(MealType type) {
  switch (type) {
    case mealTypeBreakfast:
      return const Color(0xFFF5A742);
    case mealTypeLunch:
      return const Color(0xFF5CBF7A);
    case mealTypeSnack:
      return const Color(0xFFF07070);
    case mealTypeDinner:
      return const Color(0xFF42C8F5);
    default:
      return mealPrimaryColor;
  }
}

IconData mealIcon(MealType type) {
  switch (type) {
    case mealTypeBreakfast:
      return Icons.breakfast_dining_rounded;
    case mealTypeLunch:
      return Icons.local_dining_rounded;
    case mealTypeSnack:
      return Icons.apple_rounded;
    case mealTypeDinner:
      return Icons.dinner_dining_rounded;
    default:
      return Icons.restaurant_rounded;
  }
}

BoxDecoration mealCardDecoration({Color color = mealCardColor}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: mealBorderColor),
    boxShadow: [
      BoxShadow(
        color: mealTextPrimaryColor.withValues(alpha: 0.05),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
}

class MealTextField extends StatefulWidget {
  const MealTextField({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
  });

  final String? label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;

  @override
  State<MealTextField> createState() => _MealTextFieldState();
}

class _MealTextFieldState extends State<MealTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant MealTextField oldWidget) {
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
          hintText: widget.hint,
          prefixIcon: widget.prefixIcon == null
              ? null
              : Icon(widget.prefixIcon, color: mealTextTertiaryColor),
          filled: true,
          fillColor: mealInputColor,
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
        ),
      ),
    );
  }
}
