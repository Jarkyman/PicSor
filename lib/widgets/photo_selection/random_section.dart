import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'liquid_glass_card.dart';
import 'selection_section.dart';

class RandomSection extends StatelessWidget {
  final VoidCallback onTap;

  const RandomSection({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionSection(
      title: 'Quick Start',
      child: LiquidGlassCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.shuffle_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: Scale.of(context, 28),
              ),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Random',
                    style: AppTextStyles.title(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: Scale.of(context, 20),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Text(
                    'Start swiping from a random selection',
                    style: AppTextStyles.body(context).copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: Scale.of(context, 15),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              size: Scale.of(context, 18),
            ),
          ],
        ),
      ),
    );
  }
}
