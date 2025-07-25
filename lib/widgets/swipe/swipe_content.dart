import 'package:flutter/material.dart';
import '../../models/photo_model.dart';
import '../../services/swipe_logic_service.dart';
import '../../services/photo_action_service.dart';
import '../../services/album_handler_service.dart';
import '../../core/theme.dart';
import '../../widgets/swipe/swipe_deck.dart';
import '../../widgets/swipe/swipe_action_button_group.dart';

class SwipeContent extends StatelessWidget {
  final List<PhotoModel> assets;
  final SwipeLogicService swipeLogicService;
  final bool timeCheatDetected;
  final Function(PhotoModel) onPhotoUpdated;

  const SwipeContent({
    super.key,
    required this.assets,
    required this.swipeLogicService,
    required this.timeCheatDetected,
    required this.onPhotoUpdated,
  });

  @override
  Widget build(BuildContext context) {
    if (assets.isEmpty) {
      return Center(
        child: Text('No media found.', style: AppTextStyles.body(context)),
      );
    }

    if (swipeLogicService.deck.isEmpty) {
      return Center(
        child: Text(
          'All images already swiped.',
          style: AppTextStyles.body(context),
        ),
      );
    }

    if (timeCheatDetected) {
      return Center(
        child: Text(
          'Swiping is blocked due to time manipulation.',
          style: AppTextStyles.body(context),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Background layer
        Container(color: Theme.of(context).colorScheme.surface),

        // Swipe card deck
        SwipeDeck(
          deck: swipeLogicService.deck,
          isEnabled: swipeLogicService.canSwipe() && !timeCheatDetected,
          onSwipe: (type) {
            swipeLogicService.handleDeckSwipe(type);
          },
        ),

        // Action button group
        if (swipeLogicService.deck.isNotEmpty)
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
        swipeLogicService.topCard!.id,
      ),
      builder: (context, snapshot) {
        final isFavorite = snapshot.data ?? false;
        return SwipeActionButtonGroup(
          photo: swipeLogicService.topCard!,
          isFavorite: isFavorite,
          onFavoriteToggled: onPhotoUpdated,
          isInAlbum: false, // TODO: implement real check if needed
          onAddToAlbum: () => _handleAddToAlbum(context),
          onShare:
              () => PhotoActionService.sharePhoto(swipeLogicService.topCard!),
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
      swipeLogicService.topCard!,
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
