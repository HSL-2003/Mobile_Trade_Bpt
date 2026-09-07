import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'app_card.dart' show AppRadius;

/// Shimmer loading effect for content placeholders.
class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: AppColors.surfaceAlt,
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: AppColors.surfaceHighlight,
          delay: 300.ms,
        );
  }
}

/// Shimmer loading card placeholder
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerLoading(width: double.infinity, height: 16),
        SizedBox(height: 8),
        ShimmerLoading(width: 200, height: 16),
        SizedBox(height: 8),
        ShimmerLoading(width: 150, height: 16),
      ],
    );
  }
}

/// Shimmer loading for list items
class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const ShimmerLoading(width: 40, height: 40, borderRadius: AppRadius.sm),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                ShimmerLoading(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full screen shimmer loader
class ShimmerFullScreen extends StatelessWidget {
  const ShimmerFullScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.all(24),
      child: const Column(
        children: [
          SizedBox(height: 60),
          ShimmerLoading(width: 96, height: 96, borderRadius: 24),
          SizedBox(height: 32),
          ShimmerLoading(width: 200, height: 24),
          SizedBox(height: 16),
          ShimmerLoading(width: 280, height: 14),
          SizedBox(height: 8),
          ShimmerLoading(width: 240, height: 14),
          SizedBox(height: 40),
          ShimmerLoading(width: double.infinity, height: 52, borderRadius: 12),
          SizedBox(height: 16),
          ShimmerLoading(width: double.infinity, height: 52, borderRadius: 12),
        ],
      ),
    );
  }
}
