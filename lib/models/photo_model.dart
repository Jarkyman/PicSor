import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class PhotoModel {
  final String id;
  final AssetEntity asset;
  final DateTime? createdAt;
  final bool isVideo;
  Uint8List? thumbnailData;

  PhotoModel({
    required this.id,
    required this.asset,
    required this.createdAt,
    required this.isVideo,
    this.thumbnailData,
  });
}
