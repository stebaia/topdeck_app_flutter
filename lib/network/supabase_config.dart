import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// The Supabase client instance for making API calls
final supabase = Supabase.instance.client;

/// Supabase URL from your project
const supabaseUrl = 'https://ixxlaycszoppcyizapoa.supabase.co';

/// Supabase anon key from your project
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml4eGxheWNzem9wcGN5aXphcG9hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY5NTc5NDcsImV4cCI6MjA2MjUzMzk0N30.TqOmddl6K3ZGNAuk_8DxMIUMA5tPKuPsH-hyCzyCsXE';

/// Hostname for the auth callback URL
const authCallbackUrlHostname = 'login-callback';

/// Redirect URI for OAuth workflows
final redirectUrl = kIsWeb ? null : 'io.supabase.topdeck://$authCallbackUrlHostname';

/// Initialize Supabase
Future<void> initializeSupabase() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
    debug: false,
  );
} 