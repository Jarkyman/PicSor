import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AlbumInfo {
  final String id;
  final String title;
  final bool isShared;

  AlbumInfo({required this.id, required this.title, required this.isShared});

  factory AlbumInfo.fromMap(Map<String, dynamic> map) {
    return AlbumInfo(
      id: map['id'] as String,
      title: map['title'] as String,
      isShared: map['isShared'] as bool,
    );
  }

  @override
  String toString() {
    return 'AlbumInfo(id: $id, title: $title, isShared: $isShared)';
  }
}

class AlbumService {
  static const MethodChannel _channel = MethodChannel('picsor.albums.shared');

  // Cache for shared album info
  static List<AlbumInfo>? _cachedSharedAlbums;
  static DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// Get shared album information for all albums
  /// Returns cached data if available and fresh, otherwise fetches new data
  /// Returns empty list on Android or if not available
  static Future<List<AlbumInfo>> getSharedAlbumInfo() async {
    try {
      // Only available on iOS
      if (defaultTargetPlatform != TargetPlatform.iOS) {
        return [];
      }

      // Check if we have valid cached data
      if (_cachedSharedAlbums != null && _lastCacheTime != null) {
        final timeSinceLastCache = DateTime.now().difference(_lastCacheTime!);
        if (timeSinceLastCache < _cacheValidDuration) {
          return _cachedSharedAlbums!;
        }
      }

      // Fetch fresh data from platform channel
      final List<dynamic> result = await _channel.invokeMethod('getAlbums');

      final albums =
          result
              .map((item) {
                if (item is Map) {
                  try {
                    final Map<String, dynamic> convertedMap =
                        Map<String, dynamic>.from(item);
                    return AlbumInfo.fromMap(convertedMap);
                  } catch (e) {
                    return null;
                  }
                }
                return null;
              })
              .whereType<AlbumInfo>()
              .toList();

      // Update cache
      _cachedSharedAlbums = albums;
      _lastCacheTime = DateTime.now();

      return albums;
    } catch (e) {
      // Return cached data if available, even if stale
      return _cachedSharedAlbums ?? [];
    }
  }

  /// Check if a specific album is shared by its title
  static Future<bool> isAlbumShared(String albumTitle) async {
    try {
      final albums = await getSharedAlbumInfo();
      return albums.any((album) => album.title == albumTitle && album.isShared);
    } catch (e) {
      return false;
    }
  }

  /// Get all shared albums
  static Future<List<AlbumInfo>> getSharedAlbums() async {
    try {
      final albums = await getSharedAlbumInfo();
      return albums.where((album) => album.isShared).toList();
    } catch (e) {
      return [];
    }
  }

  /// Clear the cache to force fresh data on next request
  static void clearCache() {
    _cachedSharedAlbums = null;
    _lastCacheTime = null;
  }

  /// Check if cache is valid (not expired)
  static bool get isCacheValid {
    if (_cachedSharedAlbums == null || _lastCacheTime == null) {
      return false;
    }
    final timeSinceLastCache = DateTime.now().difference(_lastCacheTime!);
    return timeSinceLastCache < _cacheValidDuration;
  }

  /// Get cache age in seconds
  static int? get cacheAgeSeconds {
    if (_lastCacheTime == null) return null;
    return DateTime.now().difference(_lastCacheTime!).inSeconds;
  }

  /// Get shared status for a list of album names
  /// Returns a map of album name to shared status
  static Future<Map<String, bool>> getSharedStatusForAlbums(
    List<String> albumNames,
  ) async {
    try {
      final sharedAlbums = await getSharedAlbumInfo();
      final Map<String, bool> result = {};

      for (final albumName in albumNames) {
        final isShared = sharedAlbums.any(
          (album) => album.title == albumName && album.isShared,
        );
        result[albumName] = isShared;
      }

      return result;
    } catch (e) {
      return {};
    }
  }

  /// Get shared status for a single album by name
  static Future<bool> isAlbumSharedByName(String albumName) async {
    try {
      final sharedAlbums = await getSharedAlbumInfo();
      return sharedAlbums.any(
        (album) => album.title == albumName && album.isShared,
      );
    } catch (e) {
      return false;
    }
  }
}
