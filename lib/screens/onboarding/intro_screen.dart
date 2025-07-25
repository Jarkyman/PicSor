import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/onboarding/onboarding_icon.dart';
import '../../widgets/onboarding/onboarding_title.dart';
import '../../widgets/onboarding/onboarding_button_row.dart';

class IntroScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const IntroScreen({super.key, required this.onContinue});

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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: AppSpacing.xl + AppSpacing.lg),
                        OnboardingIcon(icon: Icons.swipe),
                        SizedBox(height: AppSpacing.xl),
                        OnboardingTitle(text: 'How PicSor Works'),
                        SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Text(
                              'Swipe through your photos and videos to quickly organize your gallery.\n\n- Swipe right to keep\n- Swipe left to delete (soft delete)\n- Swipe up to sort for later\n\nDeleted items are not removed immediately, but placed in a temporary queue until you confirm permanent deletion. You can always undo your last swipe.\n\nPicSor works 100% offline and never uploads your photos.',
                              style: AppTextStyles.body(context),
                              textAlign: TextAlign.center,
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
                                'Continue',
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
