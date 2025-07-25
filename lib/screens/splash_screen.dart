import 'package:flutter/material.dart';
import '../services/onboarding_manager.dart';
import '../services/app_initializer.dart';
import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late OnboardingManager _onboardingManager;
  late AppInitializer _appInitializer;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _onboardingManager = OnboardingManager();
    _appInitializer = AppInitializer();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _onboardingManager.checkOnboarding();

    if (_onboardingManager.showOnboarding) {
      setState(() {
        _loading = false;
      });
    } else {
      await _loadAppData();
    }
  }

  Future<void> _loadAppData() async {
    try {
      await _appInitializer.loadState();
      final photos = await _appInitializer.loadGalleryAssets();
      _appInitializer.initializeDeck(photos);
      await _appInitializer.navigateToSwipeScreen(context, photos);
    } catch (e) {
      _appInitializer.showErrorDialog(context, e.toString());
    }
  }

  void _nextOnboarding() {
    setState(() {
      _onboardingManager.nextStep();
    });
  }

  Future<void> _finishOnboarding() async {
    await _onboardingManager.finishOnboarding();
    setState(() {
      _loading = true;
    });
    await _loadAppData();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.photo_library_outlined,
                size: Scale.of(context, 72),
                color: AppColors.primary,
              ),
              SizedBox(height: AppSpacing.xl),
              const CircularProgressIndicator(),
              SizedBox(height: AppSpacing.lg),
              Text(
                'Loading your gallery...',
                style: AppTextStyles.title(context),
              ),
            ],
          ),
        ),
      );
    }

    if (_onboardingManager.showOnboarding) {
      final onboardingScreens = _onboardingManager.getOnboardingScreens(
        onNext: _nextOnboarding,
        onFinish: _finishOnboarding,
      );
      return onboardingScreens[_onboardingManager.onboardingStep];
    }

    // Should never reach here
    return const SizedBox.shrink();
  }
}
