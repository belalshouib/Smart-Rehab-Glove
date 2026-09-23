import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import '../services/settings_provider.dart';
import '../services/data_provider.dart';
import '../services/pdf_service.dart';
import 'therapy_screen.dart';

class PatientProfileScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    final patientSessions = dataProvider.sessions
        .where((s) => s['patientId'] == patient['id'])
        .toList();
    double recoveryProgress = 0.0;
    if (patientSessions.isNotEmpty) {
      double totalScore = patientSessions.fold(
        0.0,
        (sum, item) => sum + item['score'],
      );
      recoveryProgress = totalScore / patientSessions.length;
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0D6EFD),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          patient['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: settings.translate(
              'استخراج تقرير طبي',
              'Export Medical Report',
            ),
            onPressed: () {
              PdfService.generateAndShareReport(patient, patientSessions);
            },
          ),
          // زرار الحذف الجديد
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: settings.translate('حذف المريض', 'Delete Patient'),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    backgroundColor: cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    title: Text(
                      settings.translate('تأكيد الحذف', 'Confirm Delete'),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: Text(
                      settings.translate(
                        'هل أنت متأكد من حذف هذا المريض وكل جلساته نهائياً؟',
                        'Are you sure you want to permanently delete this patient and all their sessions?',
                      ),
                      style: TextStyle(color: subTextColor),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(
                          settings.translate('إلغاء', 'Cancel'),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          dataProvider.deletePatient(patient['id']);
                          Navigator.of(context).pop();
                        },
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
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: Color(0xFF0D6EFD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 46,
                      backgroundColor: Color(0xFFE9ECEF),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF0D6EFD),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    patient['name'],
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${settings.translate('العمر:', 'Age:')} ${patient['age']} | ID: ${patient['id']}',
                    style: TextStyle(color: subTextColor),
                  ),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatItem(
                          settings.translate('التشخيص', 'Diagnosis'),
                          patient['diagnosis'],
                          textColor,
                          subTextColor,
                        ),
                        _buildStatItem(
                          settings.translate('الجلسات', 'Sessions'),
                          '${patientSessions.length}',
                          textColor,
                          subTextColor,
                        ),
                        _buildStatItem(
                          settings.translate('التعافي', 'Recovery'),
                          '${(recoveryProgress * 100).toInt()}%',
                          Colors.green,
                          subTextColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              settings.translate(
                                'مستوى التعافي',
                                'Recovery Progress',
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                            Text(
                              '${(recoveryProgress * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0D6EFD),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        LinearPercentIndicator(
                          lineHeight: 12.0,
                          percent: recoveryProgress,
                          animation: true,
                          backgroundColor: isDark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          progressColor: const Color(0xFF0D6EFD),
                          barRadius: const Radius.circular(6),
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '0%',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                            Text(
                              '100%',
                              style: TextStyle(
                                fontSize: 12,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  Align(
                    alignment: settings.language == 'ar'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      settings.translate('الجلسات السابقة', 'Recent Sessions'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (patientSessions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          settings.translate(
                            'لم يقم المريض بأي جلسات بعد',
                            'No sessions recorded yet',
                          ),
                          style: TextStyle(color: subTextColor),
                        ),
                      ),
                    )
                  else
                    ...patientSessions.take(5).map((session) {
                      DateTime date = DateTime.parse(session['date']);
                      String formattedDate = DateFormat(
                        'dd MMM yyyy',
                      ).format(date);
                      String score = '${(session['score'] * 100).toInt()}%';
                      return _buildSessionListTile(
                        formattedDate,
                        '${session['duration']}s',
                        score,
                        cardColor,
                        textColor,
                        subTextColor,
                      );
                    }).toList(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D6EFD),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
              ),
              icon: const Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 28,
              ),
              label: Text(
                settings.translate('بدء جلسة علاج', 'Start Therapy'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TherapyScreen(
                      device: null,
                      initialPatientId: patient['id'],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    Color valueColor,
    Color? titleColor,
  ) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: titleColor)),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionListTile(
    String date,
    String duration,
    String score,
    Color bgColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Duration: $duration',
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ],
              ),
            ],
          ),
          Text(
            score,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
