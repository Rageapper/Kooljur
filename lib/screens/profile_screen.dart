import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/services/avatar_service.dart';
import 'package:myapp/core/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAvatar();
  }

  Future<void> _loadUser() async {
    final user = await DataService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _loadAvatar() async {
    final avatarFile = await AvatarService.getAvatarFile();
    if (mounted) {
      setState(() {
        _avatarFile = avatarFile;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getCardColor(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.getIconColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Профиль',
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.getAccentColor(context),
              ),
            )
          : _user == null
              ? Center(
                  child: Text(
                    'Пользователь не найден',
                    style: TextStyle(
                      color: AppColors.getTextSecondary(context),
                      fontSize: 16,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Аватар и основная информация
                      _buildProfileHeader(context),
                      const SizedBox(height: 32),
                      // Информация о пользователе
                      _buildInfoSection(context),
                      const SizedBox(height: 24),
                      // Дополнительные настройки
                      _buildSettingsSection(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();
    
    return Column(
      children: [
        // Аватар с кнопкой редактирования
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.getCardColor(context),
                border: Border.all(
                  color: AppColors.getAccentColor(context),
                  width: 3,
                ),
              ),
              child: _avatarFile != null
                  ? ClipOval(
                      child: Image.file(
                        _avatarFile!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: AppColors.getIconColor(context),
                      size: 60,
                    ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.getAccentColor(context),
                  border: Border.all(
                    color: AppColors.getBackgroundColor(context),
                    width: 3,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                  onPressed: () => _showEditProfileDialog(context),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // ФИО
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            '${_user!.lastName} ${_user!.firstName} ${_user!.middleName}',
            style: TextStyle(
              color: AppColors.getTextPrimary(context),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    if (_user == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Информация',
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            context,
            icon: Icons.school_outlined,
            title: 'Школа',
            value: _user!.school,
          ),
          _buildInfoCard(
            context,
            icon: Icons.email_outlined,
            title: 'Email',
            value: _user!.email,
          ),
          if (_user!.phone.isNotEmpty)
            _buildInfoCard(
              context,
              icon: Icons.phone_outlined,
              title: 'Телефон',
              value: _user!.phone,
            ),
          if (_user!.birthDate.isNotEmpty)
            _buildInfoCard(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Дата рождения',
              value: _user!.birthDate,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.getAccentColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.getAccentColor(context),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: AppColors.getTextPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Действия',
            style: TextStyle(
              color: AppColors.getTextSecondary(context),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            icon: Icons.edit_outlined,
            title: 'Редактировать профиль',
            onTap: () => _showEditProfileDialog(context),
          ),
          _buildActionCard(
            context,
            icon: Icons.lock_outlined,
            title: 'Изменить пароль',
            onTap: () => _showChangePasswordDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.getAccentColor(context).withOpacity(0.2),
      highlightColor: AppColors.getAccentColor(context).withOpacity(0.1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.getIconColor(context),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.getTextSecondary(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    if (_user == null) return;

    final TextEditingController firstNameController = TextEditingController(text: _user!.firstName);
    final TextEditingController lastNameController = TextEditingController(text: _user!.lastName);
    final TextEditingController middleNameController = TextEditingController(text: _user!.middleName);
    File? selectedAvatar;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getCardColor(context),
          title: Text(
            'Редактировать профиль',
            style: TextStyle(color: AppColors.getTextPrimary(context)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Аватар
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 512,
                      maxHeight: 512,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setDialogState(() {
                        selectedAvatar = File(image.path);
                      });
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.getCardColor(context),
                          border: Border.all(
                            color: AppColors.getAccentColor(context),
                            width: 2,
                          ),
                        ),
                        child: selectedAvatar != null
                            ? ClipOval(
                                child: Image.file(
                                  selectedAvatar!,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              )
                            : _avatarFile != null
                                ? ClipOval(
                                    child: Image.file(
                                      _avatarFile!,
                                      fit: BoxFit.cover,
                                      width: 100,
                                      height: 100,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: AppColors.getIconColor(context),
                                    size: 50,
                                  ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.getAccentColor(context),
                            border: Border.all(
                              color: AppColors.getCardColor(context),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Фамилия
                TextField(
                  controller: lastNameController,
                  style: TextStyle(color: AppColors.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Фамилия',
                    labelStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getAccentColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Имя
                TextField(
                  controller: firstNameController,
                  style: TextStyle(color: AppColors.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Имя',
                    labelStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getAccentColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Отчество
                TextField(
                  controller: middleNameController,
                  style: TextStyle(color: AppColors.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Отчество',
                    labelStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getAccentColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Отмена',
                style: TextStyle(color: AppColors.getTextSecondary(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Сохранить аватарку
                if (selectedAvatar != null) {
                  await AvatarService.saveAvatar(selectedAvatar!);
                }

                // Обновить ФИО
                final updatedUser = _user!.copyWith(
                  firstName: firstNameController.text.trim(),
                  lastName: lastNameController.text.trim(),
                  middleName: middleNameController.text.trim(),
                );

                final success = await DataService.updateUser(updatedUser);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _loadUser();
                    await _loadAvatar();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getAccentColor(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );

    firstNameController.dispose();
    lastNameController.dispose();
    middleNameController.dispose();
  }

  Future<void> _showChangePasswordDialog(BuildContext context) async {
    if (_user == null) return;

    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    bool _isCurrentPasswordVisible = false;
    bool _isNewPasswordVisible = false;
    bool _isConfirmPasswordVisible = false;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.getCardColor(context),
          title: Text(
            'Изменить пароль',
            style: TextStyle(color: AppColors.getTextPrimary(context)),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Текущий пароль
                TextField(
                  controller: currentPasswordController,
                  obscureText: !_isCurrentPasswordVisible,
                  style: TextStyle(color: AppColors.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Текущий пароль',
                    labelStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isCurrentPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.getTextSecondary(context),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getAccentColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Новый пароль
                TextField(
                  controller: newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  style: TextStyle(color: AppColors.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Новый пароль',
                    labelStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.getTextSecondary(context),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getAccentColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Подтверждение пароля
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  style: TextStyle(color: AppColors.getTextPrimary(context)),
                  decoration: InputDecoration(
                    labelText: 'Подтвердите новый пароль',
                    labelStyle: TextStyle(color: AppColors.getTextSecondary(context)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: AppColors.getTextSecondary(context),
                      ),
                      onPressed: () {
                        setDialogState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getTextSecondary(context).withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getAccentColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                currentPasswordController.dispose();
                newPasswordController.dispose();
                confirmPasswordController.dispose();
                Navigator.pop(context);
              },
              child: Text(
                'Отмена',
                style: TextStyle(color: AppColors.getTextSecondary(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Валидация
                if (currentPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Введите текущий пароль'),
                      backgroundColor: Colors.red.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (currentPasswordController.text != _user!.password) {
                  currentPasswordController.dispose();
                  newPasswordController.dispose();
                  confirmPasswordController.dispose();
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Неверный текущий пароль'),
                        backgroundColor: Colors.red.withOpacity(0.9),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  return;
                }

                if (newPasswordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Введите новый пароль'),
                      backgroundColor: Colors.red.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (newPasswordController.text.length < 3) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Пароль должен быть не менее 3 символов'),
                      backgroundColor: Colors.red.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                if (newPasswordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Пароли не совпадают'),
                      backgroundColor: Colors.red.withOpacity(0.9),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                // Обновление пароля
                final updatedUser = _user!.copyWith(
                  password: newPasswordController.text.trim(),
                );

                final success = await DataService.updateUser(updatedUser);
                currentPasswordController.dispose();
                newPasswordController.dispose();
                confirmPasswordController.dispose();

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _loadUser();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Пароль успешно изменен'),
                          backgroundColor: Colors.green.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Ошибка при изменении пароля'),
                          backgroundColor: Colors.red.withOpacity(0.9),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getAccentColor(context),
                foregroundColor: Colors.white,
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
