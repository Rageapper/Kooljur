import 'package:flutter/material.dart';
import 'theme_provider.dart';

class ThemeInheritedWidget extends InheritedWidget {
  final ThemeProvider themeProvider;

  const ThemeInheritedWidget({
    super.key,
    required this.themeProvider,
    required super.child,
  });

  static ThemeProvider of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<ThemeInheritedWidget>();
    return widget!.themeProvider;
  }

  @override
  bool updateShouldNotify(ThemeInheritedWidget oldWidget) {
    return themeProvider != oldWidget.themeProvider;
  }
}
