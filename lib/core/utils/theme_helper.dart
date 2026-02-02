import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ThemeHelper {
  // Helper method to update all screens at once
  static void updateScreenColors(BuildContext context) {
    // This is a helper class for future use
    // All color updates should use AppColors methods with context
  }
  
  // Common pattern for Scaffold backgrounds
  static Color getScaffoldBackground(BuildContext context) {
    return AppColors.getBackgroundColor(context);
  }
  
  // Common pattern for AppBar backgrounds
  static Color getAppBarBackground(BuildContext context) {
    return AppColors.getCardColor(context);
  }
  
  // Common pattern for card backgrounds
  static Color getCardBackground(BuildContext context) {
    return AppColors.getCardColor(context);
  }
}
