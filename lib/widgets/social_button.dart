import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_card.dart' show AppRadius;

/// Clean, flat social authentication button with tactile feedback.
class SocialAuthButton extends StatefulWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  State<SocialAuthButton> createState() => _SocialAuthButtonState();
}

class _SocialAuthButtonState extends State<SocialAuthButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.isLoading) _controller.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.textSecondary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      widget.icon,
                      const SizedBox(width: 8),
                      Text(
                        widget.label,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Authentic 4-color Google "G" vector mark.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - paint.strokeWidth / 2);

    // Blue arc (right top to right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.4, false, paint);

    // Green arc (bottom right to bottom left)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.0, 1.4, false, paint);

    // Yellow arc (bottom left to top left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.4, 1.3, false, paint);

    // Red arc (top left to top right)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.7, 1.3, false, paint);

    // Blue horizontal bar
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    final barRect = Rect.fromLTWH(
      w * 0.48,
      h * 0.41,
      w * 0.50,
      h * 0.22,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// GitHub vector mark.
class GitHubLogo extends StatelessWidget {
  final double size;
  final Color color;

  const GitHubLogo({
    super.key,
    this.size = 18,
    this.color = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GitHubLogoPainter(color: color),
    );
  }
}

class _GitHubLogoPainter extends CustomPainter {
  final Color color;

  _GitHubLogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Standard GitHub Octocat SVG path scaled to 24x24
    final path = Path()
      ..moveTo(12, 2)
      ..cubicTo(6.477, 2, 2, 6.484, 2, 12.017)
      ..cubicTo(2, 16.447, 4.87, 20.203, 8.84, 21.527)
      ..cubicTo(9.34, 21.617, 9.52, 21.31, 9.52, 21.045)
      ..cubicTo(9.52, 20.803, 9.51, 20.163, 9.51, 19.314)
      ..cubicTo(6.73, 19.917, 6.14, 17.975, 6.14, 17.975)
      ..cubicTo(5.68, 16.824, 5.03, 16.517, 5.03, 16.517)
      ..cubicTo(4.12, 15.897, 5.1, 15.909, 5.1, 15.909)
      ..cubicTo(6.1, 15.979, 6.63, 16.936, 6.63, 16.936)
      ..cubicTo(7.52, 18.463, 8.97, 18.022, 9.54, 17.765)
      ..cubicTo(9.63, 17.118, 9.89, 16.678, 10.17, 16.429)
      ..cubicTo(7.95, 16.177, 5.62, 15.318, 5.62, 11.493)
      ..cubicTo(5.62, 10.403, 6.01, 9.512, 6.65, 8.814)
      ..cubicTo(6.55, 8.563, 6.2, 7.546, 6.75, 6.177)
      ..cubicTo(6.75, 6.177, 7.59, 5.908, 9.49, 7.195)
      ..cubicTo(10.29, 6.972, 11.14, 6.862, 12, 6.858)
      ..cubicTo(12.86, 6.862, 13.71, 6.972, 14.51, 7.195)
      ..cubicTo(16.41, 5.908, 17.25, 6.177, 17.25, 6.177)
      ..cubicTo(17.8, 7.546, 17.45, 8.563, 17.35, 8.814)
      ..cubicTo(17.99, 9.512, 18.38, 10.403, 18.38, 11.493)
      ..cubicTo(18.38, 15.328, 16.04, 16.173, 13.81, 16.42)
      ..cubicTo(14.17, 16.73, 14.49, 17.34, 14.49, 18.281)
      ..cubicTo(14.49, 19.637, 14.48, 20.732, 14.48, 21.045)
      ..cubicTo(14.48, 21.314, 14.65, 21.624, 15.17, 21.523)
      ..cubicTo(19.14, 20.197, 22, 16.444, 22, 12.017)
      ..cubicTo(22, 6.484, 17.522, 2, 12, 2)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
