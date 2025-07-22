import 'package:flutter/material.dart';
import '../../core/theme.dart';

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
                        Container(
                          width: Scale.of(context, 100),
                          height: Scale.of(context, 100),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(AppSpacing.lg),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.card_giftcard,
                              size: Scale.of(context, 56),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        Text(
                          'Welcome Bonus!',
                          style: AppTextStyles.headline(context),
                          textAlign: TextAlign.center,
                        ),
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
                        SizedBox(height: AppSpacing.xl + AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
