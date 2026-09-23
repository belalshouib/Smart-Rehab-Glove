import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/settings_provider.dart';
import '../services/data_provider.dart';
import 'reports_screen.dart'; // سحبنا شاشة التقارير هنا

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    double todayProgress = dataProvider.getTodayProgress();
    String totalHours = dataProvider.getTotalTherapyHours();
    int totalSessions = dataProvider.sessions.length;

    bool hasFirstStepBadge = totalSessions >= 1;
    bool hasIronDisciplineBadge = totalSessions >= 5;
    bool hasDayFinisherBadge = todayProgress >= 1.0;

    List<Map<String, dynamic>> uniqueRecentSessions = [];
    Set<String> seenPatients = {};
    for (var session in dataProvider.sessions) {
      if (!seenPatients.contains(session['patientId'])) {
        uniqueRecentSessions.add(session);
        seenPatients.add(session['patientId']);
      }
      if (uniqueRecentSessions.length == 5) break;
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الهيدر
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF0D6EFD),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            settings.translate('صباح الخير،', 'Good Morning,'),
                            style: TextStyle(fontSize: 14, color: subTextColor),
                          ),
                          Text(
                            'بلال 👋',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    Icons.notifications_outlined,
                    size: 30,
                    color: textColor,
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // الإحصائيات العلوية
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      settings.translate('إجمالي الجلسات', 'Total Sessions'),
                      '$totalSessions',
                      Icons.fitness_center,
                      Colors.orange,
                      cardColor,
                      textColor,
                      subTextColor,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      settings.translate('وقت التأهيل', 'Therapy Time'),
                      '$totalHours h',
                      Icons.timer,
                      Colors.purple,
                      cardColor,
                      textColor,
                      subTextColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // ==========================================
              // التقدم الأسبوعي (تم إضافة زرار عرض التقارير)
              // ==========================================
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
                            'التقدم الأسبوعي',
                            'Weekly Progress',
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // النقل لشاشة التقارير
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReportsScreen(),
                              ),
                            );
                          },
                          child: Text(
                            settings.translate('عرض الكل', 'View All'),
                            style: const TextStyle(
                              color: Color(0xFF0D6EFD),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  const days = [
                                    'Sat',
                                    'Sun',
                                    'Mon',
                                    'Tue',
                                    'Wed',
                                    'Thu',
                                    'Fri',
                                  ];
                                  if (value.toInt() >= 0 &&
                                      value.toInt() < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        days[value.toInt()],
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                                reservedSize: 22,
                              ),
                            ),
                            leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 20),
                                FlSpot(1, 40),
                                FlSpot(2, 35),
                                FlSpot(3, 60),
                                FlSpot(4, 55),
                                FlSpot(5, 80),
                                FlSpot(6, 85),
                              ],
                              isCurved: true,
                              color: const Color(0xFF0D6EFD),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(
                                  0xFF0D6EFD,
                                ).withOpacity(0.15),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // الرسم الدائري والأعمدة
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 220,
                      padding: const EdgeInsets.all(15),
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
                          Text(
                            settings.translate(
                              'توزيع التعافي',
                              'Recovery Dist.',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 25,
                                sections: [
                                  PieChartSectionData(
                                    color: const Color(0xFF0D6EFD),
                                    value: 60,
                                    title: '60%',
                                    radius: 20,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: 30,
                                    title: '30%',
                                    radius: 20,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: 10,
                                    title: '10%',
                                    radius: 20,
                                    titleStyle: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildLegendItem(
                                Colors.blue,
                                settings.translate('ممتاز', 'Excellent'),
                                subTextColor,
                              ),
                              const SizedBox(width: 5),
                              _buildLegendItem(
                                Colors.green,
                                settings.translate('جيد', 'Good'),
                                subTextColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 220,
                      padding: const EdgeInsets.all(15),
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
                          Text(
                            settings.translate(
                              'جلسات الأسبوع',
                              'Sessions Week',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 10,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                            const style = TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 10,
                                            );
                                            Widget text;
                                            switch (value.toInt()) {
                                              case 0:
                                                text = const Text(
                                                  'S',
                                                  style: style,
                                                );
                                                break;
                                              case 1:
                                                text = const Text(
                                                  'S',
                                                  style: style,
                                                );
                                                break;
                                              case 2:
                                                text = const Text(
                                                  'M',
                                                  style: style,
                                                );
                                                break;
                                              case 3:
                                                text = const Text(
                                                  'T',
                                                  style: style,
                                                );
                                                break;
                                              case 4:
                                                text = const Text(
                                                  'W',
                                                  style: style,
                                                );
                                                break;
                                              case 5:
                                                text = const Text(
                                                  'T',
                                                  style: style,
                                                );
                                                break;
                                              case 6:
                                                text = const Text(
                                                  'F',
                                                  style: style,
                                                );
                                                break;
                                              default:
                                                text = const Text(
                                                  '',
                                                  style: style,
                                                );
                                                break;
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              child: text,
                                            );
                                          },
                                    ),
                                  ),
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: const FlGridData(show: false),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  _buildBarGroup(0, 4),
                                  _buildBarGroup(1, 6),
                                  _buildBarGroup(2, 3),
                                  _buildBarGroup(3, 7),
                                  _buildBarGroup(4, 5),
                                  _buildBarGroup(5, 8),
                                  _buildBarGroup(6, 2),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // إنجازات البطل
              Text(
                settings.translate('إنجازات البطل 🏆', 'Hero Achievements 🏆'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildBadge(
                      title: settings.translate('بداية قوية', 'Strong Start'),
                      subtitle: settings.translate('أول جلسة', '1st Session'),
                      icon: Icons.star_rounded,
                      activeColor: Colors.orange,
                      isEarned: hasFirstStepBadge,
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 15),
                    _buildBadge(
                      title: settings.translate(
                        'التزام حديدي',
                        'Iron Discipline',
                      ),
                      subtitle: settings.translate('5 جلسات', '5 Sessions'),
                      icon: Icons.shield,
                      activeColor: Colors.blueAccent,
                      isEarned: hasIronDisciplineBadge,
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                    const SizedBox(width: 15),
                    _buildBadge(
                      title: settings.translate('بطل اليوم', 'Day Finisher'),
                      subtitle: settings.translate('100% اكتمل', '100% Done'),
                      icon: Icons.emoji_events,
                      activeColor: Colors.amber,
                      isEarned: hasDayFinisherBadge,
                      cardColor: cardColor,
                      textColor: textColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // نشاط المرضى
              Text(
                settings.translate(
                  'نشاط المرضى مؤخراً',
                  'Recent Patients Activity',
                ),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 15),

              if (uniqueRecentSessions.isEmpty)
                Center(
                  child: Text(
                    settings.translate(
                      'لا توجد جلسات سابقة.',
                      'No recent sessions.',
                    ),
                    style: TextStyle(color: subTextColor),
                  ),
                )
              else
                ...uniqueRecentSessions.map((session) {
                  DateTime date = DateTime.parse(session['date']);
                  String formattedDate = DateFormat(
                    'dd MMM yyyy - hh:mm a',
                  ).format(date);
                  String score = '${(session['score'] * 100).toInt()}%';
                  return _buildSessionCard(
                    session['patientName'],
                    formattedDate,
                    score,
                    session['score'],
                    cardColor,
                    textColor,
                    subTextColor,
                  );
                }).toList(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, Color? textColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 10, color: textColor)),
      ],
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF0D6EFD),
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color activeColor,
    required bool isEarned,
    required Color cardColor,
    required Color textColor,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEarned ? activeColor.withOpacity(0.5) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: isEarned
                    ? activeColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.1),
                child: Icon(
                  icon,
                  size: 30,
                  color: isEarned ? activeColor : Colors.grey.withOpacity(0.4),
                ),
              ),
              if (!isEarned)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock, size: 12, color: Colors.grey),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isEarned ? textColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
    Color cardColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 35, color: iconColor),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 12, color: subTextColor)),
          const SizedBox(height: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(
    String name,
    String date,
    String scoreText,
    double scoreVal,
    Color bgColor,
    Color textColor,
    Color? subTextColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFE9ECEF),
                child: Icon(Icons.person_outline, color: Colors.black54),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(fontSize: 12, color: subTextColor),
                  ),
                ],
              ),
            ],
          ),
          CircularPercentIndicator(
            radius: 22.0,
            lineWidth: 4.0,
            percent: scoreVal,
            center: Text(
              scoreText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            progressColor: Colors.green,
            backgroundColor: Colors.grey.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
        ],
      ),
    );
  }
}
