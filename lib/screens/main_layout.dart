import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../services/data_provider.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'patients_screen.dart'; // ضفنا المرضى هنا
import 'settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), // 0
    const PatientsScreen(), // 1
    const HomeScreen(), // 2
    const SettingsScreen(), // 3
  ];

  // للتحكم في الحقول وقت الإضافة من الزرار العائم
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();

  // نافذة إضافة مريض جديد
  void _showAddPatientSheet(
    BuildContext context,
    DataProvider dataProvider,
    SettingsProvider settings,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: settings.isDarkMode
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                settings.translate('إضافة مريض جديد', 'Add New Patient'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: settings.translate('اسم المريض', 'Patient Name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: settings.translate('العمر', 'Age'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _diagnosisController,
                decoration: InputDecoration(
                  labelText: settings.translate(
                    'التشخيص (مثال: جلطة، كسر)',
                    'Diagnosis',
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D6EFD),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: () {
                    if (_nameController.text.isNotEmpty &&
                        _ageController.text.isNotEmpty &&
                        _diagnosisController.text.isNotEmpty) {
                      dataProvider.addPatient(
                        _nameController.text,
                        int.parse(_ageController.text),
                        _diagnosisController.text,
                      );
                      _nameController.clear();
                      _ageController.clear();
                      _diagnosisController.clear();
                      Navigator.pop(context); // قفل النافذة

                      // بعد ما تحفظ، البرنامج هينقلك لشاشة المرضى أوتوماتيك عشان تشوف المريض الجديد
                      setState(() {
                        _currentIndex = 1;
                      });
                    }
                  },
                  child: Text(
                    settings.translate('حفظ الملف', 'Save Profile'),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final isDark = settings.isDarkMode;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      // ربطنا زرار (+) بالدالة بتاعت الإضافة
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPatientSheet(context, dataProvider, settings),
        backgroundColor: const Color(0xFF0D6EFD),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildNavItem(
                    Icons.home_filled,
                    settings.translate('الرئيسية', 'Home'),
                    0,
                    isDark,
                  ),
                  _buildNavItem(
                    Icons.people_alt,
                    settings.translate('المرضى', 'Patients'),
                    1,
                    isDark,
                  ),
                ],
              ),
              Row(
                children: [
                  _buildNavItem(
                    Icons.bluetooth,
                    settings.translate('اتصال', 'Connect'),
                    2,
                    isDark,
                  ),
                  _buildNavItem(
                    Icons.settings,
                    settings.translate('الإعدادات', 'Settings'),
                    3,
                    isDark,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? const Color(0xFF0D6EFD) : Colors.grey;

    return MaterialButton(
      minWidth: 80,
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
