import '../models/photo_action.dart';
import '../models/photo_model.dart';
import 'package:flutter/foundation.dart';
import 'deck_manager.dart';
import 'swipe_counter.dart';
import 'action_history.dart';

class SwipeLogicService {
  late final DeckManager _deckManager;
  late final SwipeCounter _swipeCounter;
  late final ActionHistory _actionHistory;

  SwipeLogicService({
    int? swipeCap,
    int refillAmount = 125,
    int refillHours = 5,
    int deckSize = 5,
    int? swipesLeft,
  }) {
    _swipeCounter = SwipeCounter(
      swipeCap: swipeCap,
      refillAmount: refillAmount,
      refillHours: refillHours,
      swipesLeft: swipesLeft,
    );
    _actionHistory = ActionHistory();
    _deckManager = DeckManager(
      deckSize: deckSize,
      swipeActions: _actionHistory.swipeActions,
    );
  }

  Future<void> loadState() async {
    await _actionHistory.loadState();
    await _swipeCounter.loadState();
  }

  Future<void> saveState() async {
    await _actionHistory.saveState();
    await _swipeCounter.saveState();
  }

  void initializeDeck(List<PhotoModel> assets) {
    _deckManager.initializeDeck(assets);
  }

  List<PhotoModel> get deck => _deckManager.deck;

  void handleSwipe(PhotoAction action) {
    debugPrint(
      'handleSwipe: BEFORE deck=${_deckManager.deck.map((p) => p.id).toList()}',
    );

    _actionHistory.addAction(action);
    _swipeCounter.consumeSwipe();

    // Remove from deck
    if (_deckManager.deck.isNotEmpty &&
        _deckManager.deck.first.id == action.photo.id) {
      _deckManager.removeTopCard();
    } else {
      debugPrint(
        'WARNING: Tried to swipe id=${action.photo.id} but deck.first=${_deckManager.deck.isNotEmpty ? _deckManager.deck.first.id : 'EMPTY'}',
      );
      assert(
        _deckManager.deck.isEmpty ||
            _deckManager.deck.first.id == action.photo.id,
        'Deck top does not match swiped id!',
      );
    }

    // Refill deck
    _deckManager.refillDeck();

    debugPrint(
      'handleSwipe: AFTER deck=${_deckManager.deck.map((p) => p.id).toList()}',
    );
    debugPrint('  swipeActions: ${_actionHistory.swipeActions}');
    debugPrint(
      '  completedActions: ${_actionHistory.completedActions.map((a) => a.photo.id).toList()}',
    );
    saveState();
  }

  void undo() {
    final lastAction = _actionHistory.undoLastAction();
    if (lastAction != null) {
      _swipeCounter.addSwipe();
      // Insert photo back at top of deck
      _deckManager.addCardToTop(lastAction.photo);
      saveState();
    }
  }

  void resetDeck() {
    _deckManager.resetDeck();
  }

  bool canSwipe() => _swipeCounter.canSwipe();

  void swipe(PhotoAction action) {
    handleSwipe(action);
  }

  void refillIfNeeded() {
    _swipeCounter.refillIfNeeded();
  }

  int getSwipesLeft() => _swipeCounter.getSwipesLeft();
  List<PhotoAction> getUndoStack() => _actionHistory.getUndoStack();
  List<PhotoAction> getCompletedActions() =>
      _actionHistory.getCompletedActions();
  Map<String, String> getSwipeActions() => _actionHistory.getSwipeActions();

  // Handles swiping the top card in the deck
  void handleDeckSwipe(PhotoActionType type) {
    debugPrint(
      'handleDeckSwipe: type=$type, deck BEFORE=${_deckManager.deck.map((p) => p.id).toList()}',
    );
    if (_deckManager.deck.isEmpty || !canSwipe()) return;
    final photo = _deckManager.deck.first;
    final action = PhotoAction(photo: photo, action: type);
    handleSwipe(action);
    debugPrint(
      'handleDeckSwipe: type=$type, deck AFTER=${_deckManager.deck.map((p) => p.id).toList()}',
    );
  }

  // Handles undoing the last swipe and restoring the photo to the deck
  void undoLastSwipe() {
    undo();
  }

  // Returns deleted actions for a given asset list
  List<PhotoAction> getDeletedActions(List<PhotoModel> assets) {
    return _actionHistory.getDeletedActions(assets);
  }

  // Returns sort-later actions for a given asset list
  List<PhotoAction> getSortLaterActions(List<PhotoModel> assets) {
    return _actionHistory.getSortLaterActions(assets);
  }

  // Returns the current top card in the deck, or null if empty
  PhotoModel? get topCard => _deckManager.topCard;

  // Returns actions of a given type ('delete' or 'sort_later') using current PhotoModel from assets
  List<PhotoAction> getActionsForType(List<PhotoModel> assets, String type) {
    return _actionHistory.getActionsForType(assets, type);
  }

  // Getters for backward compatibility
  int get swipesLeft => _swipeCounter.swipesLeft;
  List<PhotoAction> get undoStack => _actionHistory.undoStack;
  List<PhotoAction> get completedActions => _actionHistory.completedActions;
  Map<String, String> get swipeActions => _actionHistory.swipeActions;
}
