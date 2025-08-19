import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/onboarding_manager.dart';
import '../services/app_initializer.dart';
import '../services/background_gallery_loader.dart';
import '../widgets/skeleton/skeleton_splash_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late OnboardingManager _onboardingManager;
  late AppInitializer _appInitializer;
  late BackgroundGalleryLoader _backgroundLoader;
  bool _loading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _onboardingManager = OnboardingManager();
    _appInitializer = AppInitializer();
    _backgroundLoader = BackgroundGalleryLoader();
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

      // Listen to background loading progress
      _backgroundLoader.progressStream.listen((count) {
        if (mounted) {
          setState(() {
            _loadingProgress = count;
          });
        }
      });

      // Check if we already have cached assets from background loading
      List<PhotoModel> photos;
      if (_backgroundLoader.cachedAssets != null) {
        photos = _backgroundLoader.cachedAssets!;
      } else {
        // Start loading if not already started
        _backgroundLoader.startLoading();

        // Wait for completion
        photos = await _backgroundLoader.completionStream.first;
      }

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

  void _dispose() {
    _backgroundLoader.dispose();
  }

  Future<void> _finishOnboarding() async {
    await _onboardingManager.finishOnboarding();
    setState(() {
      _loading = true;
    });
    await _loadAppData();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return SkeletonSplashScreen(progress: _loadingProgress);
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
