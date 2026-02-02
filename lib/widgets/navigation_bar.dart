import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';

class NavigationBar extends StatelessWidget {
  final VoidCallback onFirstButtonTap;
  final VoidCallback onSecondButtonTap;
  final VoidCallback onThirdButtonTap;
  final VoidCallback onFourthButtonTap;
  final VoidCallback onFifthButtonTap;

  const NavigationBar({
    Key? key,
    required this.onFirstButtonTap,
    required this.onSecondButtonTap,
    required this.onThirdButtonTap,
    required this.onFourthButtonTap,
    required this.onFifthButtonTap,
  }) : super(key: key);

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final brightness = Theme.of(context).brightness;
    return Expanded(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
          onTap: onTap,
          splashColor: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.2)
              : Colors.black.withOpacity(0.1),
          highlightColor: brightness == Brightness.dark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Icon(
                icon,
              color: AppColors.getWhite(context),
                size: 32,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getCardColor(context),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            context: context,
            icon: Icons.menu_book_outlined,
            onTap: onFirstButtonTap,
          ),
          _buildIconButton(
            context: context,
            icon: Icons.notifications_outlined,
            onTap: onSecondButtonTap,
          ),
          _buildIconButton(
            context: context,
            icon: Icons.description_outlined,
            onTap: onThirdButtonTap,
          ),
          _buildIconButton(
            context: context,
            icon: Icons.mail_outline,
            onTap: onFourthButtonTap,
          ),
          _buildIconButton(
            context: context,
            icon: Icons.menu,
            onTap: onFifthButtonTap,
          ),
        ],
      ),
    );
  }
}