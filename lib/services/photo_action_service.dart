import '../models/photo_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoActionService {
  static const MethodChannel _channel = MethodChannel('picsor.favorite');

  /// Checks the system-level favorite status for the given photo id.
  static Future<bool> isSystemFavorite(String id) async {
    try {
      final freshAsset = await AssetEntity.fromId(id);
      if (freshAsset != null) {
        return freshAsset.isFavorite;
      }
      // Use only the localIdentifier part for native call
      final systemId = id.split('/').first;
      final result = await _channel.invokeMethod('isFavorite', {
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
      final result = await _channel.invokeMethod('setFavorite', {
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
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  static Future<void> addToAlbum(PhotoModel photo) async {
    // Placeholder for future album logic
    // Implement using photo_manager album APIs
  }
}
