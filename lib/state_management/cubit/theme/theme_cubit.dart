import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeType { system, light, dark }

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeKey = 'app_theme';
  
  ThemeCubit() : super(ThemeState(ThemeType.system, ThemeMode.system));

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString(_themeKey) ?? 'system';
    final themeType = ThemeType.values.firstWhere(
      (e) => e.toString() == 'ThemeType.$themeString',
      orElse: () => ThemeType.system,
    );
    
    final themeMode = _getThemeModeFromType(themeType);
    emit(ThemeState(themeType, themeMode));
  }

  Future<void> setTheme(ThemeType themeType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeType.name);
    
    final themeMode = _getThemeModeFromType(themeType);
    emit(ThemeState(themeType, themeMode));
  }

  ThemeMode _getThemeModeFromType(ThemeType themeType) {
    switch (themeType) {
      case ThemeType.light:
        return ThemeMode.light;
      case ThemeType.dark:
        return ThemeMode.dark;
      case ThemeType.system:
        return ThemeMode.system;
    }
  }
}

class ThemeState {
  final ThemeType themeType;
  final ThemeMode themeMode;

  ThemeState(this.themeType, this.themeMode);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          themeType == other.themeType &&
          themeMode == other.themeMode;

  @override
  int get hashCode => themeType.hashCode ^ themeMode.hashCode;
} 