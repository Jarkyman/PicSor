import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gallery_service.dart';
import '../services/swipe_logic_service.dart';
import '../screens/swipe_screen.dart';
import 'onboarding/welcome_screen.dart';
import 'onboarding/photo_permission_screen.dart';
import 'onboarding/notification_permission_screen.dart';
import 'onboarding/privacy_policy_screen.dart';
import 'onboarding/intro_screen.dart';
import 'onboarding/bonus_swipes_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late GalleryService _galleryService;
  late SwipeLogicService _swipeLogicService;
  bool _showOnboarding = false;
  int _onboardingStep = 0;
  bool _loading = true;
  List<Widget> get _onboardingScreens => [
    WelcomeScreen(onContinue: _nextOnboarding),
    PhotoPermissionScreen(onNext: _nextOnboarding),
    NotificationPermissionScreen(onNext: _nextOnboarding),
    PrivacyPolicyScreen(onAccept: _nextOnboarding),
    IntroScreen(onContinue: _nextOnboarding),
    BonusSwipesScreen(onClaimed: _finishOnboarding),
  ];

  @override
  void initState() {
    super.initState();
    _galleryService = GalleryService();
    _swipeLogicService = SwipeLogicService();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (!done) {
      setState(() {
        _showOnboarding = true;
        _loading = false;
      });
    } else {
      _loadAll();
    }
  }

  void _nextOnboarding() {
    setState(() {
      _onboardingStep++;
    });
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    setState(() {
      _showOnboarding = false;
      _loading = true;
    });
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      await _swipeLogicService.loadState();
      final photos = await _galleryService.fetchGalleryAssets();
      _swipeLogicService.initializeDeck(photos);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => SwipeScreen(
                  swipeLogicService: _swipeLogicService,
                  assets: photos,
                ),
          ),
        );
      }
    } catch (e) {
      // Optionally show error UI
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load app data: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
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
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Loading your gallery...',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }
    if (_showOnboarding) {
      return _onboardingScreens[_onboardingStep];
    }
    // Should never reach here
    return const SizedBox.shrink();
  }
}
