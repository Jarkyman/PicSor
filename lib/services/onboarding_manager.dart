import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/onboarding/photo_permission_screen.dart';
import '../screens/onboarding/notification_permission_screen.dart';
import '../screens/onboarding/privacy_policy_screen.dart';
import '../screens/onboarding/intro_screen.dart';
import '../screens/onboarding/bonus_swipes_screen.dart';
import '../services/swipe_storage_service.dart';

class OnboardingManager {
  bool _showOnboarding = false;
  int _onboardingStep = 0;

  bool get showOnboarding => _showOnboarding;
  int get onboardingStep => _onboardingStep;

  Future<void> checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    _showOnboarding = !done;
  }

  void nextStep() {
    _onboardingStep++;
  }

  Future<void> finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    // If we just visited the bonus page, give 1000 swipes
    await SwipeStorageService.saveSwipesLeft(1000);
    _showOnboarding = false;
  }

  List<Widget> getOnboardingScreens({
    required VoidCallback onNext,
    required VoidCallback onFinish,
  }) {
    return [
      WelcomeScreen(onContinue: onNext),
      PhotoPermissionScreen(onNext: onNext),
      NotificationPermissionScreen(onNext: onNext),
      PrivacyPolicyScreen(onAccept: onNext),
      IntroScreen(onContinue: onNext),
      BonusSwipesScreen(onClaimed: onFinish),
    ];
  }

  void reset() {
    _showOnboarding = false;
    _onboardingStep = 0;
  }
}
