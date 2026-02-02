import 'package:flutter/material.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/models/user_model.dart';
import 'package:myapp/core/models/school_model.dart';
import 'package:myapp/l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  List<SchoolModel> _schools = [];
  SchoolModel? _selectedSchool;
  bool _isLoadingSchools = false;

  @override
  void initState() {
    super.initState();
    _loadSchools();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadSchools() async {
    setState(() {
      _isLoadingSchools = true;
    });
    final schools = await DataService.getAllSchools();
    if (mounted) {
      setState(() {
        _schools = schools;
        _isLoadingSchools = false;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Проверка существования пользователя по email
      final existingUser = await DataService.getUserByEmail(email);
      if (existingUser != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Пользователь с таким email уже существует'),
              backgroundColor: Colors.red.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Проверка выбора школы
      if (_selectedSchool == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Выберите школу'),
              backgroundColor: Colors.red.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Генерация уникального ID
      final uniqueId = await DataService.generateUniqueUserId();

      // Создание нового пользователя с выбранной школой
      final newUser = UserModel(
        id: uniqueId,
        login: uniqueId, // Используем ID как логин для совместимости
        password: password,
        firstName: '',
        lastName: '',
        middleName: '',
        email: email,
        phone: '',
        birthDate: '',
        school: _selectedSchool!.name,
        className: '',
        createdAt: DateTime.now(),
      );

      try {
        final success = await DataService.createUser(newUser);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.registrationSuccess ?? 'Регистрация успешна! Войдите в аккаунт'),
                backgroundColor: Colors.green.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)?.registrationError ?? 'Ошибка при регистрации. Проверьте подключение к интернету и настройки Firebase.'),
                backgroundColor: Colors.red.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          }
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e, stackTrace) {
        debugPrint('RegisterScreen: Registration error: $e');
        debugPrint('RegisterScreen: Stack trace: $stackTrace');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка при регистрации: ${e.toString()}'),
              backgroundColor: Colors.red.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: AppBar(
        backgroundColor: AppColors.getCardColor(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.getWhite(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)?.register ?? 'Регистрация',
          style: TextStyle(color: AppColors.getTextPrimary(context), fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Builder(
                builder: (context) {
                  final localizations = AppLocalizations.of(context);
                  return Column(
                    children: [
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Введите email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите email';
                          }
                          // Простая проверка формата email
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Введите корректный email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: localizations?.password ?? 'Пароль',
                        hint: localizations?.enterPassword ?? 'Введите пароль',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: _isPasswordVisible,
                        onPasswordVisibilityToggle: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return localizations?.enterPassword ?? 'Введите пароль';
                          }
                          if (value.length < 3) {
                            return localizations?.passwordMinLength ?? 'Пароль должен быть не менее 3 символов';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: localizations?.confirmPassword ?? 'Подтвердите пароль',
                        hint: localizations?.confirmPassword ?? 'Повторите пароль',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isPasswordVisible: _isConfirmPasswordVisible,
                        onPasswordVisibilityToggle: () {
                          setState(() {
                            _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return localizations?.passwordsDoNotMatch ?? 'Пароли не совпадают';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Выбор школы
                      _buildSchoolSelector(context),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.getAccentColor(context),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Builder(
                          builder: (context) {
                            return Text(
                              AppLocalizations.of(context)?.register ?? 'Зарегистрироваться',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onPasswordVisibilityToggle,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: AppColors.getTextPrimary(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: AppColors.getTextSecondary(context),
          fontSize: 16,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.getTextSecondary(context),
          size: 20,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.getTextSecondary(context),
                  size: 20,
                ),
                onPressed: onPasswordVisibilityToggle,
              )
            : null,
        filled: true,
        fillColor: AppColors.getCardColor(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.1),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.getAccentColor(context), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildSchoolSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Школа',
          style: TextStyle(
            color: AppColors.getTextPrimary(context),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _isLoadingSchools
            ? const Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<SchoolModel>(
                value: _selectedSchool,
                decoration: InputDecoration(
                  hintText: 'Выберите школу',
                  hintStyle: TextStyle(
                    color: AppColors.getTextSecondary(context),
                    fontSize: 16,
                  ),
                  prefixIcon: Icon(
                    Icons.school,
                    color: AppColors.getTextSecondary(context),
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.getCardColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.getAccentColor(context),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                items: _schools.map((school) {
                  return DropdownMenuItem<SchoolModel>(
                    value: school,
                    child: Text(
                      school.name,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (school) {
                  setState(() {
                    _selectedSchool = school;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Выберите школу';
                  }
                  return null;
                },
              ),
      ],
    );
  }
}
