import 'dart:async';
import 'dart:typed_data';
import '../models/photo_model.dart';

class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  final Map<String, Uint8List?> _thumbnailCache = {};
  final Set<String> _loadingThumbnails = {};
  final StreamController<String> _thumbnailLoadedController =
      StreamController<String>.broadcast();

  Stream<String> get thumbnailLoadedStream => _thumbnailLoadedController.stream;

  /// Load thumbnails for a specific range of photos
  Future<void> loadThumbnailsForRange(
    List<PhotoModel> photos,
    int startIndex,
    int endIndex, {
    int thumbnailSize = 400,
  }) async {
    final range = endIndex - startIndex;
    final photosToLoad = photos.sublist(
      startIndex,
      endIndex.clamp(0, photos.length),
    );

    // Load thumbnails in parallel (but limit concurrency)
    final futures = <Future<void>>[];
    for (final photo in photosToLoad) {
      if (!photo.isThumbnailLoaded && !_loadingThumbnails.contains(photo.id)) {
        futures.add(_loadSingleThumbnail(photo, thumbnailSize));
      }
    }

    // Wait for all thumbnails to load
    await Future.wait(futures);
  }

  /// Load thumbnails for the first N photos (for initial display)
  Future<void> preloadInitialThumbnails(
    List<PhotoModel> photos, {
    int count = 20,
    int thumbnailSize = 400,
  }) async {
    await loadThumbnailsForRange(
      photos,
      0,
      count,
      thumbnailSize: thumbnailSize,
    );
  }

  /// Load a single thumbnail
  Future<void> _loadSingleThumbnail(PhotoModel photo, int size) async {
    if (_loadingThumbnails.contains(photo.id)) {
      return;
    }

    _loadingThumbnails.add(photo.id);
    try {
      await photo.loadThumbnail(size: size);
      _thumbnailLoadedController.add(photo.id);
    } finally {
      _loadingThumbnails.remove(photo.id);
    }
  }

  /// Clear thumbnail cache to free memory
  void clearCache() {
    _thumbnailCache.clear();
  }

  /// Get cache size
  int get cacheSize => _thumbnailCache.length;

  void dispose() {
    _thumbnailLoadedController.close();
  }
}
