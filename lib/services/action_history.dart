import '../models/photo_action.dart';
import '../models/photo_model.dart';
import 'swipe_storage_service.dart';
import 'package:flutter/foundation.dart';

class ActionHistory {
  final List<PhotoAction> completedActions = [];
  final List<PhotoAction> undoStack = [];
  final Map<String, String> swipeActions = {};

  Future<void> loadState() async {
    swipeActions.addAll(await SwipeStorageService.loadSwipeActions());
  }

  Future<void> saveState() async {
    await SwipeStorageService.saveSwipeActions(swipeActions);
  }

  void addAction(PhotoAction action) {
    completedActions.add(action);
    undoStack.add(action);
    swipeActions[action.photo.id] = _actionTypeToString(action.action);
  }

  PhotoAction? undoLastAction() {
    try {
      if (undoStack.isEmpty) return null;

      final lastAction = undoStack.removeLast();
      completedActions.removeWhere((a) => a.photo.id == lastAction.photo.id);
      swipeActions.remove(lastAction.photo.id);

      return lastAction;
    } catch (e) {
      debugPrint('Error in ActionHistory.undoLastAction(): $e');
      return null;
    }
  }

  List<PhotoAction> getUndoStack() => List.unmodifiable(undoStack);
  List<PhotoAction> getCompletedActions() =>
      List.unmodifiable(completedActions);
  Map<String, String> getSwipeActions() => Map.unmodifiable(swipeActions);

  // Returns deleted actions for a given asset list
  List<PhotoAction> getDeletedActions(List<PhotoModel> assets) {
    return assets
        .where((a) => swipeActions[a.id] == 'delete')
        .map((a) => PhotoAction(photo: a, action: PhotoActionType.delete))
        .toList();
  }

  // Returns sort-later actions for a given asset list
  List<PhotoAction> getSortLaterActions(List<PhotoModel> assets) {
    return assets
        .where((a) => swipeActions[a.id] == 'sort_later')
        .map((a) => PhotoAction(photo: a, action: PhotoActionType.sortLater))
        .toList();
  }

  // Returns actions of a given type ('delete' or 'sort_later') using current PhotoModel from assets
  List<PhotoAction> getActionsForType(List<PhotoModel> assets, String type) {
    return assets.where((a) => swipeActions[a.id] == type).map((a) {
      final actionType =
          type == 'delete' ? PhotoActionType.delete : PhotoActionType.sortLater;
      return PhotoAction(photo: a, action: actionType);
    }).toList();
  }

  String _actionTypeToString(PhotoActionType type) {
    switch (type) {
      case PhotoActionType.delete:
        return 'delete';
      case PhotoActionType.keep:
        return 'keep';
      case PhotoActionType.sortLater:
        return 'sort_later';
    }
  }
}
