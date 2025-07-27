import 'package:flutter/material.dart';
import '../core/theme.dart';
import '../services/swipe_logic_service.dart';
import '../models/photo_model.dart';
import '../models/photo_action.dart';
import 'swipe_screen.dart';
import 'deleted_screen.dart';
import 'sort_later_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final SwipeLogicService swipeLogicService;
  final List<PhotoModel> assets;

  const MainNavigationScreen({
    super.key,
    required this.swipeLogicService,
    required this.assets,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 2; // Start on swipe screen (middle)
  final List<Widget> _screens = [];
  final GlobalKey<SwipeScreenState> _swipeScreenKey =
      GlobalKey<SwipeScreenState>();

  @override
  void initState() {
    super.initState();
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens.addAll([
      DeletedScreen(
        actions: widget.swipeLogicService.getActionsForType(
          widget.assets,
          'delete',
        ),
      ),
      SortLaterScreen(
        actions: widget.swipeLogicService.getActionsForType(
          widget.assets,
          'sort_later',
        ),
      ),
      SwipeScreen(
        key: _swipeScreenKey,
        swipeLogicService: widget.swipeLogicService,
        assets: widget.assets,
        onStateChanged:
            () => setState(() {}), // Trigger rebuild when swipe state changes
        onUndo: () => setState(() {}), // Trigger rebuild when undo happens
      ),
      StatsScreen(),
      SettingsScreen(),
    ]);
  }

  void _handleUndo() {
    debugPrint(
      'MainNavigationScreen: Undo pressed, deck before: ${widget.swipeLogicService.deck.map((p) => p.id).toList()}',
    );
    setState(() {
      widget.swipeLogicService.undoLastSwipe();
    });
    debugPrint(
      'MainNavigationScreen: Undo completed, deck after: ${widget.swipeLogicService.deck.map((p) => p.id).toList()}',
    );

    // Regenerate SwipeScreen to force rebuild
    _screens[2] = SwipeScreen(
      key: _swipeScreenKey,
      swipeLogicService: widget.swipeLogicService,
      assets: widget.assets,
      onStateChanged:
          () => setState(() {}), // Trigger rebuild when swipe state changes
      onUndo: () => setState(() {}), // Trigger rebuild when undo happens
    );

    // Trigger undo animation after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _swipeScreenKey.currentState?.triggerUndoAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
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
                  ? _handleUndo
                  : null,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.sm,
        bottom: AppSpacing.lg,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.delete_outline, 'Delete'),
              _buildNavItem(1, Icons.watch_later_outlined, 'Later'),
              _buildNavItem(2, Icons.swipe, 'Swipe'),
              _buildNavItem(3, Icons.bar_chart_outlined, 'Stats'),
              _buildNavItem(4, Icons.settings_outlined, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
              size: Scale.of(context, 22),
            ),
            if (isSelected) ...[
              SizedBox(height: AppSpacing.xs),
              Text(
                label,
                style: AppTextStyles.body(context).copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: Scale.of(context, 10),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
