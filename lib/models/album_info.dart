import 'dart:typed_data';

class AlbumInfo {
  final String name;
  final int count;
  final Uint8List? thumb;

  const AlbumInfo({required this.name, required this.count, this.thumb});
}
