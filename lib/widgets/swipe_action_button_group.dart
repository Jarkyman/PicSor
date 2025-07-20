import 'package:flutter/material.dart';
import '../models/photo_model.dart';

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
              color:
                  isFavorite
                      ? Colors.red
                      : (isDark ? Colors.white : Colors.black),
              size: 32,
            ),
            onPressed: onFavorite,
            tooltip: 'Favorite',
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: IconButton(
            key: ValueKey(isInAlbum),
            icon: Icon(
              Icons.folder_copy_outlined,
              color:
                  isInAlbum
                      ? Colors.blue
                      : (isDark ? Colors.white : Colors.black),
              size: 32,
            ),
            onPressed: onAddToAlbum,
            tooltip: 'Add to Album',
          ),
        ),
        const SizedBox(height: 12),
        IconButton(
          icon: Icon(
            Icons.ios_share,
            color: isDark ? Colors.white : Colors.black,
            size: 32,
          ),
          onPressed: onShare,
          tooltip: 'Share',
        ),
      ],
    );
  }
}
