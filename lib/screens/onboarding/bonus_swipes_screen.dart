import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../widgets/onboarding/onboarding_icon.dart';
import '../../widgets/onboarding/onboarding_title.dart';
import '../../widgets/onboarding/onboarding_body.dart';
import '../../widgets/onboarding/onboarding_button_row.dart';

class BonusSwipesScreen extends StatelessWidget {
  final VoidCallback onClaimed;
  const BonusSwipesScreen({super.key, required this.onClaimed});

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
                        OnboardingIcon(icon: Icons.card_giftcard),
                        SizedBox(height: AppSpacing.xl),
                        OnboardingTitle(text: 'Welcome Bonus!'),
                        SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Text(
                              'To help you get started, you get 1000 free swipes!\n\nUse them to quickly sort and clean up your gallery.\n\nYou can always earn more swipes later by using the app or watching a rewarded ad.',
                              style: AppTextStyles.body(context),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
                        OnboardingButtonRow(
                          buttons: [
                            ElevatedButton(
                              onPressed: onClaimed,
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
                                'Claim Bonus',
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
