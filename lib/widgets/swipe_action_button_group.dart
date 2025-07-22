import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../core/theme.dart';

class SwipeActionButtonGroup extends StatelessWidget {
  final PhotoModel photo;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final bool isInAlbum;
  final VoidCallback onAddToAlbum;
  final VoidCallback onShare;

  const SwipeActionButtonGroup({
    Key? key,
    required this.photo,
    required this.isFavorite,
    required this.onFavorite,
    required this.isInAlbum,
    required this.onAddToAlbum,
    required this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = Theme.of(context).colorScheme.onSurface;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey(isFavorite),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : iconColor,
              size: Scale.of(context, 32),
            ),
            onPressed: onFavorite,
            tooltip: 'Favorite',
          ),
        ),
        SizedBox(height: AppSpacing.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey(isInAlbum),
            icon: Icon(
              Icons.folder_copy_outlined,
              color:
                  isInAlbum ? Theme.of(context).colorScheme.primary : iconColor,
              size: Scale.of(context, 32),
            ),
            onPressed: onAddToAlbum,
            tooltip: 'Add to Album',
          ),
        ),
        SizedBox(height: AppSpacing.md),
        IconButton(
          icon: Icon(
            Icons.ios_share,
            color: iconColor,
            size: Scale.of(context, 32),
          ),
          onPressed: onShare,
          tooltip: 'Share',
        ),
      ],
    );
  }
}
