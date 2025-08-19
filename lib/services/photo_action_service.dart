import '../models/photo_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoActionService {
  static const MethodChannel _favoriteChannel = MethodChannel(
    'picsor.favorite',
  );
  static const MethodChannel _albumsChannel = MethodChannel('picsor.albums');

  /// Checks the system-level favorite status for the given photo id.
  static Future<bool> isSystemFavorite(String id) async {
    try {
      final freshAsset = await AssetEntity.fromId(id);
      if (freshAsset != null) {
        return freshAsset.isFavorite;
      }
      // Use only the localIdentifier part for native call
      final systemId = id.split('/').first;
      final result = await _favoriteChannel.invokeMethod('isFavorite', {
        'id': systemId,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  /// Toggles the system-level favorite status for the given photo.
  /// Uses platform channel to call native code on Android/iOS.
  static Future<bool> toggleFavorite(PhotoModel photo) async {
    try {
      final asset = photo.asset;
      final newValue = !asset.isFavorite;
      final result = await _favoriteChannel.invokeMethod('setFavorite', {
        'id': photo.id,
        'favorite': newValue,
      });
      if (result == true) {
        // Fetch updated asset from system to reflect new favorite status
        final updated = await AssetEntity.fromId(photo.id);
        if (updated != null) {
          // If PhotoModel.asset is not final, update it:
          // photo.asset = updated;
          // If asset is final, you must update the PhotoModel in your list/UI.
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> sharePhoto(PhotoModel photo) async {
    final file = await photo.asset.file;
    if (file != null && await file.exists()) {
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
    }
  }

  static Future<bool> addToAlbum(PhotoModel photo, String albumName) async {
    try {
      final result = await _albumsChannel.invokeMethod('addToAlbum', {
        'id': photo.id,
        'album': albumName,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }

  static Future<List<String>> getAlbums() async {
    try {
      final result = await _albumsChannel.invokeMethod('getAlbums');
      if (result is List) {
        return result.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Get filtered albums (personal and shared only, excluding system and date-based albums)
  static Future<List<String>> getFilteredAlbums() async {
    try {
      final allAlbums = await getAlbums();

      // Filter out system albums and date-based albums
      final filteredAlbums =
          allAlbums.where((albumName) {
            final name = albumName.toLowerCase();

            // Filter out system albums
            if (name == 'recent' ||
                name == 'favorites' ||
                name == 'screenshots' ||
                name == 'videos' ||
                name == 'selfies' ||
                name == 'live photos' ||
                name == 'portrait' ||
                name == 'panoramas' ||
                name == 'slo-mo' ||
                name == 'bursts' ||
                name == 'long exposure' ||
                name == 'cinematic' ||
                name == 'depth effect' ||
                name == 'time-lapse' ||
                name == 'night mode' ||
                name == 'macro' ||
                name == 'photographic styles' ||
                name == 'raw' ||
                name == 'heif' ||
                name == 'all photos' ||
                name == 'camera roll' ||
                name == 'my photo stream' ||
                name == 'icloud photos' ||
                name == 'shared albums' ||
                name == 'hidden' ||
                name == 'recently deleted' ||
                name == 'imports' ||
                name == 'duplicates' ||
                name == 'receipts' ||
                name == 'handwriting' ||
                name == 'illustrations' ||
                name == 'qr codes' ||
                name == 'documents' ||
                name == 'utilities') {
              return false;
            }

            // Filter out date-based albums using regex patterns
            final datePatterns = [
              RegExp(r'^\d{2}/\d{2}/\d{4}$'), // DD/MM/YYYY
              RegExp(r'^\d{2}-\d{2}-\d{4}$'), // DD-MM-YYYY
              RegExp(r'^\d{4}-\d{2}-\d{2}$'), // YYYY-MM-DD
              RegExp(r'^\d{4}/\d{2}/\d{2}$'), // YYYY/MM/DD
              RegExp(r'^\d{2}\.\d{2}\.\d{4}$'), // DD.MM.YYYY
              RegExp(r'^\d{4}\.\d{2}\.\d{2}$'), // YYYY.MM.DD
              RegExp(r'^\d{2}\.\d{2}\.\d{4}$'), // MM.DD.YYYY
              RegExp(r'^\d{4}\.\d{2}\.\d{2}$'), // YYYY.MM.DD
              RegExp(r'^\d{8}$'), // YYYYMMDD
              RegExp(r'^\d{6}$'), // YYMMDD
              // iOS Photos app date albums with count: "01/02/2013 (1)"
              RegExp(r'^\d{2}/\d{2}/\d{4}\s*\(\d+\)$'),
              RegExp(r'^\d{2}-\d{2}-\d{4}\s*\(\d+\)$'),
              RegExp(r'^\d{4}-\d{2}-\d{2}\s*\(\d+\)$'),
              RegExp(r'^\d{4}/\d{2}/\d{2}\s*\(\d+\)$'),
            ];

            return !datePatterns.any((pattern) => pattern.hasMatch(albumName));
          }).toList();

      return filteredAlbums;
    } catch (_) {
      return [];
    }
  }

  static Future<bool> createAlbum(String albumName) async {
    try {
      final result = await _albumsChannel.invokeMethod('createAlbum', {
        'album': albumName,
      });
      return result == true;
    } catch (_) {
      return false;
    }
  }
}
