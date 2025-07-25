import '../models/photo_action.dart';
import '../models/photo_model.dart';
import 'swipe_storage_service.dart';
import 'package:flutter/foundation.dart';

class SwipeLogicService {
  int swipeCap;
  int refillAmount;
  int refillHours;
  int deckSize;

  int swipesLeft;
  DateTime? lastSwipeDate;
  DateTime? lastRefill;
  final List<PhotoAction> completedActions = [];
  final List<PhotoAction> undoStack = [];
  PhotoActionType? pendingSwipe;
  Map<String, String> swipeActions = {};

  List<PhotoModel> _deck = [];
  int deckStartIndex = 0;
  bool _isDeckInitialized = false;
  List<PhotoModel> _assets = [];

  SwipeLogicService({
    int? swipeCap,
    this.refillAmount = 125,
    this.refillHours = 5,
    this.deckSize = 5,
    int? swipesLeft,
  }) : swipeCap = swipeCap ?? 50804,
       swipesLeft = swipesLeft ?? 0;

  Future<void> loadState() async {
    swipeActions = await SwipeStorageService.loadSwipeActions();
    swipesLeft = await SwipeStorageService.loadSwipesLeft(swipeCap);
    final lastSwipeDateStr = await SwipeStorageService.loadLastSwipeDate();
    final lastRefillStr = await SwipeStorageService.loadLastRefill();
    lastSwipeDate =
        lastSwipeDateStr != null ? DateTime.tryParse(lastSwipeDateStr) : null;
    lastRefill =
        lastRefillStr != null ? DateTime.tryParse(lastRefillStr) : null;
  }

  Future<void> saveState() async {
    await SwipeStorageService.saveSwipeActions(swipeActions);
    await SwipeStorageService.saveSwipesLeft(swipesLeft);
    await SwipeStorageService.saveLastSwipeDate(
      lastSwipeDate?.toIso8601String() ?? '',
    );
    await SwipeStorageService.saveLastRefill(
      lastRefill?.toIso8601String() ?? '',
    );
  }

  void initializeDeck(List<PhotoModel> assets) {
    if (_isDeckInitialized) return;
    _assets = assets;
    final filtered =
        assets.where((a) => !swipeActions.containsKey(a.id)).toList();
    _deck = filtered.take(deckSize).toList();
    deckStartIndex = deckSize;
    _isDeckInitialized = true;
  }

  List<PhotoModel> get deck => _deck;

  void handleSwipe(PhotoAction action) {
    debugPrint('handleSwipe: BEFORE deck=${_deck.map((p) => p.id).toList()}');
    completedActions.add(action);
    undoStack.add(action);
    swipeActions[action.photo.id] = _actionTypeToString(action.action);
    swipesLeft = (swipesLeft - 1).clamp(0, swipeCap);
    lastSwipeDate = DateTime.now();
    // Remove from deck
    if (_deck.isNotEmpty && _deck.first.id == action.photo.id) {
      _deck.removeAt(0);
    } else {
      debugPrint(
        'WARNING: Tried to swipe id=${action.photo.id} but deck.first=${_deck.isNotEmpty ? _deck.first.id : 'EMPTY'}',
      );
      assert(
        _deck.isEmpty || _deck.first.id == action.photo.id,
        'Deck top does not match swiped id!',
      );
    }
    // Refill deck with next unswiped photo, prevent duplicates
    while (_assets.length > deckStartIndex) {
      final next = _assets[deckStartIndex];
      deckStartIndex++;
      if (!swipeActions.containsKey(next.id) &&
          !_deck.any((p) => p.id == next.id)) {
        _deck.add(next);
        break;
      }
    }
    debugPrint('handleSwipe: AFTER deck=${_deck.map((p) => p.id).toList()}');
    debugPrint('  swipeActions: $swipeActions');
    debugPrint(
      '  completedActions: ${completedActions.map((a) => a.photo.id).toList()}',
    );
    saveState();
  }

  void undo() {
    if (undoStack.isEmpty) return;
    final lastAction = undoStack.removeLast();
    completedActions.removeWhere((a) => a.photo.id == lastAction.photo.id);
    swipeActions.remove(lastAction.photo.id);
    swipesLeft = (swipesLeft + 1).clamp(0, swipeCap);
    // Insert photo back at top of deck
    _deck.insert(0, lastAction.photo);
    saveState();
  }

  void resetDeck() {
    _deck = [];
    deckStartIndex = 0;
    _isDeckInitialized = false;
  }

  bool canSwipe() => swipesLeft > 0;

  void swipe(PhotoAction action) {
    handleSwipe(action);
  }

  void refillIfNeeded() {
    final now = DateTime.now();
    if (lastRefill == null) {
      lastRefill = now;
      saveState();
      return;
    }
    final hoursSinceRefill = now.difference(lastRefill!).inHours;
    if (swipesLeft < swipeCap && hoursSinceRefill >= refillHours) {
      int refills = hoursSinceRefill ~/ refillHours;
      swipesLeft = (swipesLeft + refillAmount * refills).clamp(0, swipeCap);
      lastRefill = now;
      saveState();
    }
  }

  int getSwipesLeft() => swipesLeft;
  List<PhotoAction> getUndoStack() => List.unmodifiable(undoStack);
  List<PhotoAction> getCompletedActions() =>
      List.unmodifiable(completedActions);
  Map<String, String> getSwipeActions() => Map.unmodifiable(swipeActions);

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

  // Handles swiping the top card in the deck
  void handleDeckSwipe(PhotoActionType type) {
    debugPrint(
      'handleDeckSwipe: type=$type, deck BEFORE=${_deck.map((p) => p.id).toList()}',
    );
    if (_deck.isEmpty || !canSwipe()) return;
    final photo = _deck.first;
    final action = PhotoAction(photo: photo, action: type);
    handleSwipe(action);
    debugPrint(
      'handleDeckSwipe: type=$type, deck AFTER=${_deck.map((p) => p.id).toList()}',
    );
  }

  // Handles undoing the last swipe and restoring the photo to the deck
  void undoLastSwipe() {
    if (undoStack.isEmpty) return;
    undo();
  }

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

  // Returns the current top card in the deck, or null if empty
  PhotoModel? get topCard => _deck.isNotEmpty ? _deck.first : null;

  // Returns actions of a given type ('delete' or 'sort_later') using current PhotoModel from assets
  List<PhotoAction> getActionsForType(List<PhotoModel> assets, String type) {
    return assets.where((a) => swipeActions[a.id] == type).map((a) {
      final actionType =
          type == 'delete' ? PhotoActionType.delete : PhotoActionType.sortLater;
      return PhotoAction(photo: a, action: actionType);
    }).toList();
  }
}
