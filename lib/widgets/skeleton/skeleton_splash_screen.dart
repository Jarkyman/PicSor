import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SkeletonSplashScreen extends StatelessWidget {
  const SkeletonSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSkeletonIcon(context),
            SizedBox(height: AppSpacing.xl),
            _buildSkeletonSpinner(context),
            SizedBox(height: AppSpacing.lg),
            _buildSkeletonText(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonIcon(BuildContext context) {
    return Container(
      width: Scale.of(context, 72),
      height: Scale.of(context, 72),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Scale.of(context, 36)),
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[700],
      ),
    );
  }

  Widget _buildSkeletonSpinner(BuildContext context) {
    return Container(
      width: Scale.of(context, 24),
      height: Scale.of(context, 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Scale.of(context, 12)),
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[700],
      ),
    );
  }

  Widget _buildSkeletonText(BuildContext context) {
    return Container(
      width: Scale.of(context, 200),
      height: Scale.of(context, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Scale.of(context, 10)),
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[700],
      ),
    );
  }
}
