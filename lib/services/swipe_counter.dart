import 'swipe_storage_service.dart';

class SwipeCounter {
  int swipeCap;
  int refillAmount;
  int refillHours;

  int swipesLeft;
  DateTime? lastSwipeDate;
  DateTime? lastRefill;

  SwipeCounter({
    int? swipeCap,
    this.refillAmount = 125,
    this.refillHours = 5,
    int? swipesLeft,
  }) : swipeCap = swipeCap ?? 50804,
       swipesLeft = swipesLeft ?? 0;

  Future<void> loadState() async {
    swipesLeft = await SwipeStorageService.loadSwipesLeft(swipeCap);
    final lastSwipeDateStr = await SwipeStorageService.loadLastSwipeDate();
    final lastRefillStr = await SwipeStorageService.loadLastRefill();
    lastSwipeDate =
        lastSwipeDateStr != null ? DateTime.tryParse(lastSwipeDateStr) : null;
    lastRefill =
        lastRefillStr != null ? DateTime.tryParse(lastRefillStr) : null;
  }

  Future<void> saveState() async {
    await SwipeStorageService.saveSwipesLeft(swipesLeft);
    await SwipeStorageService.saveLastSwipeDate(
      lastSwipeDate?.toIso8601String() ?? '',
    );
    await SwipeStorageService.saveLastRefill(
      lastRefill?.toIso8601String() ?? '',
    );
  }

  void consumeSwipe() {
    swipesLeft = (swipesLeft - 1).clamp(0, swipeCap);
    lastSwipeDate = DateTime.now();
  }

  void addSwipe() {
    swipesLeft = (swipesLeft + 1).clamp(0, swipeCap);
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

  bool canSwipe() => swipesLeft > 0;

  int getSwipesLeft() => swipesLeft;

  void setSwipesLeft(int value) {
    swipesLeft = value.clamp(0, swipeCap);
  }
}
