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
import '../widgets/swipe/swipe_deck.dart';

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
                // b. Swipe card deck (nu SwipeDeck)
                SwipeDeck(
                  deck: _swipeLogicService.deck,
                  isEnabled:
                      _swipeLogicService.canSwipe() && !_timeCheatDetected,
                  onSwipe: (type) {
                    setState(() {
                      _swipeLogicService.handleDeckSwipe(type);
                    });
                  },
                ),
                // c. Action button group (sidder stadig øverst)
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
