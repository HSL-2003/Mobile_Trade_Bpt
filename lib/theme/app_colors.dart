import 'package:flutter/material.dart';

/// taste-skill Design System — Color Tokens
///
/// Dark fintech surface scale. Flat and opaque: elevation is expressed with
/// progressively lighter surfaces plus a hairline border — never blur,
/// colored glow, or decorative gradients.
class AppColors {
  AppColors._();

  // ── Surfaces (elevation scale) ──────────────────────────────────────────
  /// App background — deepest level.
  static const Color background = Color(0xFF0A0E17);

  /// Cards, sheets, dialogs — elevation 1.
  static const Color surface = Color(0xFF10151F);

  /// Inputs and nested blocks inside cards — elevation 2.
  static const Color surfaceAlt = Color(0xFF161D2B);

  /// Hover / pressed / filled controls — elevation 3.
  static const Color surfaceHighlight = Color(0xFF1C2434);

  // ── Borders (hairlines) ─────────────────────────────────────────────────
  /// Default hairline between surfaces.
  static const Color border = Color(0xFF1E2839);

  /// Emphasized hairline (focused controls, strong dividers).
  static const Color borderStrong = Color(0xFF2A3648);
  // ── Accent ──────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF38BDF8);
  static const Color accentMuted = Color(0xFF0EA5E9);
  static const Color accentBg = Color(0x1F38BDF8);

  /// Focus ring tint — used sparingly on focused inputs only.
  static const Color accentGlow = Color(0x2938BDF8);

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textPlaceholder = Color(0xFF475569);

  // ── Semantic states (Fintech calibrated) ────────────────────────────────
  static const Color success = Color(0xFF22C55E); // Emerald
  static const Color error = Color(0xFFF87171);   // Crimson Rose
  static const Color warning = Color(0xFFFBBF24); // Amber
  static const Color buy = Color(0xFF22C55E);
  static const Color sell = Color(0xFFF87171);
  static const Color buyBg = Color(0x1F22C55E);
  static const Color sellBg = Color(0x1FF87171);
}
