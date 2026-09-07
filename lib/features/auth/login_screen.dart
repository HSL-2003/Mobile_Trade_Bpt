import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../../core/providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/floating_label_input.dart';
import '../../widgets/social_button.dart';

/// Sign-in screen.
///
/// Flat surface card (no backdrop blur, no decorative gradients) with a
/// left-aligned header, a single accent CTA and restrained entrance motion.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSocialLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = 'hoangsonlam97@gmail.com';
    _passwordController.text = 'Password123!';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return 'Vui lòng nhập địa chỉ email';
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&‘*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Định dạng email không hợp lệ (ví dụ: user@example.com)';
    }
    if (trimmed.length > 254) return 'Email quá dài (tối đa 254 ký tự)';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu phải từ 6 ký tự trở lên';
    if (value.length > 128) return 'Mật khẩu quá dài (tối đa 128 ký tự)';
    return null;
  }

  Future<void> _handleLogin() async {
    final isBusy = ref.read(authProvider).isLoading || _isSocialLoading;
    if (isBusy) return;
    ref.read(authProvider.notifier).clearError();

    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final success = await ref.read(authProvider.notifier).login(
          email: email,
          password: password,
        );
    if (success && mounted) {
      context.go('/dashboard');
    } else if (!success && mounted) {
      final errorMsg = ref.read(authProvider).error ??
          'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleSocialAuth(OAuthProvider provider) async {
    final isBusy = ref.read(authProvider).isLoading || _isSocialLoading;
    if (isBusy) return;
    ref.read(authProvider.notifier).clearError();

    setState(() => _isSocialLoading = true);
    try {
      if (provider == OAuthProvider.google) {
        await ref.read(authProvider.notifier).loginWithGoogle();
      } else if (provider == OAuthProvider.github) {
        await ref.read(authProvider.notifier).loginWithGitHub();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Lỗi đăng nhập qua ${provider == OAuthProvider.google ? "Google" : "GitHub"}: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSocialLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.isAuthenticated && mounted) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410),
              child: _buildAuthCard(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthCard() {
    final authState = ref.watch(authProvider);

    return AppCard(
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
      borderColor: AppColors.borderStrong,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 28),
          _buildForm(authState),
          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 18),
          _buildSocialButtons(authState),
          const SizedBox(height: 22),
          _buildRegisterLink(),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(
          begin: 0.08,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }

Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          child: const Icon(
            Icons.candlestick_chart_rounded,
            size: 22,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Sign In',
          style: TextStyle(
            fontFamily: 'SpaceGrotesk',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Welcome back. Enter your credentials to continue.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildForm(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (authState.error != null)
            _buildErrorBanner(authState.error!),
          FloatingLabelInput(
            controller: _emailController,
            label: 'Email address',
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            prefixIcon: const Icon(Icons.alternate_email, size: 20),
          ),
          const SizedBox(height: 14),
          FloatingLabelInput(
            controller: _passwordController,
            label: 'Password',
            obscureText: _obscurePassword,
            validator: _validatePassword,
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textMuted,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 30),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedButton(
            text: 'Sign In',
            onPressed: (authState.isLoading || _isSocialLoading)
                ? null
                : _handleLogin,
            isLoading: authState.isLoading,
          ),
        ],
      ),
    );
  }

Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }

  Widget _buildSocialButtons(AuthState authState) {
    return Row(
      children: [
        Expanded(
          child: SocialAuthButton(
            icon: const GoogleLogo(size: 17),
            label: 'Google',
            isLoading: _isSocialLoading,
            onPressed: (authState.isLoading || _isSocialLoading)
                ? null
                : () => _handleSocialAuth(OAuthProvider.google),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SocialAuthButton(
            icon: const GitHubLogo(size: 17),
            label: 'GitHub',
            isLoading: _isSocialLoading,
            onPressed: (authState.isLoading || _isSocialLoading)
                ? null
                : () => _handleSocialAuth(OAuthProvider.github),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildRegisterLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        GestureDetector(
          onTap: () => context.push('/register'),
          child: const Text(
            'Sign Up',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}