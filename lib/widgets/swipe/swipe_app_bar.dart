import 'package:flutter/material.dart';
import '../../core/app_routes.dart';
import '../../core/theme.dart';
import '../../services/swipe_logic_service.dart';
import '../../models/photo_model.dart';

class SwipeAppBar extends StatefulWidget implements PreferredSizeWidget {
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
  State<SwipeAppBar> createState() => _SwipeAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SwipeAppBarState extends State<SwipeAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('PicSor', style: AppTextStyles.title(context)),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Center(
            child: Text(
              '${widget.swipeLogicService.swipesLeft} swipes',
              style: AppTextStyles.label(context),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.undo, size: Scale.of(context, 24)),
          tooltip: 'Undo',
          onPressed:
              widget.swipeLogicService.undoStack.isNotEmpty
                  ? () {
                    widget.onUndo();
                    setState(() {}); // Trigger rebuild after undo
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
              arguments: widget.swipeLogicService.getActionsForType(
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
              arguments: widget.swipeLogicService.getActionsForType(
                widget.assets,
                'sort_later',
              ),
            );
          },
        ),
      ],
    );
  }
}
