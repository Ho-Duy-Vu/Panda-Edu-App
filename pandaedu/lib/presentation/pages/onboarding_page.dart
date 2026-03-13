import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    const OnboardingSlide(
      imagePath: 'assets/images/panda_wave.webp',
      title: 'Chào bạn!',
      subtitle: 'Ghi âm và học với flashcard vui vẻ',
    ),
    const OnboardingSlide(
      imagePath: 'assets/images/panda_mic.webp',
      title: 'Ghi âm dễ dàng',
      subtitle: 'Nhấn nút đỏ để ghi lại giọng nói của bạn',
    ),
    const OnboardingSlide(
      imagePath: 'assets/images/panda_books.webp',
      title: 'Ôn tập thông minh',
      subtitle: 'Ứng dụng sẽ nhắc bạn ôn đúng lúc',
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.hasSeenOnboardingKey, true);
    
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  return _slides[index];
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingLarge),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.matchaMedium
                              : AppColors.matchaLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _slides.length - 1) {
                        _complete();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? 'Bắt đầu thôi!'
                          : 'Tiếp theo',
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
}

class OnboardingSlide extends StatelessWidget {
  final String? imagePath;
  final String title;
  final String subtitle;

  const OnboardingSlide({
    super.key,
    this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            Image.asset(
              imagePath!,
              width: 150,
              height: 150,
            )
          else
            const Icon(
              Icons.image,
              size: 120,
              color: AppColors.matchaLight,
            ),
          const SizedBox(height: AppSizes.paddingLarge * 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.pandaBlack,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSizes.paddingMedium),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
