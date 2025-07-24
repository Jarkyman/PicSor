import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../core/theme.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/photo_action_service.dart';

typedef FavoriteToggledCallback = void Function(PhotoModel updatedPhoto);
typedef SnackBarCallback =
    void Function(String message, {SnackBarAction? action});

class SwipeActionButtonGroup extends StatelessWidget {
  final PhotoModel photo;
  final bool isFavorite;
  final FavoriteToggledCallback onFavoriteToggled;
  final bool isInAlbum;
  final VoidCallback onAddToAlbum;
  final VoidCallback onShare;
  final SnackBarCallback showSnackBar;

  const SwipeActionButtonGroup({
    super.key,
    required this.photo,
    required this.isFavorite,
    required this.onFavoriteToggled,
    required this.isInAlbum,
    required this.onAddToAlbum,
    required this.onShare,
    required this.showSnackBar,
  });

  @override
  Widget build(BuildContext context) {
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
            onPressed: () async {
              final success = await PhotoActionService.toggleFavorite(photo);
              if (success) {
                final updated = await AssetEntity.fromId(photo.id);
                if (updated != null) {
                  onFavoriteToggled(
                    PhotoModel(
                      id: photo.id,
                      asset: updated,
                      createdAt: photo.createdAt,
                      isVideo: photo.isVideo,
                      thumbnailData: photo.thumbnailData,
                    ),
                  );
                } else {
                  showSnackBar(
                    'Favorite updated, but failed to refresh photo.',
                  );
                }
              } else {
                // Check permissions on iOS
                if (Theme.of(context).platform == TargetPlatform.iOS) {
                  final status = await PhotoManager.requestPermissionExtend();
                  if (!status.isAuth) {
                    showSnackBar(
                      'Photo access denied. Please allow full access in Settings.',
                      action: SnackBarAction(
                        label: 'Settings',
                        onPressed: () {
                          PhotoManager.openSetting();
                        },
                      ),
                    );
                    return;
                  }
                }
                showSnackBar(
                  'Could not update favorite. Try again or check permissions.',
                );
              }
            },
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
