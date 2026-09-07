import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import 'app_card.dart' show AppRadius;

/// Floating label input field.
///
/// Clean elevation-2 fill with a hairline border. Focus is communicated with
/// the accent border only — no glow, no animated shadow.
class FloatingLabelInput extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLength;
  final bool enabled;
  final ValueChanged<String>? onFieldSubmitted;

  const FloatingLabelInput({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLength,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  @override
  State<FloatingLabelInput> createState() => _FloatingLabelInputState();
}

class _FloatingLabelInputState extends State<FloatingLabelInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChange() {
    if (_hasError) _validateField();
  }

  void _validateField() {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(widget.controller.text);
        _hasError = _errorText != null;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          enabled: widget.enabled,
          maxLength: widget.maxLength,
          validator: widget.validator,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
            fontFamily: 'Inter',
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(
              color: _hasError
                  ? AppColors.error
                  : _isFocused
                      ? AppColors.accent
                      : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            floatingLabelStyle: TextStyle(
              color: _hasError ? AppColors.error : AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
            filled: true,
            fillColor: AppColors.surfaceAlt,
            counterStyle: const TextStyle(color: AppColors.textMuted),
            prefixIcon: widget.prefixIcon != null
                ? IconTheme(
                    data: IconThemeData(
                      color: _isFocused
                          ? AppColors.accent
                          : AppColors.textMuted,
                    ),
                    child: widget.prefixIcon!,
                  )
                : null,
            suffixIcon: widget.suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: _hasError
                    ? AppColors.error.withValues(alpha: 0.5)
                    : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: _hasError ? AppColors.error : AppColors.accent,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (_hasError && _errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              _errorText!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            )
                .animate()
                .fadeIn(duration: 200.ms)
                .slideY(begin: -0.2, end: 0, duration: 200.ms),
          ),
      ],
    );
  }
}

/// Restrained entrance motion: fade + rise, ease-out only.
extension FloatingLabelInputExtension on FloatingLabelInput {
  Widget animateEntrance({int delay = 0}) {
    return animate()
        .fadeIn(duration: 400.ms, delay: delay.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 400.ms,
          delay: delay.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
