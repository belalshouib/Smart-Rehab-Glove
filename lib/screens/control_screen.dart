import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothDevice device;
  const ControlScreen({super.key, required this.device});

  @override
  State<ControlScreen> createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  BluetoothCharacteristic? targetCharacteristic;
  bool isReady = false;

  final String targetServiceUuid = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String targetCharacteristicUuid =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  @override
  void initState() {
    super.initState();
    discoverServices();
  }

  void discoverServices() async {
    List<BluetoothService> services = await widget.device.discoverServices();
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
    if (targetCharacteristic != null) {
      await targetCharacteristic!.write(utf8.encode(command));
      if (!mounted) return; // حل إيرور الـ context
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("تم إرسال أمر: $command"),
          duration: const Duration(milliseconds: 500),
          backgroundColor: Colors.teal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceName = widget.device.platformName.isEmpty
        ? "Smart Glove"
        : widget.device.platformName;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: Text(
          deviceName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isReady
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "متصل وجاهز للتحكم",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "التحكم الأساسي",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => sendCommand("CLOSE_ALL"),
                          icon: const Icon(
                            Icons.back_hand,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "قبضة كاملة",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () => sendCommand("OPEN_ALL"),
                          icon: const Icon(Icons.pan_tool, color: Colors.white),
                          label: const Text(
                            "فتح اليد",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "تحكم الأصابع (Rehab Exercises)",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 2.5,
                      children: [
                        _fingerButton("تمرين الإبهام", "THUMB"),
                        _fingerButton("تمرين السبابة", "INDEX"),
                        _fingerButton("تمرين الوسطى", "MIDDLE"),
                        _fingerButton("تمرين البنصر", "RING"),
                        _fingerButton("تمرين الخنصر", "PINKY"),
                        _fingerButton(
                          "روتين تلقائي",
                          "AUTO",
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.blueAccent),
                  SizedBox(height: 20),
                  Text(
                    "جاري تهيئة قنوات الاتصال بالجوانتي...",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }

  // دالة صغيرة بترسم شكل زراير الأصابع عشان الكود ميبقاش زحمة
  Widget _fingerButton(
    String title,
    String command, {
    Color color = Colors.teal,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () => sendCommand(command),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }
}
