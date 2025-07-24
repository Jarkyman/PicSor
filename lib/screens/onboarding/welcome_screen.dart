import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/onboarding/onboarding_icon.dart';
import '../../widgets/onboarding/onboarding_title.dart';
import '../../widgets/onboarding/onboarding_body.dart';
import '../../widgets/onboarding/onboarding_button_row.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const WelcomeScreen({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: LayoutBuilder(
              builder:
                  (context, constraints) => ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.xl + AppSpacing.lg),
                        OnboardingIcon(icon: Icons.photo_library_outlined),
                        SizedBox(height: AppSpacing.xl),
                        OnboardingTitle(text: 'Welcome to PicSor'),
                        SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: OnboardingBody(
                              text:
                                  'Sort and clean up your photos and videos with a swipe. PicSor helps you organize your gallery – fast, private, and offline.\n\nSwipe right to keep, left to delete, and up to sort for later. No cloud, no account, just you and your photos.',
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        OnboardingButtonRow(
                          buttons: [
                            ElevatedButton(
                              onPressed: onContinue,
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  vertical: Scale.of(context, 16),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.buttonRadius,
                                  ),
                                ),
                              ),
                              child: Text(
                                'Get started',
                                style: AppTextStyles.button(context),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
