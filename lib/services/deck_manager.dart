import '../models/photo_model.dart';

class DeckManager {
  List<PhotoModel> _deck = [];
  int deckStartIndex = 0;
  bool _isDeckInitialized = false;
  List<PhotoModel> _assets = [];
  final int deckSize;
  final Map<String, String> swipeActions;

  DeckManager({this.deckSize = 5, required this.swipeActions});

  List<PhotoModel> get deck => _deck;

  void initializeDeck(List<PhotoModel> assets) {
    if (_isDeckInitialized) return;
    _assets = assets;
    final filtered =
        assets.where((a) => !swipeActions.containsKey(a.id)).toList();
    _deck = filtered.take(deckSize).toList();
    deckStartIndex = deckSize;
    _isDeckInitialized = true;
  }

  void removeTopCard() {
    if (_deck.isNotEmpty) {
      _deck.removeAt(0);
    }
  }

  void addCardToTop(PhotoModel photo) {
    _deck.insert(0, photo);
  }

  void refillDeck() {
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
  }

  PhotoModel? get topCard => _deck.isNotEmpty ? _deck.first : null;

  void resetDeck() {
    _deck = [];
    deckStartIndex = 0;
    _isDeckInitialized = false;
  }

  void updateSwipeActions(Map<String, String> newSwipeActions) {
    // This method allows external updates to swipeActions
    // In a real implementation, you might want to use a callback or stream
  }
}
