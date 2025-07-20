import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_model.dart';

class GalleryService {
  Future<List<PhotoModel>> fetchGalleryAssets({Set<String>? excludeIds}) async {
    // Request permissions
    final permissionStatus = await Permission.photos.request();
    if (!permissionStatus.isGranted) {
      throw Exception('Photo access permission denied');
    }

    // Request photo_manager permission (for Android/iOS)
    final pmResult = await PhotoManager.requestPermissionExtend();
    if (!pmResult.hasAccess) {
      throw Exception('PhotoManager permission denied');
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
      throw Exception('No albums found.');
    }
    final allPath = paths.first;
    final assets = await allPath.getAssetListPaged(page: 0, size: 1000);
    if (assets.isEmpty) {
      throw Exception('No images found.');
    }
    // Filter out swiped assets if excludeIds is provided
    final filteredAssets =
        excludeIds == null
            ? assets
            : assets.where((a) => !excludeIds.contains(a.id)).toList();
    final List<PhotoModel> photoModels = [];
    for (final asset in filteredAssets) {
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
    }
    return photoModels;
  }
}
