import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_provider.dart';
import '../services/data_provider.dart';
import 'patient_profile_screen.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String searchQuery = '';
  String selectedFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final isDark = settings.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    var filteredPatients = dataProvider.patients.where((patient) {
      final nameMatches = patient['name'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final idMatches = patient['id'].toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      return nameMatches || idMatches;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          settings.translate('ملفات المرضى', 'Patients'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: settings.translate(
                  'بحث بالاسم أو الـ ID...',
                  'Search patients...',
                ),
                hintStyle: TextStyle(color: subTextColor),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0D6EFD)),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                _buildFilterChip(
                  settings.translate('الكل', 'All Patients'),
                  'all',
                  cardColor,
                  textColor,
                ),
                const SizedBox(width: 10),
                _buildFilterChip(
                  settings.translate('النشطون', 'Active'),
                  'active',
                  cardColor,
                  textColor,
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: filteredPatients.isEmpty
                  ? Center(
                      child: Text(
                        settings.translate(
                          'لا يوجد مرضى مطابقة للبحث',
                          'No patients found',
                        ),
                        style: TextStyle(color: subTextColor),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredPatients.length,
                      itemBuilder: (context, index) {
                        final patient = filteredPatients[index];

                        // هنا ضفنا الـ Dismissible اللي بتعمل ميزة السحب
                        return Dismissible(
                          key: Key(patient['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: settings.language == 'ar'
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete_sweep,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  title: Text(
                                    settings.translate(
                                      'تأكيد الحذف',
                                      'Confirm Delete',
                                    ),
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: Text(
                                    settings.translate(
                                      'هل أنت متأكد من حذف هذا المريض وكل جلساته؟',
                                      'Are you sure you want to delete this patient and all sessions?',
                                    ),
                                    style: TextStyle(color: subTextColor),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: Text(
                                        settings.translate('إلغاء', 'Cancel'),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: Text(
                                        settings.translate('حذف', 'Delete'),
                                        style: const TextStyle(
                                          color: Colors.redAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          onDismissed: (direction) {
                            dataProvider.deletePatient(patient['id']);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  settings.translate(
                                    'تم حذف المريض',
                                    'Patient deleted',
                                  ),
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          },
                          child: Card(
                            color: cardColor,
                            margin: const EdgeInsets.only(bottom: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 2,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(15),
                              leading: const CircleAvatar(
                                radius: 25,
                                backgroundColor: Color(0xFFE9ECEF),
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xFF0D6EFD),
                                  size: 30,
                                ),
                              ),
                              title: Text(
                                patient['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: textColor,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 5),
                                  Text(
                                    '${settings.translate('العمر:', 'Age:')} ${patient['age']} | ID: ${patient['id']}',
                                    style: TextStyle(color: subTextColor),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${settings.translate('التشخيص:', 'Diagnosis:')} ${patient['diagnosis']}',
                                    style: TextStyle(
                                      color: const Color(0xFF0D6EFD),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PatientProfileScreen(patient: patient),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    Color cardColor,
    Color textColor,
  ) {
    bool isSelected = selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: const Color(0xFF0D6EFD),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : textColor,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: cardColor,
      onSelected: (bool selected) {
        setState(() => selectedFilter = value);
      },
    );
  }
}
