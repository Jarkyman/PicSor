import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../models/photo_model.dart';
import '../../core/theme.dart';

class SwipeCard extends StatelessWidget {
  final PhotoModel photo;
  final bool isTop;
  final String? liveLabel;
  final Color? liveLabelColor;
  final bool showLiveLabel;
  final double aspectRatio;
  final Widget? child;

  const SwipeCard({
    super.key,
    required this.photo,
    this.isTop = false,
    this.liveLabel,
    this.liveLabelColor,
    this.showLiveLabel = false,
    this.aspectRatio = 1.0,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    final borderRadius = BorderRadius.circular(AppSpacing.cardRadius);

    if (photo.isThumbnailLoaded &&
        photo.thumbnailData != null &&
        photo.thumbnailData!.isNotEmpty) {
      final img = ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          photo.thumbnailData!,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
        ),
      );
      if (!isTop) {
        imageWidget = Stack(
          children: [
            img,
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: borderRadius,
              ),
            ),
          ],
        );
      } else {
        imageWidget = img;
      }
    } else {
      // Show loading placeholder or load thumbnail
      imageWidget = FutureBuilder<Uint8List?>(
        future: photo.loadThumbnail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              color: Colors.grey[800],
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            );
          }

          if (snapshot.hasData && snapshot.data != null) {
            final img = ClipRRect(
              borderRadius: borderRadius,
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
              ),
            );
            if (!isTop) {
              return Stack(
                children: [
                  img,
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.9),
                      borderRadius: borderRadius,
                    ),
                  ),
                ],
              );
            } else {
              return img;
            }
          }

          // Fallback for failed loading
          return Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: Icon(
              Icons.broken_image,
              color: Colors.white,
              size: Scale.of(context, 80),
            ),
          );
        },
      );
    }
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            imageWidget,
            if (showLiveLabel && liveLabel != null && liveLabelColor != null)
              Positioned(
                top: Scale.of(context, 32),
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: showLiveLabel ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Center(
                    child: Text(
                      liveLabel!,
                      style: AppTextStyles.headline(context).copyWith(
                        color: liveLabelColor,
                        fontSize: Scale.of(context, 36),
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: liveLabelColor!.withValues(alpha: 0.7),
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
