import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import 'signup_screen.dart';
import 'main_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // اللوجو أو الأيقونة
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D6EFD).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.back_hand,
                    size: 60,
                    color: Color(0xFF0D6EFD),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                settings.translate('مرحباً بعودتك 👋', 'Welcome Back 👋'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                settings.translate(
                  'سجل دخولك لمتابعة جلسات التأهيل',
                  'Sign in to continue your therapy sessions',
                ),
                style: TextStyle(fontSize: 16, color: subTextColor),
              ),
              const SizedBox(height: 40),

              // حقل الإيميل
              _buildTextField(
                label: settings.translate('البريد الإلكتروني', 'Email'),
                icon: Icons.email_outlined,
                cardColor: cardColor,
                textColor: textColor,
                hint: 'example@gmail.com',
              ),
              const SizedBox(height: 20),

              // حقل الباسورد
              _buildTextField(
                label: settings.translate('كلمة المرور', 'Password'),
                icon: Icons.lock_outline,
                cardColor: cardColor,
                textColor: textColor,
                isPassword: true,
                hint: '••••••••',
              ),
              const SizedBox(height: 15),

              // نسيت كلمة المرور؟
              Align(
                alignment: settings.language == 'ar'
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    settings.translate('نسيت كلمة المرور؟', 'Forgot Password?'),
                    style: const TextStyle(
                      color: Color(0xFF0D6EFD),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              // زرار الدخول الأساسي
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    // مؤقتاً بينقل للداشبورد مباشرة لحد ما نربط الفايربيز
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainLayout(),
                      ),
                    );
                  },
                  child: Text(
                    settings.translate('تسجيل الدخول', 'Login'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // الخط الفاصل
              Row(
                children: [
                  Expanded(
                    child: Divider(color: subTextColor?.withValues(alpha: 0.3)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      settings.translate(
                        'أو الدخول بواسطة',
                        'Or continue with',
                      ),
                      style: TextStyle(color: subTextColor, fontSize: 14),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: subTextColor?.withValues(alpha: 0.3)),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // زراير جوجل وفيسبوك
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(
                    Icons.g_mobiledata,
                    cardColor,
                    const Color(0xFFDB4437),
                  ),
                  const SizedBox(width: 20),
                  _buildSocialButton(
                    Icons.facebook,
                    cardColor,
                    const Color(0xFF4267B2),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // الانتقال لإنشاء حساب
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    settings.translate(
                      'ليس لديك حساب؟',
                      'Don\'t have an account?',
                    ),
                    style: TextStyle(color: subTextColor),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Text(
                      settings.translate('إنشاء حساب', 'Sign Up'),
                      style: const TextStyle(
                        color: Color(0xFF0D6EFD),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required Color cardColor,
    required Color textColor,
    bool isPassword = false,
    required String hint,
  }) {
    return TextField(
      obscureText: isPassword && !_isPasswordVisible,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF0D6EFD)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF0D6EFD), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 35, color: iconColor),
        onPressed: () {},
        padding: const EdgeInsets.all(12),
      ),
    );
  }
}
