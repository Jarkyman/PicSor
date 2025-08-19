import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class PhotoModel {
  final String id;
  final AssetEntity asset;
  final DateTime? createdAt;
  final bool isVideo;
  Uint8List? _thumbnailData;
  bool _isLoadingThumbnail = false;

  PhotoModel({
    required this.id,
    required this.asset,
    required this.createdAt,
    required this.isVideo,
    Uint8List? thumbnailData,
  }) : _thumbnailData = thumbnailData;

  Uint8List? get thumbnailData => _thumbnailData;
  bool get isThumbnailLoaded => _thumbnailData != null;
  bool get isLoadingThumbnail => _isLoadingThumbnail;

  /// Load thumbnail data if not already loaded
  Future<Uint8List?> loadThumbnail({int size = 400}) async {
    if (_thumbnailData != null) {
      return _thumbnailData;
    }

    if (_isLoadingThumbnail) {
      // Wait for current loading to complete
      while (_isLoadingThumbnail) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _thumbnailData;
    }

    _isLoadingThumbnail = true;
    try {
      _thumbnailData = await asset.thumbnailDataWithSize(
        ThumbnailSize(size, size),
      );
      return _thumbnailData;
    } catch (e) {
      // Return null if thumbnail loading fails
      return null;
    } finally {
      _isLoadingThumbnail = false;
    }
  }

  /// Preload thumbnail for immediate use
  Future<void> preloadThumbnail({int size = 400}) async {
    await loadThumbnail(size: size);
  }
}
