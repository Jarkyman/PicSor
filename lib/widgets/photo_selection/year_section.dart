import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'liquid_glass_card.dart';
import 'selection_section.dart';

class YearSection extends StatelessWidget {
  final List<int> years;
  final Function(int) onYearSelected;
  final Function(int) getAssetCount;

  const YearSection({
    super.key,
    required this.years,
    required this.onYearSelected,
    required this.getAssetCount,
  });

  @override
  Widget build(BuildContext context) {
    return SelectionSection(
      title: 'By Year',
      child: SizedBox(
        height: 90,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: years.length,
          itemBuilder: (context, index) {
            final year = years[index];
            final assetCount = getAssetCount(year);

            return Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: LiquidGlassCard(
                onTap: () => onYearSelected(year),
                child: SizedBox(
                  width: 100,
                  height: 70,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          year.toString(),
                          style: AppTextStyles.title(context).copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: Scale.of(context, 18),
                            letterSpacing: -0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2),
                        Text(
                          '$assetCount photos',
                          style: AppTextStyles.body(context).copyWith(
                            fontSize: Scale.of(context, 11),
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
