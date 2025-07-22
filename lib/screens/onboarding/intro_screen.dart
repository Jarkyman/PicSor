import 'package:flutter/material.dart';
import '../../core/theme.dart';

class IntroScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const IntroScreen({Key? key, required this.onContinue}) : super(key: key);

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
                              Icons.swipe,
                              size: Scale.of(context, 56),
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.7),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xl),
                        Text(
                          'How PicSor Works',
                          style: AppTextStyles.headline(context),
                          textAlign: TextAlign.center,
                        ),
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
                        SizedBox(height: AppSpacing.xl + AppSpacing.md),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
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
