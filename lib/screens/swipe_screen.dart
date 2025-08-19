import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/swipe_logic_service.dart';
import '../widgets/swipe/swipe_app_bar.dart';
import '../widgets/swipe/swipe_content.dart';
import '../widgets/dialogs.dart';

class SwipeScreen extends StatefulWidget {
  final SwipeLogicService swipeLogicService;
  final List<PhotoModel> assets;
  final VoidCallback? onStateChanged;
  final VoidCallback? onUndo;

  const SwipeScreen({
    super.key,
    required this.swipeLogicService,
    required this.assets,
    this.onStateChanged,
    this.onUndo,
  });

  @override
  SwipeScreenState createState() => SwipeScreenState();
}

class SwipeScreenState extends State<SwipeScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late SwipeLogicService _swipeLogicService;
  final bool _timeCheatDetected = false;
  bool _isLoading = true;
  bool _isUndoing = false; // Add undo state management
  final GlobalKey<SwipeContentState> _swipeContentKey =
      GlobalKey<SwipeContentState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _swipeLogicService = widget.swipeLogicService;
    _initializeScreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshAssets();
    }
  }

  Future<void> _initializeScreen() async {
    // Initialize the deck with the provided assets
    _swipeLogicService.initializeDeck(widget.assets);

    // Simulate loading time for better UX
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshAssets() async {
    // Optionally implement refresh logic if needed
  }

  void _handleUndo() {
    // Prevent multiple undo operations
    if (_isUndoing) return;

    try {
      setState(() {
        _isUndoing = true;
      });

      // Perform undo operation
      _swipeLogicService.undoLastSwipe();

      // Update UI first
      if (mounted) {
        setState(() {
          // Force rebuild to update swipe count and undo button state
        });
      }

      // Then trigger undo animation after state is updated
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _swipeContentKey.currentState?.triggerUndoAnimation();
        // Reset undo state after animation
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _isUndoing = false;
            });
          }
        });
      });

      widget.onUndo?.call();
    } catch (e) {
      debugPrint('Error in _handleUndo: $e');
      // Fallback: just update the UI
      if (mounted) {
        setState(() {
          _isUndoing = false;
        });
      }
    }
  }

  void _handleSwipe() {
    setState(() {
      // Force rebuild to update swipe count and undo button state
    });
    widget.onStateChanged?.call();
  }

  // Method to trigger undo animation from parent
  void triggerUndoAnimation() {
    _swipeContentKey.currentState?.triggerUndoAnimation();
  }

  void _handlePhotoUpdated(PhotoModel updatedPhoto) {
    setState(() {
      final idx = widget.assets.indexWhere((p) => p.id == updatedPhoto.id);
      if (idx != -1) {
        widget.assets[idx] = updatedPhoto;
      }
      final deckIdx = _swipeLogicService.deck.indexWhere(
        (p) => p.id == updatedPhoto.id,
      );
      if (deckIdx != -1) {
        _swipeLogicService.deck[deckIdx] = updatedPhoto;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Swipe Photos',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Text(
                '${_swipeLogicService.swipesLeft} swipes',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Builder(
              builder: (context) {
                if (_timeCheatDetected) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => showTimeCheatDialog(context),
                  );
                }

                return SwipeContent(
                  key: _swipeContentKey,
                  assets: widget.assets,
                  swipeLogicService: _swipeLogicService,
                  timeCheatDetected: _timeCheatDetected,
                  onPhotoUpdated: _handlePhotoUpdated,
                  isLoading: _isLoading,
                  onSwipe: _handleSwipe,
                  onUndo: _handleUndo,
                );
              },
            ),
            // Undo button in bottom left corner
            Positioned(
              left: 20,
              bottom: 20,
              child: GestureDetector(
                onTap:
                    (_swipeLogicService.undoStack.isNotEmpty && !_isUndoing)
                        ? _handleUndo
                        : null,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        _swipeLogicService.undoStack.isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.undo_rounded,
                    color:
                        _swipeLogicService.undoStack.isNotEmpty
                            ? Colors.white
                            : Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.3),
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
