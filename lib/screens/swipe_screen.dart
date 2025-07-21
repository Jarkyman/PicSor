import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/gallery_service.dart';
import '../models/photo_model.dart';
import '../models/photo_action.dart';
import 'dart:typed_data';
import '../app.dart';
import '../core/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../services/swipe_logic_service.dart';
import '../services/swipe_storage_service.dart';
import '../services/photo_action_service.dart';
import '../widgets/swipe_card.dart';
import '../widgets/swipe_action_button_group.dart';
import '../widgets/floating_live_label.dart';
import 'dart:io';
import 'dart:ui';

class _AlbumInfo {
  final String name;
  final int count;
  final Uint8List? thumb;
  _AlbumInfo({required this.name, required this.count, this.thumb});
}

class SwipeScreen extends StatefulWidget {
  final SwipeLogicService swipeLogicService;
  final List<PhotoModel> assets;

  const SwipeScreen({
    Key? key,
    required this.swipeLogicService,
    required this.assets,
  }) : super(key: key);

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
      print(
        'SWIPE ANIMATION STATUS: $status, _isAnimatingOut=$_isAnimatingOut, _pendingSwipe=$_pendingSwipe',
      );
      if (status == AnimationStatus.completed && _isAnimatingOut) {
        print(
          'SWIPE ANIMATION COMPLETED: _isAnimatingOut=$_isAnimatingOut, _pendingSwipe=$_pendingSwipe',
        );
        if (_pendingSwipe != null) {
          print(
            'SWIPE ANIMATION COMPLETED: calling handleDeckSwipe(${_pendingSwipe!})',
          );
          setState(() {
            _swipeLogicService.handleDeckSwipe(_pendingSwipe!);
            print(
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

  void _showTimeCheatDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Time Manipulation Detected'),
            content: const Text(
              'Device time appears to have been set backwards. Swiping is blocked. Please correct your system time.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  void _onDeckSwipe(PhotoActionType type) {
    print(
      'CALL: _onDeckSwipe($type), _isAnimatingOut=$_isAnimatingOut, _pendingSwipe=$_pendingSwipe',
    );
    // No longer update deck here; handled in animation completed listener
    setState(() {
      _isAnimatingOut = true;
      _pendingSwipe = type;
    });
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
    _swipeAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: endOffset,
    ).animate(CurvedAnimation(parent: _swipeController, curve: Curves.easeOut));
    print('CALL: _swipeController.forward(from: 0) from _onDeckSwipe');
    _swipeController.forward(from: 0);
  }

  void _triggerDeckSwipe(PhotoActionType type) {
    print(
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
    print('CALL: _swipeController.forward(from: 0) from _triggerDeckSwipe');
    _swipeController.forward(from: 0);
  }

  void _handleDeckPanEnd(DragEndDetails details) {
    if (_isAnimatingOut || _swipeLogicService.deck.isEmpty) return;
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.dx.abs() > velocity.dy.abs()) {
      if (velocity.dx < -500) {
        _triggerDeckSwipe(PhotoActionType.delete);
      } else if (velocity.dx > 500) {
        _triggerDeckSwipe(PhotoActionType.keep);
      }
    } else {
      if (velocity.dy < -500) {
        _triggerDeckSwipe(PhotoActionType.sortLater);
      }
    }
  }

  void _navigateToSortLater() async {
    final sortLater =
        _swipeLogicService.completedActions
            .where((a) => a.action == PhotoActionType.sortLater)
            .toList();
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.sortLater,
      arguments: _swipeLogicService.getActionsForType(
        widget.assets,
        'sort_later',
      ),
    );
    if (result is List<PhotoModel> && result.isNotEmpty) {
      setState(() {
        widget.assets.insertAll(_swipeLogicService.deckStartIndex, result);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Returned ${result.length} photo(s) to swipe queue'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<Widget> _buildPhotoWidget(PhotoModel photo) async {
    final isLocal = await photo.asset.isLocallyAvailable();
    if (!isLocal) {
      return Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'Media not downloaded\n(Open Photos app to download)',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      );
    }
    final thumb = await photo.asset.thumbnailDataWithSize(
      const ThumbnailSize(400, 400),
    );
    if (thumb != null && thumb.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.memory(thumb, fit: BoxFit.cover),
      );
    }
    // Try loading the original file as fallback
    final file = await photo.asset.file;
    if (file != null) {
      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.memory(bytes, fit: BoxFit.cover),
        );
      }
    }
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, color: Colors.white, size: 80),
    );
  }

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
      print('Gesture: _handleDeckPanEnd triggers _triggerDeckSwipe($type)');
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

  String? _getLiveLabel(Offset offset) {
    if (!_isDragging) return null;
    if (offset.dx > 20 && offset.dx.abs() > offset.dy.abs()) return 'Keep';
    if (offset.dx < -20 && offset.dx.abs() > offset.dy.abs()) return 'Delete';
    if (offset.dy < -20 && offset.dy.abs() > offset.dx.abs())
      return 'Sort later';
    return null;
  }

  Color? _getLiveLabelColor(Offset offset) {
    if (!_isDragging) return null;
    if (offset.dx > 20 && offset.dx.abs() > offset.dy.abs())
      return Colors.green;
    if (offset.dx < -20 && offset.dx.abs() > offset.dy.abs()) return Colors.red;
    if (offset.dy < -20 && offset.dy.abs() > offset.dx.abs())
      return Colors.purple;
    return null;
  }

  bool _shouldShowLiveLabel(Offset offset, bool isDragging) {
    if (!isDragging) return false;
    if (offset.dx.abs() > 20 && offset.dx.abs() > offset.dy.abs()) return true;
    if (offset.dy < -20 && offset.dy.abs() > offset.dx.abs()) return true;
    return false;
  }

  List<PhotoAction> get _deletedActions {
    return widget.assets
        .where(
          (a) => _swipeLogicService.completedActions.any(
            (action) =>
                action.photo.id == a.id &&
                action.action == PhotoActionType.delete,
          ),
        )
        .map((a) => PhotoAction(photo: a, action: PhotoActionType.delete))
        .toList();
  }

  List<PhotoAction> get _sortLaterActions {
    return widget.assets
        .where(
          (a) => _swipeLogicService.completedActions.any(
            (action) =>
                action.photo.id == a.id &&
                action.action == PhotoActionType.sortLater,
          ),
        )
        .map((a) => PhotoAction(photo: a, action: PhotoActionType.sortLater))
        .toList();
  }

  Future<bool> _isFavorite(PhotoModel photo) async {
    final isFav = await PhotoActionService.isSystemFavorite(photo.id);
    return isFav;
  }

  Future<void> _toggleFavorite(PhotoModel photo) async {
    final success = await PhotoActionService.toggleFavorite(photo);
    if (success) {
      final updated = await AssetEntity.fromId(photo.id);
      if (updated != null) {
        setState(() {
          final idx = widget.assets.indexWhere((p) => p.id == photo.id);
          if (idx != -1) {
            widget.assets[idx] = PhotoModel(
              id: photo.id,
              asset: updated,
              createdAt: photo.createdAt,
              isVideo: photo.isVideo,
              thumbnailData: photo.thumbnailData,
            );
          }
          final deckIdx = _swipeLogicService.deck.indexWhere(
            (p) => p.id == photo.id,
          );
          if (deckIdx != -1) {
            _swipeLogicService.deck[deckIdx] = PhotoModel(
              id: photo.id,
              asset: updated,
              createdAt: photo.createdAt,
              isVideo: photo.isVideo,
              thumbnailData: photo.thumbnailData,
            );
          }
        });
      } else {
        setState(() {});
      }
    } else {
      setState(() {});
      // Check permissions on iOS
      if (Platform.isIOS) {
        final status = await PhotoManager.requestPermissionExtend();
        if (!status.isAuth) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Photo access denied. Please allow full access in Settings.',
                ),
                action: SnackBarAction(
                  label: 'Settings',
                  onPressed: () {
                    PhotoManager.openSetting();
                  },
                ),
                duration: Duration(seconds: 4),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Could not update favorite. Try again or check permissions.',
                ),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Could not update favorite. Try again or check permissions.',
              ),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  Future<void> _showAlbumPicker(PhotoModel photo) async {
    final albums = await PhotoActionService.getAlbums();
    if (albums.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No albums found.')));
      return;
    }
    final selected = await showDialog<String>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).pop(),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.black.withOpacity(0.25)),
                ),
              ),
            ),
            Center(
              child: Dialog(
                insetPadding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: 400,
                  height: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Add to Album',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: FutureBuilder<List<_AlbumInfo>>(
                          future: _fetchAlbumInfos(albums),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final albumInfos = snap.data!;
                            return ListView.separated(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: albumInfos.length,
                              separatorBuilder:
                                  (_, __) => const SizedBox(height: 16),
                              itemBuilder: (context, i) {
                                final info = albumInfos[i];
                                return Row(
                                  children: [
                                    const SizedBox(width: 24),
                                    Expanded(
                                      child: Material(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant
                                            .withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap:
                                              () => Navigator.of(
                                                context,
                                              ).pop(info.name),
                                          child: SizedBox(
                                            height: 56,
                                            child: Row(
                                              children: [
                                                if (info.thumb != null)
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                16,
                                                              ),
                                                          topRight:
                                                              Radius.circular(
                                                                0,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                0,
                                                              ),
                                                        ),
                                                    child: Image.memory(
                                                      info.thumb!,
                                                      width: 56,
                                                      height: 56,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                else
                                                  Container(
                                                    width: 56,
                                                    height: 56,
                                                    decoration: const BoxDecoration(
                                                      color: Color(0xFFE0E0E0),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                            topRight:
                                                                Radius.circular(
                                                                  0,
                                                                ),
                                                            bottomRight:
                                                                Radius.circular(
                                                                  0,
                                                                ),
                                                          ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.photo,
                                                      size: 28,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 8,
                                                        ),
                                                    child: Text(
                                                      info.name,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${info.count}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                      Icons
                                                          .photo_library_outlined,
                                                      size: 18,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 12),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Material(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () async {
                                    final controller = TextEditingController();
                                    final albumName = await showDialog<String>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('New Album'),
                                          content: TextField(
                                            controller: controller,
                                            autofocus: true,
                                            decoration: const InputDecoration(
                                              hintText: 'Album name',
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () =>
                                                      Navigator.of(
                                                        context,
                                                      ).pop(),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                final name =
                                                    controller.text.trim();
                                                if (name.isNotEmpty) {
                                                  Navigator.of(
                                                    context,
                                                  ).pop(name);
                                                }
                                              },
                                              child: const Text('Create'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (albumName != null &&
                                        albumName.isNotEmpty) {
                                      final created =
                                          await PhotoActionService.createAlbum(
                                            albumName,
                                          );
                                      if (created) {
                                        // Opdater listen og tilføj billedet til det nye album
                                        final ok =
                                            await PhotoActionService.addToAlbum(
                                              photo,
                                              albumName,
                                            );
                                        if (!ok) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Failed to add to new album.',
                                              ),
                                            ),
                                          );
                                        } else {
                                          Navigator.of(context).pop(
                                            albumName,
                                          ); // luk popup og vælg albummet
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not create album.',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(Icons.add, size: 22),
                                          SizedBox(width: 8),
                                          Text(
                                            'Add',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Material(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => Navigator.of(context).pop(),
                                  child: SizedBox(
                                    height: 48,
                                    child: Center(
                                      child: Text(
                                        'Close',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    if (selected != null) {
      final ok = await PhotoActionService.addToAlbum(photo, selected);
      if (!ok) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to add to album.')));
      }
    }
  }

  // Helper: fetch album info (name, count, thumb)
  Future<List<_AlbumInfo>> _fetchAlbumInfos(List<String> albums) async {
    final List<_AlbumInfo> infos = [];
    for (final name in albums) {
      try {
        final paths = await PhotoManager.getAssetPathList(
          hasAll: false,
          filterOption: FilterOptionGroup(
            containsPathModified: false,
            orders: [
              const OrderOption(type: OrderOptionType.createDate, asc: false),
            ],
          ),
        );
        AssetPathEntity? match;
        try {
          match = paths.firstWhere((p) => p.name == name);
        } catch (_) {
          match = null;
        }
        if (match != null) {
          final count = match.assetCountAsync;
          final assets = await match.getAssetListRange(start: 0, end: 1);
          final thumb =
              assets.isNotEmpty
                  ? await assets.first.thumbnailDataWithSize(
                    const ThumbnailSize(80, 80),
                  )
                  : null;
          infos.add(_AlbumInfo(name: name, count: await count, thumb: thumb));
        } else {
          infos.add(_AlbumInfo(name: name, count: 0, thumb: null));
        }
      } catch (_) {
        infos.add(_AlbumInfo(name: name, count: 0, thumb: null));
      }
    }
    return infos;
  }

  // Placeholder for add to album
  bool _isInAlbum(PhotoModel photo) => false; // TODO: implement real check
  Future<void> _addToAlbum(PhotoModel photo) async {
    await _showAlbumPicker(photo);
  }

  Future<void> _sharePhoto(PhotoModel photo) async {
    final file = await photo.asset.file;
    if (file != null) {
      await Share.shareXFiles([XFile(file.path)]);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('BUILD: deck=${_swipeLogicService.deck.map((p) => p.id).toList()}');
    if (_swipeLogicService.deck.isNotEmpty) {
      final top = _swipeLogicService.topCard!;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('PicSor'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                '${_swipeLogicService.swipesLeft} swipes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.undo),
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
            icon: const Icon(Icons.delete_outline),
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
            icon: const Icon(Icons.watch_later_outlined),
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
              return const Center(child: Text('No media found.'));
            }
            if (_swipeLogicService.deck.isEmpty) {
              return const Center(child: Text('All images already swiped.'));
            }
            if (_timeCheatDetected) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _showTimeCheatDialog(),
              );
              return const Center(
                child: Text('Swiping is blocked due to time manipulation.'),
              );
            }
            // Live label logic
            final liveLabel = _getLiveLabel(_dragOffset);
            final liveLabelColor = _getLiveLabelColor(_dragOffset);
            final showLiveLabel = _shouldShowLiveLabel(
              _dragOffset,
              _isDragging,
            );
            Widget? floatingLabel;
            if (showLiveLabel && liveLabel != null && liveLabelColor != null) {
              Alignment alignment = Alignment.center;
              EdgeInsets padding = EdgeInsets.zero;
              switch (liveLabel) {
                case 'Keep':
                  alignment = Alignment.centerRight;
                  padding = const EdgeInsets.only(right: 24);
                  break;
                case 'Delete':
                  alignment = Alignment.centerLeft;
                  padding = const EdgeInsets.only(left: 24);
                  break;
                case 'Sort later':
                  alignment = Alignment.topCenter;
                  padding = const EdgeInsets.only(top: 32);
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
            return Stack(
              fit: StackFit.expand,
              children: [
                // a. Background layer
                Container(color: Theme.of(context).colorScheme.background),
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
                                              print('Gesture: onPanUpdate');
                                              _handleCardPanUpdate(details);
                                            }
                                            : null,
                                    onPanEnd:
                                        _swipeLogicService.canSwipe() &&
                                                !_isAnimatingOut
                                            ? (details) {
                                              print('Gesture: onPanEnd');
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
                      future: _isFavorite(_swipeLogicService.topCard!),
                      builder: (context, snapshot) {
                        final isFavorite = snapshot.data ?? false;
                        return SwipeActionButtonGroup(
                          photo: _swipeLogicService.topCard!,
                          isFavorite: isFavorite,
                          onFavorite:
                              () =>
                                  _toggleFavorite(_swipeLogicService.topCard!),
                          isInAlbum: _isInAlbum(_swipeLogicService.topCard!),
                          onAddToAlbum:
                              () => _addToAlbum(_swipeLogicService.topCard!),
                          onShare:
                              () => _sharePhoto(_swipeLogicService.topCard!),
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
