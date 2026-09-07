import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bot_trade_auth/main.dart';
import 'package:bot_trade_auth/widgets/animated_button.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  group('LoginScreen Widget Tests', () {
    Future<void> pumpLogin(WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: BotTradeApp()));
      await tester.pumpAndSettle();
    }

    testWidgets('Login screen renders correctly', (WidgetTester tester) async {
      await pumpLogin(tester);

      // Header (title shares text with the CTA button)
      expect(find.text('Sign In'), findsNWidgets(2));
      expect(
        find.text('Welcome back. Enter your credentials to continue.'),
        findsOneWidget,
      );

      // Form fields
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Social sign-in options
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);

      // Register link
      expect(find.text("Don't have an account? "), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('Empty fields show validation errors',
        (WidgetTester tester) async {
      await pumpLogin(tester);

      // Clear the pre-filled credentials
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '');
      await tester.enterText(fields.at(1), '');

      // Tap sign in (the CTA button, not the header title)
      await tester.tap(find.byType(AnimatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Vui lòng nhập địa chỉ email'), findsWidgets);
      expect(find.text('Vui lòng nhập mật khẩu'), findsWidgets);
    });

    testWidgets('Invalid email shows error', (WidgetTester tester) async {
      await pumpLogin(tester);

      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(AnimatedButton));
      await tester.pumpAndSettle();

      expect(
        find.text('Định dạng email không hợp lệ (ví dụ: user@example.com)'),
        findsWidgets,
      );
    });

    testWidgets('Navigation to register screen works',
        (WidgetTester tester) async {
      await pumpLogin(tester);

      // Tap sign up link
      await tester.ensureVisible(find.text('Sign Up'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify register screen elements
      expect(find.text('Create Account'), findsNWidgets(2)); // header + button
      expect(find.text('Start your trading journey today'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });
  });
}
