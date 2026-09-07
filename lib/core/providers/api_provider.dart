import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/api_client.dart';

/// Provider for the central ApiClient instance.
/// Configured with Supabase client for auth token injection.
final apiClientProvider = Provider<ApiClient>((ref) {
  final supabase = Supabase.instance.client;
  return ApiClient(supabase: supabase);
});

/// Provider for Supabase client (for direct access if needed).
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for Supabase auth state stream.
/// Useful for listening to auth changes in real-time.
final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});
