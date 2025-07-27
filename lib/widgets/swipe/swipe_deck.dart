import 'package:flutter/material.dart';
import '../../models/photo_model.dart';
import '../../models/photo_action.dart';
import 'swipe_card.dart';
import 'swipe_live_label_utils.dart';

class SwipeDeck extends StatefulWidget {
  final List<PhotoModel> deck;
  final void Function(PhotoActionType type) onSwipe;
  final bool isEnabled;
  final VoidCallback? onUndo; // Added callback for undo events

  const SwipeDeck({
    super.key,
    required this.deck,
    required this.onSwipe,
    this.isEnabled = true,
    this.onUndo,
  });

  @override
  SwipeDeckState createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck> with TickerProviderStateMixin {
  late AnimationController _swipeController;
  PhotoActionType? _pendingSwipe;
  bool _isAnimatingOut = false;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _cardAnimController;
  late Animation<Offset> _cardAnim;
  String? _dragDirection;
  bool _isUndoAnimation = false;
  PhotoActionType? _lastSwipeDirection;
  final Map<String, PhotoActionType> _swipeDirections = {};
  String? _removingCardId;
  // Animation for next card promotion
  late AnimationController _nextCardAnimController;
  late Animation<double> _nextCardOffsetAnim;
  late Animation<double> _nextCardOverlayAnim;
  bool _promoteNextCard = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isAnimatingOut) {
        if (_pendingSwipe != null && _removingCardId != null) {
          widget.onSwipe(_pendingSwipe!); // deck fjernes her
          setState(() {
            _isAnimatingOut = false;
            _pendingSwipe = null;
            _dragOffset = Offset.zero;
            _removingCardId = null;
            _promoteNextCard = true;
            _nextCardAnimController.forward(from: 0);
          });
          // Reset next card animation to ensure clean state
          _nextCardAnimController.reset();
          // Ensure next card animation starts from 0 when new card becomes top
          _nextCardOffsetAnim = Tween<double>(begin: 0.0, end: 0.0).animate(
            CurvedAnimation(
              parent: _nextCardAnimController,
              curve: Curves.easeOutCubic,
            ),
          );
        }
      }
    });
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 400,
      ), // Undo-animation lidt langsommere
    );
    _cardAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_cardAnimController);
    _nextCardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _nextCardOffsetAnim = Tween<double>(begin: 8.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _nextCardAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _nextCardOverlayAnim = Tween<double>(begin: 0.18, end: 0.0).animate(
      CurvedAnimation(
        parent: _nextCardAnimController,
        curve: Curves.easeOutCubic,
      ),
    );
    _nextCardAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _promoteNextCard = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _cardAnimController.dispose();
    _nextCardAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugPrint(
      'SwipeDeck didUpdateWidget: old deck length = ${oldWidget.deck.length}, new deck length = ${widget.deck.length}',
    );
    // Check if this is an undo (deck got bigger)
    if (widget.deck.length > oldWidget.deck.length) {
      debugPrint('SwipeDeck: Undo detected! Triggering animation...');
      _animateUndo();
    }
  }

  void _animateUndo() {
    // Find retning for det nye topkort
    if (widget.deck.isEmpty) return;
    final topCardId = widget.deck.first.id;
    final direction =
        _swipeDirections[topCardId] ??
        PhotoActionType.keep; // fallback to right
    setState(() {
      _isUndoAnimation = true;
    });

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Offset startOffset;
    switch (direction) {
      case PhotoActionType.delete:
        startOffset = Offset(-width, 0); // Fra venstre
        break;
      case PhotoActionType.keep:
        startOffset = Offset(width, 0); // From right
        break;
      case PhotoActionType.sortLater:
        startOffset = Offset(0, -height); // Fra toppen
        break;
    }

    _cardAnim = Tween<Offset>(begin: startOffset, end: Offset.zero).animate(
      CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOutCubic),
    );

    _cardAnimController.reset();
    _cardAnimController.forward();

    // Reset state after animation
    _cardAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isUndoAnimation = false;
          // Remove swipe direction for this card so undo can happen multiple times
          _swipeDirections.remove(topCardId);
        });
        _cardAnimController.removeStatusListener((status) {});
      }
    });
  }

  // Public method to trigger undo animation
  void triggerUndoAnimation() {
    _animateUndo();
  }

  // Method called when undo happens
  void onUndoTriggered() {
    debugPrint(
      'SwipeDeck: onUndoTriggered called, triggering undo animation...',
    );
    widget.onUndo?.call();
    _animateUndo();
  }

  void _triggerDeckSwipe(PhotoActionType type) {
    if (_isAnimatingOut || widget.deck.isEmpty) return;
    setState(() {
      _isAnimatingOut = true;
      _pendingSwipe = type;
      _lastSwipeDirection = type; // Gem retning for undo animation
      if (widget.deck.isNotEmpty) {
        _removingCardId = widget.deck.first.id;
        _swipeDirections[widget.deck.first.id] = type;
      }
    });
    _swipeController.forward(from: 0);
  }

  void _handleCardPanStart(DragStartDetails details) {
    setState(() {
      _dragOffset = Offset.zero;
      _dragDirection = null;
      _isDragging = false;
    });
  }

  void _handleCardPanUpdate(DragUpdateDetails details) {
    debugPrint(
      'SwipeDeck: BEFORE update - _dragOffset = $_dragOffset, _dragDirection = $_dragDirection',
    );
    setState(() {
      // Determine direction first based on delta
      if (_dragDirection == null) {
        if (details.delta.dx.abs() > details.delta.dy.abs()) {
          _dragDirection = 'horizontal';
        } else if (details.delta.dy < 0) {
          _dragDirection = 'up';
        }
      }

      // Update offset based on direction - only allow right, left, and up
      if (_dragDirection == 'horizontal') {
        _dragOffset = Offset(
          _dragOffset.dx + details.delta.dx,
          0, // Keep Y at 0 for horizontal swipes
        );
      } else if (_dragDirection == 'up') {
        final newY = _dragOffset.dy + details.delta.dy;
        _dragOffset = Offset(
          0, // Keep X at 0 for vertical swipes
          newY < 0 ? newY : 0, // Only allow upward movement
        );
      }

      _isDragging = true;
      debugPrint(
        'SwipeDeck: AFTER update - _dragOffset = $_dragOffset, _dragDirection = $_dragDirection, _isDragging = $_isDragging, _promoteNextCard = $_promoteNextCard, _nextCardOffsetAnim = ${_nextCardOffsetAnim.value}',
      );
    });
  }

  void _handleCardPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    const minDrag = 80.0;
    const minVelocity = 800.0;
    Offset endOffset = Offset.zero;
    PhotoActionType? type;
    if (_dragDirection == 'horizontal') {
      if (dx < -minDrag || velocity.dx < -minVelocity) {
        endOffset = Offset(-width, 0);
        type = PhotoActionType.delete;
      } else if (dx > minDrag || velocity.dx > minVelocity) {
        endOffset = Offset(width, 0);
        type = PhotoActionType.keep;
      }
    } else if (_dragDirection == 'up') {
      if (dy < -minDrag || velocity.dy < -minVelocity) {
        endOffset = Offset(0, -height);
        type = PhotoActionType.sortLater;
      }
    }
    if (type != null) {
      setState(() {
        _isDragging = false;
        _dragDirection = null;
      });
      _cardAnim = Tween<Offset>(begin: _dragOffset, end: endOffset).animate(
        CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut),
      );
      _cardAnimController.reset();
      _cardAnimController.forward();
      _triggerDeckSwipe(type);
    } else {
      setState(() {
        _isDragging = false;
        _dragDirection = null;
      });
      _cardAnim = Tween<Offset>(begin: _dragOffset, end: Offset.zero).animate(
        CurvedAnimation(parent: _cardAnimController, curve: Curves.easeOut),
      );
      _cardAnimController.reset();
      _cardAnimController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'SwipeDeck build: deck length = ${widget.deck.length}, deck IDs = ${widget.deck.map((p) => p.id).toList()}',
    );

    if (widget.deck.isEmpty) {
      return const SizedBox.shrink();
    }

    final liveLabel = getLiveLabel(_dragOffset, _isDragging);
    final liveLabelColor = getLiveLabelColor(_dragOffset, _isDragging);
    final showLiveLabel = shouldShowLiveLabel(_dragOffset, _isDragging);
    Widget? floatingLabel;
    if (showLiveLabel && liveLabel != null && liveLabelColor != null) {
      Alignment alignment = Alignment.center;
      EdgeInsets padding = EdgeInsets.zero;
      switch (liveLabel) {
        case 'Keep':
          alignment = Alignment.centerRight;
          padding = EdgeInsets.only(right: 24);
          break;
        case 'Delete':
          alignment = Alignment.centerLeft;
          padding = EdgeInsets.only(left: 24);
          break;
        case 'Sort later':
          alignment = Alignment.topCenter;
          padding = EdgeInsets.only(top: 32);
          break;
      }
      floatingLabel = Align(
        alignment: alignment,
        child: AnimatedOpacity(
          opacity: showLiveLabel ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 120),
          child: Padding(
            padding: padding,
            child: Text(
              liveLabel,
              style: TextStyle(
                color: liveLabelColor,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    blurRadius: 24,
                    color: liveLabelColor.withValues(alpha: 0.8),
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = constraints.maxWidth;
        // Add padding at bottom so cards are not under bottom bar
        final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
        final maxCardHeight = constraints.maxHeight - bottomPadding;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Render all cards, but if a card is _removingCardId, animate it out
            ...List.generate(widget.deck.length, (i) {
              final renderIndex = widget.deck.length - 1 - i;
              final photo = widget.deck[renderIndex];
              final isTop = renderIndex == 0;
              final isNext = renderIndex == 1;
              final isRemoving = _removingCardId == photo.id;
              double offsetY = 0.0;
              if (isTop) {
                // Top card should always be at center (no offset)
                offsetY = 0.0;
              } else if (isNext && _promoteNextCard) {
                // Animate next card up
                offsetY = _nextCardOffsetAnim.value;
              } else {
                // Underliggende kort har stacking offset
                offsetY = i * 8.0;
              }
              debugPrint(
                'Card $i (isTop: $isTop, renderIndex: $renderIndex): offsetY = $offsetY, _isDragging = $_isDragging, photo.id = ${photo.id}, _removingCardId = $_removingCardId',
              );
              final aspectRatio =
                  (photo.asset.width > 0 && photo.asset.height > 0)
                      ? photo.asset.width / photo.asset.height
                      : 1.0;
              double cardWidth = maxCardWidth;
              double cardHeight = cardWidth / aspectRatio;
              if (cardHeight > maxCardHeight) {
                cardHeight = maxCardHeight;
                cardWidth = cardHeight * aspectRatio;
              }
              Widget card = SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: SwipeCard(
                  photo: photo,
                  isTop: isTop,
                  aspectRatio: aspectRatio,
                ),
              );
              Widget animatedCard;
              if (isTop) {
                animatedCard = AnimatedBuilder(
                  animation: _cardAnimController,
                  builder: (context, child) {
                    final offset =
                        _isDragging && !isRemoving
                            ? _dragOffset
                            : (_cardAnimController.isAnimating ||
                                    _isUndoAnimation
                                ? _cardAnim.value
                                : Offset.zero);

                    // Use the offset with direction restrictions
                    final combinedOffset = offset;

                    debugPrint(
                      'AnimatedBuilder: _isDragging = $_isDragging, offset = $offset, combinedOffset = $combinedOffset, _dragDirection = $_dragDirection',
                    );

                    return GestureDetector(
                      onPanStart: !isRemoving ? _handleCardPanStart : null,
                      onPanUpdate: !isRemoving ? _handleCardPanUpdate : null,
                      onPanEnd: !isRemoving ? _handleCardPanEnd : null,
                      child: Stack(
                        children: [
                          Transform.translate(
                            offset: combinedOffset,
                            child: child,
                          ),
                          // Temporarily disable live label overlay to test
                          // if (_isDragging && !isRemoving)
                          //   _buildLiveLabelOverlay(),
                        ],
                      ),
                    );
                  },
                  child: card,
                );
              } else if (isNext && _promoteNextCard) {
                animatedCard = AnimatedBuilder(
                  animation: _nextCardAnimController,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        child!,
                        if (_nextCardOverlayAnim.value > 0)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: _nextCardOverlayAnim.value,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  child: card,
                );
              } else {
                animatedCard = card;
              }
              return Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset:
                        isTop
                            ? Offset.zero
                            : (isNext && _promoteNextCard
                                ? Offset(0, _nextCardOffsetAnim.value)
                                : Offset(0, offsetY)),
                    child: animatedCard,
                  ),
                ),
              );
            }),
            if (floatingLabel != null) floatingLabel,
          ],
        );
      },
    );
  }

  // Helper til at bygge overlay/livelabel under drag
  Widget _buildLiveLabelOverlay() {
    final liveLabel = getLiveLabel(_dragOffset, true);
    final liveLabelColor = getLiveLabelColor(_dragOffset, true);
    final showLiveLabel = shouldShowLiveLabel(_dragOffset, true);
    debugPrint(
      'LiveLabel: showLiveLabel = $showLiveLabel, liveLabel = $liveLabel, _dragOffset = $_dragOffset',
    );
    if (showLiveLabel && liveLabel != null && liveLabelColor != null) {
      Alignment alignment = Alignment.center;
      EdgeInsets padding = EdgeInsets.zero;
      switch (liveLabel) {
        case 'Keep':
          alignment = Alignment.centerRight;
          padding = EdgeInsets.only(right: 24);
          break;
        case 'Delete':
          alignment = Alignment.centerLeft;
          padding = EdgeInsets.only(left: 24);
          break;
        case 'Sort later':
          alignment = Alignment.topCenter;
          padding = EdgeInsets.only(top: 32);
          break;
      }
      return Align(
        alignment: alignment,
        child: Padding(
          padding: padding,
          child: Text(
            liveLabel,
            style: TextStyle(
              color: liveLabelColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  blurRadius: 24,
                  color: liveLabelColor.withValues(alpha: 0.8),
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
