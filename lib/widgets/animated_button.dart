import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'app_card.dart' show AppRadius;

/// Primary action button.
///
/// Flat accent fill (no gradient/glow), restrained press feedback (0.98 scale)
/// and an in-place loading state. [backgroundColor]/[foregroundColor] allow
/// semantic variants (e.g. destructive).
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AnimatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 52,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _background {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    return widget.isOutlined ? AppColors.surface : AppColors.accent;
  }

  Color get _foreground {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    return widget.isOutlined ? AppColors.textPrimary : AppColors.background;
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isLoading) _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final showBorder =
        widget.isOutlined && widget.backgroundColor == null;

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onPressed,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: showBorder ? AppColors.border : Colors.transparent,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: BorderRadius.circular(AppRadius.md),
              splashColor: AppColors.textPrimary.withValues(alpha: 0.06),
              highlightColor: AppColors.textPrimary.withValues(alpha: 0.04),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_foreground),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18, color: _foreground),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _foreground,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Restrained entrance motion: fade + rise, ease-out only.
extension AnimatedButtonExtension on AnimatedButton {
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
