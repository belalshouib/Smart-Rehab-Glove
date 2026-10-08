import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import 'main_layout.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                settings.translate('إنشاء حساب جديد 🚀', 'Create Account 🚀'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                settings.translate(
                  'انضم إلينا وابدأ رحلة التعافي',
                  'Join us and start your recovery journey',
                ),
                style: TextStyle(fontSize: 16, color: subTextColor),
              ),
              const SizedBox(height: 40),

              // حقل الاسم
              _buildTextField(
                label: settings.translate('الاسم بالكامل', 'Full Name'),
                icon: Icons.person_outline,
                cardColor: cardColor,
                textColor: textColor,
                hint: settings.translate('مثال: بلال', 'e.g: Belal'),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 40),

              // زرار إنشاء الحساب
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
                    // مؤقتاً بينقل للداشبورد
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MainLayout(),
                      ),
                      (route) => false,
                    );
                  },
                  child: Text(
                    settings.translate('إنشاء حساب', 'Sign Up'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    settings.translate(
                      'لديك حساب بالفعل؟',
                      'Already have an account?',
                    ),
                    style: TextStyle(color: subTextColor),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      settings.translate('تسجيل الدخول', 'Login'),
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
}
