import 'package:flutter/material.dart';
import '../../models/photo_model.dart';
import '../../models/photo_action.dart';
import 'swipe_card.dart';
import 'swipe_live_label_utils.dart';

class SwipeDeck extends StatefulWidget {
  final List<PhotoModel> deck;
  final void Function(PhotoActionType type) onSwipe;
  final bool isEnabled;

  const SwipeDeck({
    super.key,
    required this.deck,
    required this.onSwipe,
    this.isEnabled = true,
  });

  @override
  State<SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<SwipeDeck> with TickerProviderStateMixin {
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  PhotoActionType? _pendingSwipe;
  bool _isAnimatingOut = false;
  Offset _dragOffset = Offset.zero;
  Offset _swipeEndOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _cardAnimController;
  late Animation<Offset> _cardAnim;
  String? _dragDirection;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isAnimatingOut) {
        if (_pendingSwipe != null) {
          widget.onSwipe(_pendingSwipe!);
          setState(() {
            _isAnimatingOut = false;
            _pendingSwipe = null;
            _dragOffset = Offset.zero;
            _swipeEndOffset = Offset.zero;
          });
        }
      }
    });
    _cardAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardAnim = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(_cardAnimController);
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  void _triggerDeckSwipe(PhotoActionType type) {
    if (_isAnimatingOut || widget.deck.isEmpty) return;
    Offset endOffset;
    switch (type) {
      case PhotoActionType.delete:
        endOffset = const Offset(-2, 0);
        break;
      case PhotoActionType.keep:
        endOffset = const Offset(2, 0);
        break;
      case PhotoActionType.sortLater:
        endOffset = const Offset(0, -2);
        break;
    }
    setState(() {
      _isAnimatingOut = true;
      _pendingSwipe = type;
      _swipeAnimation = Tween<Offset>(
        begin: Offset.zero,
        end: endOffset,
      ).animate(
        CurvedAnimation(parent: _swipeController, curve: Curves.easeOut),
      );
    });
    _swipeController.forward(from: 0);
  }

  void _handleCardPanUpdate(DragUpdateDetails details) {
    setState(() {
      if (_dragDirection == null) {
        if (details.delta.dx.abs() > details.delta.dy.abs()) {
          _dragDirection = 'horizontal';
        } else if (details.delta.dy < 0) {
          _dragDirection = 'up';
        }
      }
      if (_dragDirection == 'horizontal') {
        _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
      } else if (_dragDirection == 'up') {
        final newY = _dragOffset.dy + details.delta.dy;
        _dragOffset = Offset(0, newY < 0 ? newY : 0);
      }
      _isDragging = true;
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
        _swipeEndOffset = endOffset;
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
        _swipeEndOffset = Offset.zero;
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
    if (widget.deck.isEmpty) {
      return const SizedBox.shrink();
    }
    final topPhoto = widget.deck.first;
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
                    color: liveLabelColor.withOpacity(0.8),
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
        final maxCardHeight = constraints.maxHeight;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ...List.generate(widget.deck.length, (i) {
              final renderIndex = widget.deck.length - 1 - i;
              final isTop = renderIndex == 0;
              final offsetY = i * 8.0;
              final photo = widget.deck[renderIndex];
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
              card = Transform.translate(
                offset: Offset(0, offsetY),
                child: card,
              );
              if (isTop) {
                card = AnimatedBuilder(
                  animation: _cardAnimController,
                  builder: (context, child) {
                    final offset =
                        _isDragging
                            ? _dragOffset
                            : (_cardAnimController.isAnimating
                                ? _cardAnim.value
                                : Offset.zero);
                    return GestureDetector(
                      onPanUpdate:
                          widget.isEnabled && !_isAnimatingOut
                              ? (details) => _handleCardPanUpdate(details)
                              : null,
                      onPanEnd:
                          widget.isEnabled && !_isAnimatingOut
                              ? (details) => _handleCardPanEnd(details)
                              : null,
                      child: Transform.translate(offset: offset, child: child),
                    );
                  },
                  child: card,
                );
              }
              return Positioned.fill(child: Center(child: card));
            }),
            if (floatingLabel != null) floatingLabel,
          ],
        );
      },
    );
  }
}
