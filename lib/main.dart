import 'package:flutter/material.dart';
import 'app.dart';
import 'network/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  runApp(const App());
}
