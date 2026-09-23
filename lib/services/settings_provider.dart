import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  String _language = 'ar'; // اللغة الافتراضية عربي

  bool get isDarkMode => _isDarkMode;
  String get language => _language;

  SettingsProvider() {
    _loadSettings();
  }

  // تحميل الإعدادات المحفوظة
  void _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _language = prefs.getString('language') ?? 'ar';
    notifyListeners();
  }

  // تغيير المظهر (Dark/Light)
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // تغيير اللغة
  void changeLanguage(String langCode) async {
    _language = langCode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('language', _language);
    notifyListeners();
  }

  // دالة صغيرة للترجمة (هتسهل علينا جداً في التصميم)
  String translate(String arText, String enText) {
    return _language == 'ar' ? arText : enText;
  }
}
