import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'skeleton_card.dart';
import 'skeleton_button.dart';

class SkeletonSwipeScreen extends StatelessWidget {
  const SkeletonSwipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSkeletonContent(context);
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
}
