import 'package:flutter/material.dart';
import '../theme/premium_design_system.dart';

/// Premium Button Component
/// Minimalist full-width call-to-action button with sharp borders or solid primary flat tones
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isFullWidth;
  final bool isSecondary;
  final bool isOutlined;
  final IconData? icon;
  final bool isLoading;

  const PremiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isFullWidth = true,
    this.isSecondary = false,
    this.isOutlined = false,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    Color borderColor;

    if (isOutlined) {
      backgroundColor = Colors.transparent;
      foregroundColor = theme.colorScheme.primary;
      borderColor = theme.colorScheme.primary;
    } else if (isSecondary) {
      backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
      foregroundColor = theme.colorScheme.primary;
      borderColor = Colors.transparent;
    } else {
      backgroundColor = theme.colorScheme.primary;
      foregroundColor = theme.colorScheme.onPrimary;
      borderColor = Colors.transparent;
    }

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: theme.colorScheme.outline.withOpacity(0.1),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(PremiumDesignSystem.borderRadius),
          ),
          side: BorderSide(
            color: borderColor,
            width: PremiumDesignSystem.borderWidth,
          ),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
