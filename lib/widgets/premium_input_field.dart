import 'package:flutter/material.dart';
import '../theme/premium_design_system.dart';

/// Premium Input Field Component
/// Border-centric input fields with soft focus highlights matching design system tokens
class PremiumInputField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final bool isMultiline;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;

  const PremiumInputField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.isMultiline = false,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: PremiumDesignSystem.label.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: isMultiline ? maxLines : 1,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: PremiumDesignSystem.bodyLarge.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: PremiumDesignSystem.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  )
                : null,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(PremiumDesignSystem.borderRadius),
              ),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: PremiumDesignSystem.borderWidth,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(PremiumDesignSystem.borderRadius),
              ),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: PremiumDesignSystem.borderWidth,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(PremiumDesignSystem.borderRadius),
              ),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: PremiumDesignSystem.borderWidth,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}
