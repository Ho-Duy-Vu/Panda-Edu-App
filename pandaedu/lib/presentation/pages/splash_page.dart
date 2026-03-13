import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../../core/constants.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String _statusMessage = 'Đang khởi động...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      setState(() {
        _statusMessage = 'Đang tải dữ liệu...';
        _hasError = false;
      });

      // Preload flashcards to ensure data is ready
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Load flashcards in background
      final provider = context.read<FlashcardProvider>();
      await provider.loadFlashcards();
      
      if (!mounted) return;
      
      setState(() {
        _statusMessage = 'Hoàn tất!';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      await _navigate();
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _statusMessage = 'Lỗi khi tải dữ liệu';
      });
      
      // Still navigate after showing error briefly
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      await _navigate();
    }
  }

  Future<void> _navigate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool(StorageKeys.hasSeenOnboardingKey) ?? false;
      
      if (!mounted) return;
      
      if (hasSeenOnboarding) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    } catch (e) {
      if (!mounted) return;
      
      // If navigation fails, go to home as fallback
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.matchaMedium,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/app_logo.webp',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: AppSizes.paddingLarge),
            const Text(
              'PandaEdu',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            const Text(
              'Voice Flashcards',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: AppSizes.paddingLarge * 2),
            if (!_hasError)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            else
              const Icon(
                Icons.error_outline,
                color: Colors.white,
                size: 48,
              ),
            const SizedBox(height: AppSizes.paddingMedium),
            Text(
              _statusMessage,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
