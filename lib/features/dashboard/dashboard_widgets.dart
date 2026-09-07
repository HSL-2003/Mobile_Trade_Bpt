import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_card.dart';

/// Dashboard app bar: per-tab title + account subtitle + logout action.
Widget buildDashboardAppBar(String title, String subtitle, VoidCallback onLogout) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'SpaceGrotesk',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: onLogout,
          icon: const Icon(
            Icons.logout_rounded,
            size: 20,
            color: AppColors.textSecondary,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surface,
            fixedSize: const Size(42, 42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    ),
  );
}

/// Error state with retry action.
Widget buildErrorState(String error, VoidCallback onRetry) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 28,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}
