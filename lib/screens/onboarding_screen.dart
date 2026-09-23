import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => isLastPage = index == 2);
                },
                children: [
                  _buildPage(
                    color: Colors.blue.shade50,
                    icon: Icons.precision_manufacturing,
                    title: 'تقنية ذكية للتأهيل',
                    subtitle:
                        'نظام متكامل يدمج بين قفاز آلي وتطبيق ذكي لتسريع عملية العلاج الطبيعي لليد.',
                  ),
                  _buildPage(
                    color: Colors.green.shade50,
                    icon: Icons.analytics_outlined,
                    title: 'تتبع حيوي دقيق',
                    subtitle:
                        'مراقبة حركة كل إصبع على حدة لحظة بلحظة لضمان أقصى درجات الاستفادة من الجلسة.',
                  ),
                  _buildPage(
                    color: Colors.purple.shade50,
                    icon: Icons.picture_as_pdf,
                    title: 'تقارير طبية معتمدة',
                    subtitle:
                        'استخراج تقارير تفصيلية بضغطة زر لمشاركتها مع الطبيب المعالج ومتابعة التطور.',
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زرار التخطي
                  TextButton(
                    onPressed: () => _controller.jumpToPage(2),
                    child: const Text(
                      'تخطي',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // نقط التقليب
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: const ExpandingDotsEffect(
                      activeDotColor: Color(0xFF0D6EFD),
                      dotColor: Colors.black12,
                      dotHeight: 8,
                      dotWidth: 8,
                    ),
                  ),

                  // زرار التالي أو ابدأ
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      if (isLastPage) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainLayout(),
                          ),
                        );
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    child: Text(
                      isLastPage ? 'ابدأ الآن' : 'التالي',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // التعديل السحري هنا: ضفنا SingleChildScrollView عشان نحل مشكلة الـ Overflow
  Widget _buildPage({
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Icon(icon, size: 80, color: const Color(0xFF0D6EFD)),
            ),
            const SizedBox(height: 40),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
