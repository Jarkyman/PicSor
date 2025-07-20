import 'photo_model.dart';

enum PhotoActionType { delete, keep, sortLater }

class PhotoAction {
  final PhotoModel photo;
  final PhotoActionType action;

  const PhotoAction({required this.photo, required this.action});
}
