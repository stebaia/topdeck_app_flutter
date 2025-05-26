import 'package:flutter/material.dart';
import 'package:topdeck_app_flutter/utils/deep_link_handler.dart';
import 'app.dart';
import 'network/supabase_config.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();
  await AppLinkService.instance.initialize();
  runApp(const App());
}
