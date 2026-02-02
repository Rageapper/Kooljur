import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/user_model.dart';

class UserInfoSection extends StatefulWidget {
  final VoidCallback onInfoTap;
  final String weekRange;

  const UserInfoSection({
    Key? key,
    required this.onInfoTap,
    this.weekRange = '26.01-01.02',
  }) : super(key: key);

  @override
  State<UserInfoSection> createState() => _UserInfoSectionState();
}

class _UserInfoSectionState extends State<UserInfoSection> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await DataService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  String _getUserDisplayText() {
    if (_user == null) return '';

    final firstName = _user!.firstName.isNotEmpty ? _user!.firstName : '';
    final className = _user!.className.isNotEmpty ? _user!.className : '';

    // Если есть имя и класс
    if (firstName.isNotEmpty && className.isNotEmpty) {
      return '$firstName $className';
    }
    // Если есть только имя
    else if (firstName.isNotEmpty) {
      return firstName;
    }
    // Если есть только класс
    else if (className.isNotEmpty) {
      return className;
    }
    // Если ничего нет, показываем логин
    else {
      return _user!.login;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.getCardColor(context),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            color: AppColors.getWhite(context),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _getUserDisplayText(),
                    style: TextStyle(
                      color: AppColors.getTextPrimary(context),
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onInfoTap,
            child: Icon(
              Icons.calendar_today,
              color: AppColors.getWhite(context),
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: widget.onInfoTap,
            child: Text(
              widget.weekRange,
              style: TextStyle(
                color: AppColors.getTextPrimary(context),
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onInfoTap,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.getTextSecondary(context),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
