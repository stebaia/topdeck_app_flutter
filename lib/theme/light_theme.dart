import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData get make {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    );
  }
}
