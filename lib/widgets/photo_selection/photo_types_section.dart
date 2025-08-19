import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'liquid_glass_card.dart';
import 'selection_section.dart';

class PhotoTypesSection extends StatelessWidget {
  final Function(String) onTypeSelected;

  const PhotoTypesSection({
    super.key,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final photoTypes = [
      {'name': 'Recent', 'icon': Icons.access_time, 'filter': 'recent'},
      {'name': 'Screenshots', 'icon': Icons.screenshot, 'filter': 'screenshots'},
      {'name': 'Videos', 'icon': Icons.videocam, 'filter': 'videos'},
      {'name': 'Featured', 'icon': Icons.star, 'filter': 'featured'},
      {'name': 'Selfies', 'icon': Icons.face, 'filter': 'selfies'},
      {'name': 'Live Photos', 'icon': Icons.animation, 'filter': 'live'},
      {'name': 'Portrait', 'icon': Icons.camera_alt, 'filter': 'portrait'},
      {'name': 'Panoramas', 'icon': Icons.panorama, 'filter': 'panorama'},
      {'name': 'Slo-mo', 'icon': Icons.slow_motion_video, 'filter': 'slomo'},
      {'name': 'Favorites', 'icon': Icons.favorite, 'filter': 'favorites'},
    ];

    return SelectionSection(
      title: 'Photo Types',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: photoTypes.length,
        itemBuilder: (context, index) {
          final type = photoTypes[index];
          return LiquidGlassCard(
            onTap: () => onTypeSelected(type['filter'] as String),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    type['icon'] as IconData,
                    color: Theme.of(context).colorScheme.secondary,
                    size: Scale.of(context, 22),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    type['name'] as String,
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
