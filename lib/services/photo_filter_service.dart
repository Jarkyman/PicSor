import '../models/photo_model.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class PhotoFilterService {
  static List<PhotoModel> filterByYear(List<PhotoModel> assets, int year) {
    return assets.where((asset) => asset.createdAt?.year == year).toList();
  }

  static List<PhotoModel> filterByType(
    List<PhotoModel> assets,
    String filterType,
  ) {
    switch (filterType) {
      case 'recent':
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        return assets
            .where((asset) => asset.createdAt?.isAfter(thirtyDaysAgo) ?? false)
            .toList();

      case 'videos':
        return assets.where((asset) => asset.isVideo).toList();

      case 'screenshots':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('screenshot') || title.contains('img_');
        }).toList();

      case 'selfies':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('selfie') || title.contains('front');
        }).toList();

      case 'live':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('live');
        }).toList();

      case 'portrait':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('portrait');
        }).toList();

      case 'panorama':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('panorama') || title.contains('pano');
        }).toList();

      case 'slomo':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('slomo') || title.contains('slow');
        }).toList();

      case 'favorites':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('favorite') || title.contains('star');
        }).toList();

      case 'duplicates':
        // This would require more sophisticated duplicate detection
        return assets.take(20).toList();

      case 'receipts':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('receipt') || title.contains('bill');
        }).toList();

      case 'handwriting':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('note') || title.contains('writing');
        }).toList();

      case 'illustrations':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('drawing') || title.contains('art');
        }).toList();

      case 'qrcodes':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('qr') || title.contains('code');
        }).toList();

      case 'imports':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('import') || title.contains('download');
        }).toList();

      case 'documents':
        return assets.where((asset) {
          final title = asset.asset.title?.toLowerCase() ?? '';
          return title.contains('doc') || title.contains('pdf');
        }).toList();

      default:
        return assets.take(20).toList();
    }
  }

  static List<PhotoModel> getRandomAssets(List<PhotoModel> assets) {
    if (assets.isEmpty) return [];

    // Generate a random start index
    final random = Random();
    final startIndex = random.nextInt(assets.length);

    // Create a new list starting from the random index
    final reorderedAssets = <PhotoModel>[];

    // Add all assets from startIndex to the end
    reorderedAssets.addAll(assets.sublist(startIndex));

    // Add all assets from the beginning to startIndex
    if (startIndex > 0) {
      reorderedAssets.addAll(assets.sublist(0, startIndex));
    }

    return reorderedAssets;
  }

  static Future<List<PhotoModel>> filterByAlbum(
    List<PhotoModel> assets,
    AssetPathEntity album,
  ) async {
    try {
      final albumAssets = await album.getAssetListPaged(
        page: 0,
        size: 100000,
      ); // Load all photos (very large number)
      final albumAssetIds = albumAssets.map((a) => a.id).toSet();

      return assets.where((asset) => albumAssetIds.contains(asset.id)).toList();
    } catch (e) {
      // Fallback to a subset if album access fails
      return assets.take(20).toList();
    }
  }

  static List<int> getAvailableYears(List<PhotoModel> assets) {
    final years = <int>{};
    for (final asset in assets) {
      if (asset.createdAt != null) {
        years.add(asset.createdAt!.year);
      }
    }
    return years.toList()..sort((a, b) => b.compareTo(a)); // Most recent first
  }
}
