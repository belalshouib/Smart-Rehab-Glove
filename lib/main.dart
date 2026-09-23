import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart'; // سحبنا شاشة البداية
import 'services/settings_provider.dart';
import 'services/data_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // بنقرا الإعدادات من الـ Provider عشان نطبق الدارك مود واللغة
    final settings = Provider.of<SettingsProvider>(context);

    return MaterialApp(
      title: 'Smart Rehab Glove',
      debugShowCheckedModeBanner: false,

      // تفعيل الاتجاه (من اليمين للشمال أو العكس حسب اللغة)
      builder: (context, child) {
        return Directionality(
          textDirection: settings.language == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: child!,
        );
      },

      // تفعيل المظهر (Dark Mode / Light Mode)
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xFF0D6EFD), // اللون الأزرق الأساسي
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0D6EFD),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),

      // نقطة البداية (الشاشة الافتتاحية)
      home: const SplashScreen(),
    );
  }
}
