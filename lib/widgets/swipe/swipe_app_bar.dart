import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/theme.dart';
import '../../services/swipe_logic_service.dart';
import '../../models/photo_model.dart';

class SwipeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final SwipeLogicService swipeLogicService;
  final List<PhotoModel> assets;
  final VoidCallback onUndo;

  const SwipeAppBar({
    super.key,
    required this.swipeLogicService,
    required this.assets,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('PicSor', style: AppTextStyles.title(context)),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: Text(
              '${swipeLogicService.swipesLeft} swipes',
              style: AppTextStyles.label(context),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.undo, size: Scale.of(context, 24)),
          tooltip: 'Undo',
          onPressed: swipeLogicService.undoStack.isNotEmpty ? onUndo : null,
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, size: Scale.of(context, 24)),
          tooltip: 'Deleted',
          onPressed: () {
            Navigator.pushNamed(
              context,
              AppRoutes.deleted,
              arguments: swipeLogicService.getActionsForType(assets, 'delete'),
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
              arguments: swipeLogicService.getActionsForType(
                assets,
                'sort_later',
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
