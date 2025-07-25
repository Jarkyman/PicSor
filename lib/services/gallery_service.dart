import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_model.dart';
import 'package:flutter/foundation.dart';
import 'error_handler_service.dart';

class GalleryService {
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Simple in-memory cache
  List<PhotoModel>? _cachedAssets;
  DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  Future<List<PhotoModel>> fetchGalleryAssets({Set<String>? excludeIds}) async {
    // Check cache first
    if (_isCacheValid()) {
      debugPrint('GalleryService: Using cached assets');
      return _getFilteredAssets(_cachedAssets!, excludeIds);
    }

    // Fetch fresh data with retry mechanism
    return await _fetchWithRetry(excludeIds);
  }

  Future<List<PhotoModel>> _fetchWithRetry(Set<String>? excludeIds) async {
    AppError? lastError;

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        debugPrint(
          'GalleryService: Fetching assets (attempt $attempt/$_maxRetries)',
        );
        final assets = await _fetchAssetsFromGallery();

        // Cache the results
        _cachedAssets = assets;
        _lastCacheTime = DateTime.now();

        return _getFilteredAssets(assets, excludeIds);
      } catch (e) {
        lastError = _createAppError(e);
        debugPrint('GalleryService: Attempt $attempt failed: $e');

        if (attempt < _maxRetries) {
          await Future.delayed(_retryDelay * attempt); // Exponential backoff
        }
      }
    }

    throw AppError(
      message: 'Failed to fetch gallery assets after $_maxRetries attempts',
      type: ErrorType.gallery,
      originalException: lastError?.originalException,
      userFriendlyMessage:
          'Unable to load your photos. Please check permissions and try again.',
    );
  }

  Future<List<PhotoModel>> _fetchAssetsFromGallery() async {
    // Request permissions with better error handling
    final permissionStatus = await _requestPermissions();
    if (!permissionStatus) {
      throw AppError(
        message: 'Photo access permission denied',
        type: ErrorType.permission,
        userFriendlyMessage:
            'Photo access is required. Please grant permission in your device settings.',
      );
    }

    // Get "All" asset path for images only
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      type: RequestType.image,
      filterOption: FilterOptionGroup(
        imageOption: const FilterOption(),
        orders: [
          const OrderOption(type: OrderOptionType.createDate, asc: false),
        ],
      ),
    );

    if (paths.isEmpty) {
      throw AppError(
        message: 'No albums found',
        type: ErrorType.gallery,
        userFriendlyMessage: 'No photo albums found on your device.',
      );
    }

    final allPath = paths.first;
    final assets = await allPath.getAssetListPaged(page: 0, size: 1000);

    if (assets.isEmpty) {
      throw AppError(
        message: 'No images found',
        type: ErrorType.gallery,
        userFriendlyMessage: 'No photos found in your gallery.',
      );
    }

    // Convert to PhotoModel with error handling for individual assets
    final List<PhotoModel> photoModels = [];
    for (final asset in assets) {
      try {
        final thumb = await asset.thumbnailDataWithSize(
          const ThumbnailSize(400, 400),
        );
        photoModels.add(
          PhotoModel(
            id: asset.id,
            asset: asset,
            createdAt: asset.createDateTime,
            isVideo: asset.type == AssetType.video,
            thumbnailData: thumb,
          ),
        );
      } catch (e) {
        debugPrint('GalleryService: Failed to process asset ${asset.id}: $e');
        // Continue with other assets instead of failing completely
      }
    }

    if (photoModels.isEmpty) {
      throw AppError(
        message: 'No valid images could be processed',
        type: ErrorType.gallery,
        userFriendlyMessage: 'Unable to process photos. Please try again.',
      );
    }

    return photoModels;
  }

  Future<bool> _requestPermissions() async {
    try {
      // Request photos permission
      final permissionStatus = await Permission.photos.request();
      if (!permissionStatus.isGranted) {
        return false;
      }

      // Request photo_manager permission (for Android/iOS)
      final pmResult = await PhotoManager.requestPermissionExtend();
      return pmResult.hasAccess;
    } catch (e) {
      debugPrint('GalleryService: Permission request failed: $e');
      return false;
    }
  }

  AppError _createAppError(dynamic error) {
    if (error is AppError) {
      return error;
    }

    String message = error.toString();
    Exception? originalException;

    if (error is Exception) {
      originalException = error;
    }

    return AppError(
      message: message,
      type: ErrorType.gallery,
      originalException: originalException,
    );
  }

  List<PhotoModel> _getFilteredAssets(
    List<PhotoModel> assets,
    Set<String>? excludeIds,
  ) {
    if (excludeIds == null || excludeIds.isEmpty) {
      return assets;
    }
    return assets.where((a) => !excludeIds.contains(a.id)).toList();
  }

  bool _isCacheValid() {
    if (_cachedAssets == null || _lastCacheTime == null) {
      return false;
    }
    return DateTime.now().difference(_lastCacheTime!) < _cacheValidDuration;
  }

  void clearCache() {
    _cachedAssets = null;
    _lastCacheTime = null;
    debugPrint('GalleryService: Cache cleared');
  }

  int get cachedAssetCount => _cachedAssets?.length ?? 0;
  bool get hasCachedData => _cachedAssets != null;
}
