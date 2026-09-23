import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/settings_provider.dart';
import '../services/data_provider.dart';

class TherapyScreen extends StatefulWidget {
  final BluetoothDevice? device;
  final String? initialPatientId;

  const TherapyScreen({super.key, this.device, this.initialPatientId});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen> {
  BluetoothCharacteristic? targetCharacteristic;
  bool isReady = false;
  final String targetServiceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String targetCharacteristicUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  List<double> _fingerValues = [0.0, 0.0, 0.0, 0.0, 0.0];
  double _gripValue = 0.0; // متغير قوة القبضة الجديد
  final Random _random = Random();

  String? selectedPatientId;

  @override
  void initState() {
    super.initState();
    selectedPatientId = widget.initialPatientId;

    if (widget.device != null) {
      discoverServices();
    } else {
      setState(() {
        isReady = true;
      });
    }
  }

  void discoverServices() async {
    List<BluetoothService> services = await widget.device!.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == targetServiceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == targetCharacteristicUuid) {
            if (mounted) {
              setState(() {
                targetCharacteristic = characteristic;
                isReady = true;
              });
            }
          }
        }
      }
    }
  }

  void sendCommand(String command) async {
    if (targetCharacteristic != null && widget.device != null) {
      await targetCharacteristic!.write(utf8.encode(command));
    }
  }

  void _startSession() {
    if (!_isRunning) {
      setState(() => _isRunning = true);
      sendCommand("AUTO");

      _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        if (mounted) {
          setState(() {
            _seconds++;
            for (int i = 0; i < _fingerValues.length; i++) {
              _fingerValues[i] = 0.4 + (_random.nextDouble() * 0.6);
            }
            // توليد قراءة عشوائية لقوة القبضة (لحد ما نربط السنسور الحقيقي)
            _gripValue = 0.3 + (_random.nextDouble() * 0.7);
          });
        }
      });
    }
  }

  void _pauseSession() {
    if (_isRunning) {
      setState(() => _isRunning = false);
      _timer?.cancel();
      sendCommand("PAUSE");
    }
  }

  void _stopSession(DataProvider dataProvider) {
    if (_seconds > 0) {
      double avgScore = _fingerValues.reduce((a, b) => a + b) / 5;
      if (avgScore == 0.0) avgScore = 0.85;
      if (avgScore > 1.0) avgScore = 1.0;

      String pId = selectedPatientId ?? 'guest_id';
      String pName = 'مريض غير معروف';

      if (selectedPatientId != null) {
        var patient = dataProvider.patients.firstWhere(
          (p) => p['id'] == selectedPatientId,
          orElse: () => {},
        );
        if (patient.isNotEmpty) {
          pName = patient['name'];
        }
      }

      dataProvider.addSession(pId, pName, _seconds, avgScore, _fingerValues);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("تم حفظ الجلسة بنجاح!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    }

    setState(() {
      _isRunning = false;
      _seconds = 0;
      _fingerValues = [0.0, 0.0, 0.0, 0.0, 0.0];
      _gripValue = 0.0;
    });
    _timer?.cancel();
    sendCommand("STOP");
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.device?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final isDark = settings.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (selectedPatientId == null && dataProvider.patients.isNotEmpty) {
      selectedPatientId = dataProvider.patients[0]['id'];
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          settings.translate('جلسة العلاج', 'Therapy Session'),
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
        centerTitle: true,
      ),
      body: isReady
          ? Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
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
                        Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Color(0xFF0D6EFD),
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                dataProvider.patients.isEmpty
                                    ? Text(
                                        settings.translate(
                                          'لا يوجد مرضى',
                                          'No Patients',
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      )
                                    : DropdownButton<String>(
                                        value: selectedPatientId,
                                        underline: const SizedBox(),
                                        icon: Icon(
                                          Icons.keyboard_arrow_down,
                                          color: textColor,
                                        ),
                                        dropdownColor: cardColor,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontSize: 14,
                                        ),
                                        items: dataProvider.patients.map((
                                          patient,
                                        ) {
                                          return DropdownMenuItem<String>(
                                            value: patient['id'],
                                            child: Text(patient['name']),
                                          );
                                        }).toList(),
                                        onChanged: _isRunning
                                            ? null
                                            : (value) {
                                                setState(() {
                                                  selectedPatientId = value;
                                                });
                                              },
                                      ),
                                Text(
                                  widget.device == null
                                      ? 'وضع التجربة'
                                      : settings.translate('متصل', 'Connected'),
                                  style: TextStyle(
                                    color: widget.device == null
                                        ? Colors.orange
                                        : Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          _formatTime(_seconds),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    settings.translate(
                      'التتبع الحيوي للأصابع',
                      'Live Hand Tracking',
                    ),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 10,
                    ),
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
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildVisualFinger(
                            _fingerValues[0],
                            70,
                            settings.translate('إبهام', 'Thumb'),
                            const Color(0xFF0D6EFD),
                          ),
                          _buildVisualFinger(
                            _fingerValues[1],
                            110,
                            settings.translate('سبابة', 'Index'),
                            const Color(0xFF0D6EFD),
                          ),
                          _buildVisualFinger(
                            _fingerValues[2],
                            130,
                            settings.translate('وسطى', 'Middle'),
                            const Color(0xFF0D6EFD),
                          ),
                          _buildVisualFinger(
                            _fingerValues[3],
                            115,
                            settings.translate('بنصر', 'Ring'),
                            const Color(0xFF0D6EFD),
                          ),
                          _buildVisualFinger(
                            _fingerValues[4],
                            85,
                            settings.translate('خنصر', 'Pinky'),
                            const Color(0xFF0D6EFD),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Expanded(
                    child: Container(
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
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFingerProgress(
                              settings.translate('الإبهام', 'Thumb'),
                              _fingerValues[0],
                              textColor,
                            ),
                            const SizedBox(height: 15),
                            _buildFingerProgress(
                              settings.translate('السبابة', 'Index'),
                              _fingerValues[1],
                              textColor,
                            ),
                            const SizedBox(height: 15),
                            _buildFingerProgress(
                              settings.translate('الوسطى', 'Middle'),
                              _fingerValues[2],
                              textColor,
                            ),
                            const SizedBox(height: 15),
                            _buildFingerProgress(
                              settings.translate('البنصر', 'Ring'),
                              _fingerValues[3],
                              textColor,
                            ),
                            const SizedBox(height: 15),
                            _buildFingerProgress(
                              settings.translate('الخنصر', 'Pinky'),
                              _fingerValues[4],
                              textColor,
                            ),

                            const SizedBox(height: 20),
                            Divider(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[300],
                            ),
                            const SizedBox(height: 15),

                            // مؤشر قوة القبضة الجديد (Grip Strength) بلون مختلف
                            _buildGripStrengthIndicator(
                              settings.translate('قوة القبضة', 'Grip Strength'),
                              _gripValue,
                              textColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: Icons.play_arrow,
                        label: settings.translate('ابدأ', 'Start'),
                        color: Colors.green,
                        onTap: _startSession,
                        isActive: !_isRunning,
                      ),
                      _buildControlButton(
                        icon: Icons.pause,
                        label: settings.translate('إيقاف مؤقت', 'Pause'),
                        color: Colors.orange,
                        onTap: _pauseSession,
                        isActive: _isRunning,
                      ),
                      _buildControlButton(
                        icon: Icons.stop,
                        label: settings.translate('إنهاء', 'Stop'),
                        color: Colors.red,
                        onTap: () => _stopSession(dataProvider),
                        isActive: _seconds > 0,
                      ),
                    ],
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    settings.translate(
                      'جاري الاتصال بالجوانتي...',
                      'Connecting to glove...',
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildVisualFinger(
    double value,
    double maxHeight,
    String label,
    Color activeColor,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${(value * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 35,
          height: maxHeight,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.3), width: 1),
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 35,
            height: maxHeight * value,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [activeColor.withOpacity(0.6), activeColor],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildFingerProgress(String label, double percent, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 8.0,
            percent: percent,
            animation: true,
            animateFromLastPercent: true,
            animationDuration: 800,
            backgroundColor: Colors.grey.withOpacity(0.2),
            progressColor: const Color(0xFF0D6EFD),
            barRadius: const Radius.circular(5),
          ),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '${(percent * 100).toInt()}%',
            textAlign: TextAlign.right,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  // دالة جديدة مخصصة لقوة القبضة بتصميم أعرض ولون مختلف
  Widget _buildGripStrengthIndicator(
    String label,
    double percent,
    Color textColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 15,
              ),
            ),
            Text(
              '${(percent * 100).toInt()}%',
              style: TextStyle(
                color: Colors.amber[700],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        LinearPercentIndicator(
          lineHeight: 14.0, // أعرض من صوابع الإيد
          percent: percent,
          animation: true,
          animateFromLastPercent: true,
          animationDuration: 800,
          backgroundColor: Colors.grey.withOpacity(0.2),
          progressColor: Colors.amber[600], // لون برتقالي/ذهبي لتمييز القوة
          barRadius: const Radius.circular(8),
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isActive,
  }) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.5,
      child: InkWell(
        onTap: isActive ? onTap : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
