import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/l10n/app_localizations.dart';

class Header extends StatelessWidget {
  final VoidCallback onProfileTap;

  const Header({
    Key? key,
    required this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Container(
      color: AppColors.getCardColor(context),
      padding: const EdgeInsets.only(top: 27, left: 18, right: 18, bottom: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations?.diary ?? "Дневник",
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: onProfileTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.settings,
                color: AppColors.getWhite(context),
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
