import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'skeleton_card.dart';
import 'skeleton_button.dart';

class SkeletonSwipeScreen extends StatelessWidget {
  const SkeletonSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildSkeletonAppBar(context),
      body: SafeArea(child: _buildSkeletonContent(context)),
    );
  }

  PreferredSizeWidget _buildSkeletonAppBar(BuildContext context) {
    return AppBar(
      title: _buildSkeletonText(context, 120, 24),
      actions: [
        _buildSkeletonText(context, 80, 16),
        const SizedBox(width: AppSpacing.md),
        _buildSkeletonButton(context, 40),
        const SizedBox(width: AppSpacing.sm),
        _buildSkeletonButton(context, 40),
        const SizedBox(width: AppSpacing.sm),
        _buildSkeletonButton(context, 40),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  Widget _buildSkeletonContent(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(color: Theme.of(context).colorScheme.surface),

        // Main skeleton card
        Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: SkeletonCard(
              height: MediaQuery.of(context).size.height * 0.6,
              borderRadius: AppSpacing.cardRadius,
            ),
          ),
        ),

        // Action buttons skeleton
        Positioned(
          bottom: 24,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonButton(size: 48),
              SizedBox(height: AppSpacing.md),
              SkeletonButton(size: 48),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonText(BuildContext context, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[700],
      ),
    );
  }

  Widget _buildSkeletonButton(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        color:
            Theme.of(context).brightness == Brightness.light
                ? Colors.grey[300]
                : Colors.grey[700],
      ),
    );
  }
}
