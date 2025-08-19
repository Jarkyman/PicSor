import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../screens/main_navigation_screen.dart';
import 'gallery_service.dart';
import 'swipe_logic_service.dart';
import 'error_handler_service.dart';

class AppInitializer {
  late final GalleryService _galleryService;
  late final SwipeLogicService _swipeLogicService;
  final ErrorHandlerService _errorHandler = ErrorHandlerService();

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
              (_) => MainNavigationScreen(
                swipeLogicService: _swipeLogicService,
                assets: assets,
              ),
        ),
      );
    }
  }

  void showErrorDialog(BuildContext context, String error) {
    _errorHandler.handleError(
      context,
      error,
      type: ErrorType.gallery,
      userFriendlyMessage: 'Failed to load app data. Please try again.',
      onRetry: () => _retryLoadAppData(context),
    );
  }

  Future<void> _retryLoadAppData(BuildContext context) async {
    try {
      await loadState();
      final photos = await loadGalleryAssets();
      initializeDeck(photos);
      await navigateToSwipeScreen(context, photos);
    } catch (e) {
      showErrorDialog(context, e.toString());
    }
  }

  // Getters for external access
  SwipeLogicService get swipeLogicService => _swipeLogicService;
  GalleryService get galleryService => _galleryService;
}
