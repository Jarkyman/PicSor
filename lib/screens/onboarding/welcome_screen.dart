import 'package:flutter/material.dart';
import '../../core/theme.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const WelcomeScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl + AppSpacing.lg),
                // Logo placeholder
                Container(
                  width: Scale.of(context, 100),
                  height: Scale.of(context, 100),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.photo_library_outlined,
                      size: Scale.of(context, 56),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Welcome to PicSor',
                  style: AppTextStyles.headline(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Sort and clean up your photos and videos with a swipe. PicSor helps you organize your gallery – fast, private, and offline.\n\nSwipe right to keep, left to delete, and up to sort for later. No cloud, no account, just you and your photos.',
                  style: AppTextStyles.body(context),
                  textAlign: TextAlign.center,
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
                      'Get started',
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
    );
  }
}
