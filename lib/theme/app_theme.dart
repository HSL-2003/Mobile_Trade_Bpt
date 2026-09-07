import 'package:flutter/material.dart';
import 'app_colors.dart';

/// taste-skill Design System — Theme
///
/// Single source of truth for typography, radii and component styling.
/// Screens inherit from here instead of restyling primitives inline.
class AppTheme {
  AppTheme._();

  // ── Radius scale ────────────────────────────────────────────────────────
  static const double radiusSm = 10;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;

  /// Numeric style used across P&L, prices and counters.
  static const List<FontFeature> tabularNumbers = [FontFeature.tabularFigures()];

  static ThemeData get darkTheme {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accent,
        secondary: AppColors.accentMuted,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: AppColors.background,
        onSecondary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: AppColors.textPrimary,
      ),
      fontFamily: 'Inter',
      textTheme: _textTheme,
    );

    return base.copyWith(
      inputDecorationTheme: _inputDecoration,
      elevatedButtonTheme: _elevatedButton,
      outlinedButtonTheme: _outlinedButton,
      textButtonTheme: _textButton,
      snackBarTheme: _snackBar,
      dialogTheme: _dialog,
      bottomSheetTheme: _bottomSheet,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      chipTheme: _chip,
      checkboxTheme: _checkbox,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.surfaceAlt,
      ),
      bottomNavigationBarTheme: _bottomNav,
    );
  }

  // ── Typography ──────────────────────────────────────────────────────────
  // Display / headline use Space Grotesk for a technical, numeric voice;
  // body copy stays on Inter. Tracking tightens as sizes grow.
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.8,
      fontFeatures: tabularNumbers,
    ),
    displayMedium: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.6,
      fontFeatures: tabularNumbers,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: -0.4,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.3,
    ),
    titleLarge: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: -0.2,
    ),
    titleMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      height: 1.5,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textMuted,
      height: 1.4,
    ),
    labelLarge: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      letterSpacing: 0.2,
    ),
    labelSmall: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      letterSpacing: 0.4,
    ),
  );

  // ── Inputs ──────────────────────────────────────────────────────────────
  static const InputDecorationTheme _inputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceAlt,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    hintStyle: TextStyle(color: AppColors.textPlaceholder, fontSize: 15),
    labelStyle: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    floatingLabelStyle: TextStyle(
      color: AppColors.textSecondary,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    ),
    border: _inputBorder,
    enabledBorder: _inputBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      borderSide: BorderSide(color: AppColors.accent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      borderSide: BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
      borderSide: BorderSide(color: AppColors.error, width: 1.5),
    ),
  );

  static const OutlineInputBorder _inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
    borderSide: BorderSide(color: AppColors.border),
  );

  // ── Buttons ─────────────────────────────────────────────────────────────
  static final ElevatedButtonThemeData _elevatedButton =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.background,
      disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(64, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );

  static final OutlinedButtonThemeData _outlinedButton =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.textPrimary,
      backgroundColor: Colors.transparent,
      side: const BorderSide(color: AppColors.borderStrong),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(64, 52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      textStyle: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
      ),
    ),
  );

  static final TextButtonThemeData _textButton = TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.accent,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        fontFamily: 'Inter',
      ),
    ),
  );

  // ── Feedback surfaces ───────────────────────────────────────────────────
  static const SnackBarThemeData _snackBar = SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor: AppColors.surfaceHighlight,
    contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusMd)),
    ),
    insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static const DialogThemeData _dialog = DialogThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(radiusXl)),
      side: BorderSide(color: AppColors.border),
    ),
    titleTextStyle: TextStyle(
      fontFamily: 'SpaceGrotesk',
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    contentTextStyle: TextStyle(
      fontSize: 14,
      color: AppColors.textSecondary,
      height: 1.5,
    ),
  );

  static const BottomSheetThemeData _bottomSheet = BottomSheetThemeData(
    backgroundColor: AppColors.surface,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: AppColors.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
    ),
  );

  // ── Small controls ──────────────────────────────────────────────────────
  static const ChipThemeData _chip = ChipThemeData(
    backgroundColor: Colors.transparent,
    side: BorderSide(color: AppColors.border),
    labelStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  );

  static final CheckboxThemeData _checkbox = CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? AppColors.accent
          : Colors.transparent,
    ),
    checkColor: WidgetStateProperty.all(AppColors.background),
    side: const BorderSide(color: AppColors.borderStrong, width: 1.5),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
  );

  static const BottomNavigationBarThemeData _bottomNav =
      BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.accent,
    unselectedItemColor: AppColors.textMuted,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
  );
}

