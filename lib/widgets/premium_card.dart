import 'package:flutter/material.dart';
import '../theme/premium_design_system.dart';

/// Premium Card Component
/// Flat container with explicit thin borders, dynamic background fills, and comfortable padding
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool useElevation;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.useElevation = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;
    final borderColor = this.borderColor ?? theme.colorScheme.outline.withOpacity(0.2);

    Widget card = Container(
      padding: padding ?? const EdgeInsets.all(PremiumDesignSystem.cardPadding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.all(
          Radius.circular(PremiumDesignSystem.borderRadius),
        ),
        border: Border.all(
          color: borderColor,
          width: PremiumDesignSystem.borderWidth,
        ),
        boxShadow: useElevation
            ? theme.brightness == Brightness.dark
                ? [PremiumDesignSystem.subtleElevationDark]
                : [PremiumDesignSystem.subtleElevation]
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
