import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_model.dart';
import '../models/photo_action.dart';
import '../core/app_routes.dart';
import '../services/swipe_logic_service.dart';
import '../services/photo_action_service.dart';
import '../widgets/swipe/swipe_card.dart';
import '../widgets/swipe/swipe_action_button_group.dart';
import '../widgets/swipe/swipe_live_label_utils.dart';
import 'dart:io';
import 'dart:ui';
import '../widgets/dialogs.dart';
import '../models/album_info.dart';
import '../widgets/swipe/album_picker_dialog.dart';
import '../core/theme.dart';

class SwipeScreen extends StatefulWidget {
  final SwipeLogicService swipeLogicService;
  final List<PhotoModel> assets;

  const SwipeScreen({
    super.key,
    required this.swipeLogicService,
    required this.assets,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late SwipeLogicService _swipeLogicService;
  bool _timeCheatDetected = false;
  late AnimationController _swipeController;
  late Animation<Offset> _swipeAnimation;
  PhotoActionType? _pendingSwipe;
  bool _isAnimatingOut = false;
  Offset _dragOffset = Offset.zero;
  Offset _swipeEndOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _cardAnimController;
  late Animation<Offset> _cardAnim;
  String? _dragDirection; // 'horizontal' or 'up' or null

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _swipeLogicService = widget.swipeLogicService;
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeController.addStatusListener((status) {
      debugPrint(
        'SWIPE ANIMATION STATUS: $status, _isAnimatingOut=$_isAnimatingOut, _pendingSwipe=$_pendingSwipe',
      );
      if (status == AnimationStatus.completed && _isAnimatingOut) {
        debugPrint(
          'SWIPE ANIMATION COMPLETED: _isAnimatingOut=$_isAnimatingOut, _pendingSwipe=$_pendingSwipe',
        );
        if (_pendingSwipe != null) {
          debugPrint(
            'SWIPE ANIMATION COMPLETED: calling handleDeckSwipe(${_pendingSwipe!})',
          );
          setState(() {
            _swipeLogicService.handleDeckSwipe(_pendingSwipe!);
            debugPrint(
              'SWIPE ANIMATION COMPLETED: handleDeckSwipe done, resetting _isAnimatingOut and _pendingSwipe',
            );
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
    WidgetsBinding.instance.removeObserver(this);
    _swipeController.dispose();
    _cardAnimController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAssets();
    }
  }

  Future<void> _refreshAssets() async {
    // Optionally implement refresh logic if needed
  }

  /// Triggers a deck swipe animation.
  ///
  /// @param type The type of swipe action to trigger.
  void _triggerDeckSwipe(PhotoActionType type) {
    debugPrint(
      'CALL: _triggerDeckSwipe($type), _isAnimatingOut=$_isAnimatingOut, deckEmpty=${_swipeLogicService.deck.isEmpty}, _pendingSwipe=$_pendingSwipe',
    );
    if (_isAnimatingOut || _swipeLogicService.deck.isEmpty) return;
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
    debugPrint(
      'CALL: _swipeController.forward(from: 0) from _triggerDeckSwipe',
    );
    _swipeController.forward(from: 0);
  }

  /// Handles the update of the card pan.
  ///
  /// @param details The details of the drag update.
  void _handleCardPanUpdate(DragUpdateDetails details) {
    setState(() {
      // Determine drag direction on first update
      if (_dragDirection == null) {
        if (details.delta.dx.abs() > details.delta.dy.abs()) {
          _dragDirection = 'horizontal';
        } else if (details.delta.dy < 0) {
          _dragDirection = 'up';
        }
      }
      // Only allow horizontal or up
      if (_dragDirection == 'horizontal') {
        _dragOffset = Offset(_dragOffset.dx + details.delta.dx, 0);
      } else if (_dragDirection == 'up') {
        final newY = _dragOffset.dy + details.delta.dy;
        _dragOffset = Offset(0, newY < 0 ? newY : 0); // Clamp to ≤ 0
      }
      _isDragging = true;
    });
  }

  /// Handles the end of the card pan.
  ///
  /// @param details The details of the drag end.
  void _handleCardPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    // Thresholds
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
      debugPrint(
        'Gesture: _handleDeckPanEnd triggers _triggerDeckSwipe($type)',
      );
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
      // Animate back to center
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
    if (_swipeLogicService.deck.isNotEmpty) {
      final top = _swipeLogicService.topCard!;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('PicSor', style: AppTextStyles.title(context)),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Center(
              child: Text(
                '${_swipeLogicService.swipesLeft} swipes',
                style: AppTextStyles.label(context),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.undo, size: Scale.of(context, 24)),
            tooltip: 'Undo',
            onPressed:
                _swipeLogicService.undoStack.isNotEmpty
                    ? () {
                      setState(() {
                        _swipeLogicService.undoLastSwipe();
                      });
                    }
                    : null,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: Scale.of(context, 24)),
            tooltip: 'Deleted',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.deleted,
                arguments: _swipeLogicService.getActionsForType(
                  widget.assets,
                  'delete',
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.watch_later_outlined, size: Scale.of(context, 24)),
            tooltip: 'Sort Later',
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.sortLater,
                arguments: _swipeLogicService.getActionsForType(
                  widget.assets,
                  'sort_later',
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (widget.assets.isEmpty) {
              return Center(
                child: Text(
                  'No media found.',
                  style: AppTextStyles.body(context),
                ),
              );
            }
            if (_swipeLogicService.deck.isEmpty) {
              return Center(
                child: Text(
                  'All images already swiped.',
                  style: AppTextStyles.body(context),
                ),
              );
            }
            if (_timeCheatDetected) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => showTimeCheatDialog(context),
              );
              return Center(
                child: Text(
                  'Swiping is blocked due to time manipulation.',
                  style: AppTextStyles.body(context),
                ),
              );
            }
            // Live label logic
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
                  padding = EdgeInsets.only(right: AppSpacing.lg);
                  break;
                case 'Delete':
                  alignment = Alignment.centerLeft;
                  padding = EdgeInsets.only(left: AppSpacing.lg);
                  break;
                case 'Sort later':
                  alignment = Alignment.topCenter;
                  padding = EdgeInsets.only(top: AppSpacing.xl);
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
                      style: AppTextStyles.headline(context).copyWith(
                        color: liveLabelColor,
                        fontSize: Scale.of(context, 36),
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
            return Stack(
              fit: StackFit.expand,
              children: [
                // a. Background layer
                Container(color: Theme.of(context).colorScheme.surface),
                // b. Swipe card deck
                Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final maxCardWidth = constraints.maxWidth;
                      final maxCardHeight = constraints.maxHeight;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Card stack
                          ...List.generate(_swipeLogicService.deck.length, (i) {
                            final renderIndex =
                                _swipeLogicService.deck.length - 1 - i;
                            final isTop = renderIndex == 0;
                            final offsetY = i * 8.0;
                            final photo = _swipeLogicService.deck[renderIndex];
                            final aspectRatio =
                                (photo.asset.width > 0 &&
                                        photo.asset.height > 0)
                                    ? photo.asset.width / photo.asset.height
                                    : 1.0;
                            // Calculate card size to fit inside max bounds
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
                                // evt. liveLabel props
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
                                        _swipeLogicService.canSwipe() &&
                                                !_isAnimatingOut
                                            ? (details) {
                                              _handleCardPanUpdate(details);
                                            }
                                            : null,
                                    onPanEnd:
                                        _swipeLogicService.canSwipe() &&
                                                !_isAnimatingOut
                                            ? (details) {
                                              _handleCardPanEnd(details);
                                            }
                                            : null,
                                    child: Transform.translate(
                                      offset: offset,
                                      child: child,
                                    ),
                                  );
                                },
                                child: card,
                              );
                            }
                            return Positioned.fill(child: Center(child: card));
                          }),
                          // Floating live label
                          if (floatingLabel != null) floatingLabel,
                        ],
                      );
                    },
                  ),
                ),
                // c. Action button group (last child, always on top)
                if (_swipeLogicService.deck.isNotEmpty)
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: FutureBuilder<bool>(
                      future: PhotoActionService.isSystemFavorite(
                        _swipeLogicService.topCard!.id,
                      ),
                      builder: (context, snapshot) {
                        final isFavorite = snapshot.data ?? false;
                        return SwipeActionButtonGroup(
                          photo: _swipeLogicService.topCard!,
                          isFavorite: isFavorite,
                          onFavoriteToggled: (updatedPhoto) {
                            setState(() {
                              final idx = widget.assets.indexWhere(
                                (p) => p.id == updatedPhoto.id,
                              );
                              if (idx != -1) {
                                widget.assets[idx] = updatedPhoto;
                              }
                              final deckIdx = _swipeLogicService.deck
                                  .indexWhere((p) => p.id == updatedPhoto.id);
                              if (deckIdx != -1) {
                                _swipeLogicService.deck[deckIdx] = updatedPhoto;
                              }
                            });
                          },
                          isInAlbum:
                              false, // TODO: implement real check if needed
                          onAddToAlbum: () async {
                            final result = await showAlbumPickerDialog(
                              context,
                              _swipeLogicService.topCard!,
                            );
                            if (result != null &&
                                result.startsWith('CREATE_ALBUM:')) {
                              final albumName = result.substring(
                                'CREATE_ALBUM:'.length,
                              );
                              final created =
                                  await PhotoActionService.createAlbum(
                                    albumName,
                                  );
                              if (!mounted) return;
                              if (created) {
                                final ok = await PhotoActionService.addToAlbum(
                                  _swipeLogicService.topCard!,
                                  albumName,
                                );
                                if (ok) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Photo added to album "$albumName"!',
                                        style: AppTextStyles.body(context),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Album created, but failed to add photo.',
                                        style: AppTextStyles.body(context),
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to create album.',
                                      style: AppTextStyles.body(context),
                                    ),
                                  ),
                                );
                              }
                            } else if (result != null && result.isNotEmpty) {
                              final ok = await PhotoActionService.addToAlbum(
                                _swipeLogicService.topCard!,
                                result,
                              );
                              if (!mounted) return;
                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Photo added to album "$result"!',
                                      style: AppTextStyles.body(context),
                                    ),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to add photo to album.',
                                      style: AppTextStyles.body(context),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                          onShare:
                              () => PhotoActionService.sharePhoto(
                                _swipeLogicService.topCard!,
                              ),
                          showSnackBar: (message, {action}) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message,
                                  style: AppTextStyles.body(context),
                                ),
                                action: action,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
