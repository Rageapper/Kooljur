import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/core/theme/app_colors.dart';
import 'package:myapp/core/services/data_service.dart';
import 'package:myapp/core/services/fcm_service.dart';
import 'package:myapp/screens/register_screen.dart';
import 'package:myapp/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLoginMode) {
        // Проверка через DataService по email
        final user = await DataService.getUserByEmail(email);
        if (user != null && user.password == password) {
          // Сохраняем текущего пользователя
          debugPrint('LoginScreen: User found - ID: ${user.id}, Email: ${user.email}');
          await DataService.setCurrentUserId(user.id);
          final savedUserId = await DataService.getCurrentUserId();
          debugPrint('LoginScreen: Saved current user ID: $savedUserId');
          
          // Инициализируем FCM для получения уведомлений
          try {
            await FCMService.initialize();
          } catch (e) {
            debugPrint('LoginScreen: FCM initialization error: $e');
          }
          
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/Frame1',
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Неверный email или пароль'),
                backgroundColor: Colors.red.withOpacity(0.9),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      } else {
        // Регистрация - переход на экран регистрации
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterScreen()),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Минималистичный логотип
                    Container(
                      width: 64,
                      height: 64,
                      margin: const EdgeInsets.only(bottom: 48),
                      decoration: BoxDecoration(
                        color: AppColors.getAccentColor(context).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.school,
                        color: AppColors.getAccentColor(context),
                        size: 32,
                      ),
                    ),
                    
                    // Заголовок
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.of(context);
                        return Column(
                          children: [
                            Text(
                              _isLoginMode 
                                  ? (localizations?.login ?? 'Вход')
                                  : (localizations?.register ?? 'Регистрация'),
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _isLoginMode
                                  ? (localizations?.enterAccount ?? 'Войдите в свой аккаунт')
                                  : (localizations?.createAccount ?? 'Создайте новый аккаунт'),
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    
                    // Поле email
                    Builder(
                      builder: (context) {
                        return _buildTextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          label: 'Email',
                          hint: 'Введите email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
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
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Поле пароля
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.of(context);
                        return _buildTextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          label: localizations?.password ?? 'Пароль',
                          hint: localizations?.enterPassword ?? 'Введите пароль',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          isPasswordVisible: _isPasswordVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSubmit(),
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
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // Кнопка входа/регистрации
                    _buildSubmitButton(),
                    const SizedBox(height: 24),
                    
                    // Переключение между входом и регистрацией
                    Builder(
                      builder: (context) {
                        final localizations = AppLocalizations.of(context);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLoginMode
                                  ? (localizations?.noAccount ?? 'Нет аккаунта? ')
                                  : (localizations?.haveAccount ?? 'Уже есть аккаунт? '),
                              style: TextStyle(
                                color: AppColors.getTextSecondary(context),
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_isLoginMode) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                } else {
                                  setState(() {
                                    _isLoginMode = true;
                                    _emailController.clear();
                                    _passwordController.clear();
                                  });
                                }
                              },
                              child: Text(
                                _isLoginMode 
                                    ? (localizations?.register ?? 'Зарегистрироваться')
                                    : (localizations?.login ?? 'Войти'),
                                style: TextStyle(
                                  color: AppColors.getAccentColor(context),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? onPasswordVisibilityToggle,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword && !isPasswordVisible,
      keyboardType: keyboardType,
      validator: validator,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: TextStyle(
        color: AppColors.getTextPrimary(context),
        fontSize: 16,
      ),
      decoration: InputDecoration(
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

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.getAccentColor(context),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
                  final localizations = AppLocalizations.of(context);
                  return Text(
                    _isLoginMode 
                        ? (localizations?.login ?? 'Войти')
                        : (localizations?.register ?? 'Зарегистрироваться'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
      ),
    );
  }
}
