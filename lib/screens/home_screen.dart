import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'therapy_screen.dart'; // دي شاشة الجلسة

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ScanResult> scanResults = [];
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.isScanning.listen((state) {
      if (mounted) {
        setState(() {
          isScanning = state;
        });
      }
    });

    FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          scanResults = results;
        });
      }
    });
  }

  void startScan() async {
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Smart Rehab Glove',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ======== الزرار الجديد (زرار وضع التجربة) ========
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.science, color: Colors.white),
              label: const Text(
                "تخطي واختبار الجلسات (Test Mode)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  // بنبعت device: null عشان إحنا بنجرب من غير هاردوير
                  MaterialPageRoute(
                    builder: (context) => const TherapyScreen(device: null),
                  ),
                );
              },
            ),
          ),

          // ===================================================
          const SizedBox(height: 10),
          Icon(
            isScanning ? Icons.bluetooth_searching : Icons.bluetooth,
            size: 80,
            color: isScanning ? Colors.blueAccent : Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            isScanning
                ? "جاري البحث عن الجوانتي..."
                : "اضغط على الزر للبحث عن الجوانتي",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: scanResults.length,
              itemBuilder: (context, index) {
                final device = scanResults[index].device;
                final deviceName = device.platformName.isEmpty
                    ? "جهاز غير معروف"
                    : device.platformName;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.bluetooth, color: Colors.white),
                    ),
                    title: Text(
                      deviceName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(device.remoteId.toString()),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await device.connect(license: License.commercial);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TherapyScreen(device: device),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("فشل الاتصال بالجهاز"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'توصيل',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: startScan,
        backgroundColor: Colors.blueAccent,
        icon: const Icon(Icons.search, color: Colors.white),
        label: const Text(
          "بحث بلوتوث",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
