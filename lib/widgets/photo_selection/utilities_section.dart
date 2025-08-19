import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'liquid_glass_card.dart';
import 'selection_section.dart';

class UtilitiesSection extends StatelessWidget {
  final Function(String) onUtilitySelected;

  const UtilitiesSection({
    super.key,
    required this.onUtilitySelected,
  });

  @override
  Widget build(BuildContext context) {
    final utilities = [
      {'name': 'Duplicates', 'icon': Icons.copy, 'filter': 'duplicates'},
      {'name': 'Receipts', 'icon': Icons.receipt, 'filter': 'receipts'},
      {'name': 'Handwriting', 'icon': Icons.edit, 'filter': 'handwriting'},
      {'name': 'Illustrations', 'icon': Icons.brush, 'filter': 'illustrations'},
      {'name': 'QR Codes', 'icon': Icons.qr_code, 'filter': 'qrcodes'},
      {'name': 'Imports', 'icon': Icons.download, 'filter': 'imports'},
      {'name': 'Documents', 'icon': Icons.description, 'filter': 'documents'},
    ];

    return SelectionSection(
      title: 'Utilities',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: utilities.length,
        itemBuilder: (context, index) {
          final utility = utilities[index];
          return LiquidGlassCard(
            onTap: () => onUtilitySelected(utility['filter'] as String),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    utility['icon'] as IconData,
                    color: Theme.of(context).colorScheme.tertiary,
                    size: Scale.of(context, 22),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    utility['name'] as String,
                    style: AppTextStyles.body(context).copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: Scale.of(context, 16),
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
