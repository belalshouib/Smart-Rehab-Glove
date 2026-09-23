import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
        title: Text(
          settings.translate('الإعدادات', 'Settings'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // كارت الملف الشخصي (Profile Card)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF0D6EFD),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Engineering Student',
                        style: TextStyle(fontSize: 14, color: subTextColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // قائمة الإعدادات
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    Icons.person_outline,
                    settings.translate('الملف الشخصي', 'Profile'),
                    textColor,
                    subTextColor,
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    Icons.back_hand_outlined,
                    settings.translate('إعدادات الجوانتي', 'Glove Settings'),
                    textColor,
                    subTextColor,
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    Icons.bluetooth,
                    settings.translate('البلوتوث', 'Bluetooth'),
                    textColor,
                    subTextColor,
                    trailingText: settings.translate('متصل', 'Connected'),
                    trailingColor: Colors.green,
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    Icons.notifications_outlined,
                    settings.translate('الإشعارات', 'Notifications'),
                    textColor,
                    subTextColor,
                  ),
                  _buildDivider(isDark),
                  // زرار الدارك مود
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF1F5F9),
                      child: Icon(Icons.dark_mode, color: Color(0xFF475569)),
                    ),
                    title: Text(
                      settings.translate('الوضع الداكن', 'Dark Mode'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    trailing: Switch(
                      value: settings.isDarkMode,
                      activeColor: const Color(0xFF0D6EFD),
                      onChanged: (value) {
                        settings.toggleTheme();
                      },
                    ),
                  ),
                  _buildDivider(isDark),
                  // زرار تغيير اللغة
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF1F5F9),
                      child: Icon(Icons.language, color: Color(0xFF475569)),
                    ),
                    title: Text(
                      settings.translate('اللغة العربية', 'Arabic Language'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    trailing: Switch(
                      value: settings.language == 'ar',
                      activeColor: const Color(0xFF0D6EFD),
                      onChanged: (value) {
                        settings.changeLanguage(value ? 'ar' : 'en');
                      },
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    Icons.info_outline,
                    settings.translate('عن التطبيق', 'About App'),
                    textColor,
                    subTextColor,
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    Icons.logout,
                    settings.translate('تسجيل الخروج', 'Logout'),
                    Colors.redAccent,
                    subTextColor,
                    iconColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Text(
              'Smart Rehab Glove v1.0.0',
              style: TextStyle(color: subTextColor, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    Color textColor,
    Color? subTextColor, {
    String? trailingText,
    Color? trailingColor,
    Color iconColor = const Color(0xFF475569),
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFF1F5F9),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: TextStyle(
                color: trailingColor ?? subTextColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (trailingText != null) const SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios, size: 16, color: subTextColor),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }
}
