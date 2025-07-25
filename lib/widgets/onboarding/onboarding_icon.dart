import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OnboardingIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  const OnboardingIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Scale.of(context, 100),
      height: Scale.of(context, 100),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Center(
        child: Icon(
          icon,
          size: Scale.of(context, size),
          color:
              color ??
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
