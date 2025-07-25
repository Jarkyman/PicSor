import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../screens/swipe_screen.dart';
import '../core/theme.dart';
import 'gallery_service.dart';
import 'swipe_logic_service.dart';

class AppInitializer {
  late final GalleryService _galleryService;
  late final SwipeLogicService _swipeLogicService;

  AppInitializer() {
    _galleryService = GalleryService();
    _swipeLogicService = SwipeLogicService();
  }

  Future<void> loadState() async {
    await _swipeLogicService.loadState();
  }

  Future<List<PhotoModel>> loadGalleryAssets() async {
    return await _galleryService.fetchGalleryAssets();
  }

  void initializeDeck(List<PhotoModel> assets) {
    _swipeLogicService.initializeDeck(assets);
  }

  Future<void> navigateToSwipeScreen(
    BuildContext context,
    List<PhotoModel> assets,
  ) async {
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => SwipeScreen(
                swipeLogicService: _swipeLogicService,
                assets: assets,
              ),
        ),
      );
    }
  }

  void showErrorDialog(BuildContext context, String error) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Error', style: AppTextStyles.title(context)),
              content: Text(
                'Failed to load app data: $error',
                style: AppTextStyles.body(context),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK', style: AppTextStyles.button(context)),
                ),
              ],
            ),
      );
    }
  }

  // Getters for external access
  SwipeLogicService get swipeLogicService => _swipeLogicService;
  GalleryService get galleryService => _galleryService;
}
