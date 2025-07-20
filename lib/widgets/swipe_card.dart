import 'package:flutter/material.dart';
import '../models/photo_model.dart';

class SwipeCard extends StatelessWidget {
  final PhotoModel photo;
  final bool isTop;
  final String? liveLabel;
  final Color? liveLabelColor;
  final bool showLiveLabel;
  final double aspectRatio;
  final Widget? child;

  const SwipeCard({
    Key? key,
    required this.photo,
    this.isTop = false,
    this.liveLabel,
    this.liveLabelColor,
    this.showLiveLabel = false,
    this.aspectRatio = 1.0,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;
    if (photo.thumbnailData != null && photo.thumbnailData!.isNotEmpty) {
      final img = ClipRRect(
        borderRadius: BorderRadius.circular(24),
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
                ).colorScheme.background.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        );
      } else {
        imageWidget = img;
      }
    } else {
      imageWidget = Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image, color: Colors.white, size: 80),
      );
    }
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Card(
        elevation: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            imageWidget,
            if (showLiveLabel && liveLabel != null && liveLabelColor != null)
              Positioned(
                top: 32,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: showLiveLabel ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 120),
                  child: Center(
                    child: Text(
                      liveLabel!,
                      style: TextStyle(
                        color: liveLabelColor,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            blurRadius: 20,
                            color: liveLabelColor!.withOpacity(0.7),
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
