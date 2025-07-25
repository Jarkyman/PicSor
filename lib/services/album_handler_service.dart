import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/photo_action_service.dart';
import '../widgets/swipe/album_picker_dialog.dart';

class AlbumHandlerService {
  static Future<void> handleAddToAlbum(
    BuildContext context,
    PhotoModel photo,
    Function(String) showSnackBar,
  ) async {
    final result = await showAlbumPickerDialog(context, photo);

    if (result == null || result.isEmpty) return;

    if (result.startsWith('CREATE_ALBUM:')) {
      await _handleCreateNewAlbum(context, photo, result, showSnackBar);
    } else {
      await _handleAddToExistingAlbum(context, photo, result, showSnackBar);
    }
  }

  static Future<void> _handleCreateNewAlbum(
    BuildContext context,
    PhotoModel photo,
    String result,
    Function(String) showSnackBar,
  ) async {
    final albumName = result.substring('CREATE_ALBUM:'.length);
    final created = await PhotoActionService.createAlbum(albumName);

    if (!context.mounted) return;

    if (created) {
      final ok = await PhotoActionService.addToAlbum(photo, albumName);
      if (!context.mounted) return;

      if (ok) {
        showSnackBar('Photo added to album "$albumName"!');
      } else {
        showSnackBar('Album created, but failed to add photo.');
      }
    } else {
      showSnackBar('Failed to create album.');
    }
  }

  static Future<void> _handleAddToExistingAlbum(
    BuildContext context,
    PhotoModel photo,
    String albumName,
    Function(String) showSnackBar,
  ) async {
    final ok = await PhotoActionService.addToAlbum(photo, albumName);

    if (!context.mounted) return;

    if (ok) {
      showSnackBar('Photo added to album "$albumName"!');
    } else {
      showSnackBar('Failed to add photo to album.');
    }
  }
}
