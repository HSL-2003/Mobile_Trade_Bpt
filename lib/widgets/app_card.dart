import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// Primary surface container — the workhorse card of the design system.
///
/// Flat opaque surface + hairline border + soft ambient shadow. Replaces the
/// previous glassmorphism card (no backdrop blur → cheaper to render and
/// visually calmer).
class AppCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.width,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppRadius.lg,
    this.color,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardDecoration = BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor ?? AppColors.border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x2E000000),
          blurRadius: 16,
          offset: Offset(0, 4),
        ),
      ],
    );

    if (onTap != null) {
      return Container(
        width: width,
        decoration: cardDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.accent.withValues(alpha: 0.08),
            highlightColor: AppColors.accent.withValues(alpha: 0.04),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    }

    return Container(
      width: width,
      padding: padding,
      decoration: cardDecoration,
      child: child,
    );
  }
}

/// Radius tokens shared across the design system.
class AppRadius {
  AppRadius._();

  static const double xs = 4;
  static const double sm = 10;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double full = 9999;
}

/// Restrained entrance motion: fade + 8px rise, ease-out only.
extension AppCardEntrance on AppCard {
  Widget animateEntrance({int delay = 0}) {
    return animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          delay: delay.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
