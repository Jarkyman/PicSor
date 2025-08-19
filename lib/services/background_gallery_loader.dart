import 'dart:async';
import '../models/photo_model.dart';
import 'gallery_service.dart';

class BackgroundGalleryLoader {
  final GalleryService _galleryService = GalleryService();
  final StreamController<int> _progressController =
      StreamController<int>.broadcast();
  final StreamController<List<PhotoModel>> _completionController =
      StreamController<List<PhotoModel>>.broadcast();

  Stream<int> get progressStream => _progressController.stream;
  Stream<List<PhotoModel>> get completionStream => _completionController.stream;

  bool _isLoading = false;
  List<PhotoModel>? _cachedAssets;

  bool get isLoading => _isLoading;
  List<PhotoModel>? get cachedAssets => _cachedAssets;

  Future<void> startLoading() async {
    if (_isLoading || _cachedAssets != null) return;

    _isLoading = true;
    _progressController.add(0);

    try {
      // Actually load the gallery assets with progress updates
      final assets = await _galleryService.fetchGalleryAssets(
        onProgress: (count) {
          _progressController.add(count);
        },
      );

      _cachedAssets = assets;
      _progressController.add(assets.length);
      _completionController.add(assets);
    } catch (e) {
      _progressController.addError(e);
      _completionController.addError(e);
    } finally {
      _isLoading = false;
    }
  }

  void dispose() {
    _progressController.close();
    _completionController.close();
  }
}
