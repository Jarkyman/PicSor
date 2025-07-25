import 'package:flutter/material.dart';
import '../models/photo_model.dart';
import '../services/swipe_logic_service.dart';
import '../widgets/swipe/swipe_app_bar.dart';
import '../widgets/swipe/swipe_content.dart';
import '../widgets/dialogs.dart';

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
  final bool _timeCheatDetected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _swipeLogicService = widget.swipeLogicService;
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

  Future<void> _refreshAssets() async {
    // Optionally implement refresh logic if needed
  }

  void _handleUndo() {
    setState(() {
      _swipeLogicService.undoLastSwipe();
    });
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
      appBar: SwipeAppBar(
        swipeLogicService: _swipeLogicService,
        assets: widget.assets,
        onUndo: _handleUndo,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (_timeCheatDetected) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => showTimeCheatDialog(context),
              );
            }

            return SwipeContent(
              assets: widget.assets,
              swipeLogicService: _swipeLogicService,
              timeCheatDetected: _timeCheatDetected,
              onPhotoUpdated: _handlePhotoUpdated,
            );
          },
        ),
      ),
    );
  }
}
