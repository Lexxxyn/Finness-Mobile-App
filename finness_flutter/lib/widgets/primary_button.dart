import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onPress;
  final Color color;
  final Color textColor;
  final bool loading;
  final bool disabled;
  final String? testID;
  final ButtonStyle? style;
  final TextStyle? textStyle;
  final Widget? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.onPress,
    this.color = const Color(0xFF4F46E5),
    this.textColor = Colors.white,
    this.loading = false,
    this.disabled = false,
    this.testID,
    this.style,
    this.textStyle,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = disabled || loading;
    final callback = onPressed ?? onPress;

    return ElevatedButton(
      key: testID != null ? Key(testID!) : null,
      onPressed: isDisabled ? null : callback,
      style:
          style ??
          ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 4,
            shadowColor: Colors.black.withValues(alpha: 0.16),
          ),
      child: loading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
                strokeWidth: 2,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style:
                      textStyle ??
                      TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                ),
              ],
            ),
    );
  }
}
