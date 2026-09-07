import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'core/router/app_router.dart';

/// Supabase configuration - loaded from environment or defaults from .env
const String supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://ellamikmetzcchijhyqd.supabase.co',
);
const String supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'sb_publishable_4J7WR_kabAZEwpBMc0xIWw_qZ_xd9wJ',
);
/// Google OAuth Client ID for Android authentication
const String googleClientId = String.fromEnvironment(
  'GOOGLE_CLIENT_ID',
  defaultValue: '159443348604-8aje1tdbvago1qkb7se2tff77ml5itbf.apps.googleusercontent.com',
);
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Supabase with Google OAuth config
  debugPrint('⚡ [Supabase Init] Initializing Supabase with URL: $supabaseUrl');
  debugPrint('⚡ [Google OAuth] Using Client ID: $googleClientId');
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
  debugPrint('✅ [Supabase Init] Supabase initialized successfully');

  runApp(
    const ProviderScope(
      child: BotTradeApp(),
    ),
  );
}

/// Root application widget with Riverpod and GoRouter.
class BotTradeApp extends ConsumerWidget {
  const BotTradeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Bot Trade',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}