import 'package:flutter/material.dart';

/// Lightweight theme controller using a global ValueNotifier.
/// Avoids external dependencies while letting any widget toggle theme mode.
class ThemeController {
  ThemeController._();
  static final ThemeController instance = ThemeController._();

  /// Current app ThemeMode. Defaults to dark.
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  void toggle() {
    final isDark = themeMode.value == ThemeMode.dark;
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  void set(ThemeMode mode) {
    themeMode.value = mode;
  }
}
