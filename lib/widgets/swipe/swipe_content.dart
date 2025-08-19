import 'package:flutter/material.dart';
import '../../models/photo_model.dart';
import '../../services/swipe_logic_service.dart';
import '../../services/photo_action_service.dart';
import '../../services/album_handler_service.dart';
import '../../services/thumbnail_service.dart';
import '../../core/theme.dart';
import '../../widgets/swipe/swipe_deck.dart';
import '../../widgets/swipe/swipe_action_button_group.dart';
import '../skeleton/skeleton_swipe_screen.dart';

class SwipeContent extends StatefulWidget {
  final List<PhotoModel> assets;
  final SwipeLogicService swipeLogicService;
  final bool timeCheatDetected;
  final Function(PhotoModel) onPhotoUpdated;
  final bool isLoading;
  final VoidCallback? onSwipe; // Add callback for swipe events
  final VoidCallback? onUndo; // Add callback for undo events

  const SwipeContent({
    super.key,
    required this.assets,
    required this.swipeLogicService,
    required this.timeCheatDetected,
    required this.onPhotoUpdated,
    this.isLoading = false,
    this.onSwipe,
    this.onUndo,
  });

  @override
  SwipeContentState createState() => SwipeContentState();
}

class SwipeContentState extends State<SwipeContent> {
  int _forceRebuild = 0;
  final GlobalKey<SwipeDeckState> _swipeDeckKey = GlobalKey<SwipeDeckState>();
  final ThumbnailService _thumbnailService = ThumbnailService();

  @override
  void initState() {
    super.initState();
    // Preload thumbnails for the first 20 photos
    _preloadInitialThumbnails();

    // Check if we need to animate a card on initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.swipeLogicService.deck.isNotEmpty) {
        // Check if the top card needs animation (e.g., restored from state)
        _swipeDeckKey.currentState?.checkForUndoAnimation();
      }
    });
  }

  Future<void> _preloadInitialThumbnails() async {
    if (widget.assets.isNotEmpty) {
      await _thumbnailService.preloadInitialThumbnails(widget.assets);
    }
  }

  // Method to trigger undo animation
  void triggerUndoAnimation() {
    _swipeDeckKey.currentState?.triggerUndoAnimation();
    widget.onUndo?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SkeletonSwipeScreen();
    }

    if (widget.assets.isEmpty) {
      return const Center(child: Text('No photos found'));
    }

    if (widget.swipeLogicService.deck.isEmpty) {
      return const Center(child: Text('No more photos to swipe'));
    }

    if (widget.timeCheatDetected) {
      return const Center(child: Text('Time cheat detected'));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer
        Container(color: Theme.of(context).colorScheme.surface),

        // Swipe card deck
        SwipeDeck(
          key: _swipeDeckKey,
          deck: widget.swipeLogicService.deck,
          isEnabled:
              widget.swipeLogicService.canSwipe() && !widget.timeCheatDetected,
          onSwipe: (type) {
            // Deck is updated first AFTER animation is complete (in SwipeDeck)
            widget.swipeLogicService.handleDeckSwipe(type);
            widget.onSwipe?.call(); // Trigger parent rebuild
          },
          onUndo: () {
            _swipeDeckKey.currentState?.triggerUndoAnimation();
            widget.onUndo?.call();
          },
        ),

        // Action button group
        if (widget.swipeLogicService.deck.isNotEmpty)
          Positioned(
            bottom: 24,
            right: 16,
            child: _buildActionButtonGroup(context),
          ),
      ],
    );
  }

  Widget _buildActionButtonGroup(BuildContext context) {
    return FutureBuilder<bool>(
      future: PhotoActionService.isSystemFavorite(
        widget.swipeLogicService.topCard!.id,
      ),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return SwipeActionButtonGroup(
          photo: widget.swipeLogicService.topCard!,
          isFavorite: isFavorite,
          onFavoriteToggled: widget.onPhotoUpdated,
          isInAlbum: false, // TODO: implement real check if needed
          onAddToAlbum: () => _handleAddToAlbum(context),
          onShare:
              () => PhotoActionService.sharePhoto(
                widget.swipeLogicService.topCard!,
              ),
          showSnackBar:
              (message, {action}) =>
                  _showSnackBar(context, message, action: action),
        );
      },
    );
  }

  Future<void> _handleAddToAlbum(BuildContext context) async {
    await AlbumHandlerService.handleAddToAlbum(
      context,
      widget.swipeLogicService.topCard!,
      (message) => _showSnackBar(context, message),
    );
  }

  void _showSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.body(context)),
        action: action,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
