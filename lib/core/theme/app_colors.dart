import 'package:flutter/material.dart';

class AppColors {
  // Accent colors
  static const Color accentBlue = Color(0xFF007AFF);
  
  // Helper methods to get theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
  }
  
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
  
  static Color getTextSecondary(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? const Color(0xFF898A8E)
        : Colors.black54;
  }
  
  static Color getWhite(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }
  
  static Color getIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? Colors.white : Colors.black87;
  }
  
  static Color getAccentColor(BuildContext context) {
    return Colors.blue; // Можно сделать адаптивным, если нужно
  }
  
  // Legacy static colors for backward compatibility (will use theme-aware versions)
  static Color get darkBackground => const Color(0xFF111111);
  static Color get darkCard => const Color(0xFF262626);
  static Color get white => Colors.white;
  static Color get textPrimary => Colors.white;
  static Color get textSecondary => Colors.white;
}