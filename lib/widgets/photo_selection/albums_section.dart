import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/theme.dart';
import '../../services/album_service.dart';
import 'liquid_glass_card.dart';
import 'selection_section.dart';

class AlbumsSection extends StatefulWidget {
  final List<AssetPathEntity> albums;
  final Function(AssetPathEntity) onAlbumSelected;

  const AlbumsSection({
    super.key,
    required this.albums,
    required this.onAlbumSelected,
  });

  @override
  State<AlbumsSection> createState() => _AlbumsSectionState();
}

class _AlbumsSectionState extends State<AlbumsSection> {
  static const int _itemsPerPage = 8; // Load 8 albums at a time
  int _currentIndex = 0;
  bool _isLoadingMore = false;
  Map<String, bool> _sharedAlbums = {};

  @override
  void initState() {
    super.initState();
    // Load initial batch and shared album info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMoreAlbums();
      _loadSharedAlbumInfo();
    });
  }

  /// Preload shared album info for faster access later
  static Future<void> preloadSharedAlbumInfo() async {
    await AlbumService.getSharedAlbumInfo();
  }

  Future<void> _loadSharedAlbumInfo() async {
    try {
      final sharedAlbums = await AlbumService.getSharedAlbumInfo();
      setState(() {
        _sharedAlbums = {
          for (var album in sharedAlbums) album.title: album.isShared,
        };
      });
    } catch (e) {
      // Handle error silently
    }
  }

  void _loadMoreAlbums() {
    if (_currentIndex < widget.albums.length && !_isLoadingMore) {
      setState(() {
        _isLoadingMore = true;
      });

      // Simulate loading delay for better UX
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _currentIndex = (_currentIndex + _itemsPerPage).clamp(
              0,
              widget.albums.length,
            );
            _isLoadingMore = false;
          });
        }
      });
    }
  }

  List<AssetPathEntity> get _visibleAlbums {
    return widget.albums.take(_currentIndex).toList();
  }

  /// Get appropriate icon for album based on name
  IconData _getAlbumIcon(String albumName) {
    final name = albumName.toLowerCase();

    // Check for travel/vacation albums
    if (name.contains('travel') ||
        name.contains('vacation') ||
        name.contains('trip') ||
        name.contains('holiday') ||
        name.contains('journey')) {
      return Icons.flight_rounded;
    }

    // Check for event albums
    if (name.contains('wedding') ||
        name.contains('birthday') ||
        name.contains('party') ||
        name.contains('celebration') ||
        name.contains('event')) {
      return Icons.celebration_rounded;
    }

    // Check for work/business albums
    if (name.contains('work') ||
        name.contains('business') ||
        name.contains('office') ||
        name.contains('meeting') ||
        name.contains('project')) {
      return Icons.work_rounded;
    }

    // Check for family albums
    if (name.contains('family') ||
        name.contains('kids') ||
        name.contains('children') ||
        name.contains('baby') ||
        name.contains('son') ||
        name.contains('daughter')) {
      return Icons.family_restroom_rounded;
    }

    // Check for pet albums
    if (name.contains('pet') ||
        name.contains('dog') ||
        name.contains('cat') ||
        name.contains('animal')) {
      return Icons.pets_rounded;
    }

    // Default album icon
    return Icons.photo_library_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SelectionSection(
      title: 'Albums',
      child: Column(
        children: [
          ..._visibleAlbums.map((album) {
            return Padding(
              padding: EdgeInsets.only(bottom: AppSpacing.sm),
              child: LiquidGlassCard(
                onTap: () => widget.onAlbumSelected(album),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _getAlbumIcon(album.name),
                        color: Theme.of(context).colorScheme.primary,
                        size: Scale.of(context, 26),
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.name,
                            style: AppTextStyles.body(context).copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: Scale.of(context, 16),
                              letterSpacing: -0.1,
                            ),
                          ),


                          FutureBuilder<int>(
                            future: album.assetCountAsync,
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              return Text(
                                '$count photos',
                                style: AppTextStyles.body(context).copyWith(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.6),
                                  fontSize: Scale.of(context, 13),
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        // Show shared album indicator if applicable
                        if (_sharedAlbums[album.name] == true)
                          Padding(
                            padding: EdgeInsets.only(right: AppSpacing.sm),
                            child: Icon(
                              Icons.people_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: Scale.of(context, 16),
                            ),
                          ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.4),
                          size: Scale.of(context, 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          // Show load more button if there are more albums
          if (_currentIndex < widget.albums.length)
            Padding(
              padding: EdgeInsets.only(top: AppSpacing.md),
              child: LiquidGlassCard(
                onTap: _isLoadingMore ? () {} : _loadMoreAlbums,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isLoadingMore)
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      else
                        Icon(
                          Icons.expand_more_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: Scale.of(context, 20),
                        ),
                      SizedBox(width: AppSpacing.sm),
                      Text(
                        _isLoadingMore
                            ? 'Loading...'
                            : 'Load ${(_currentIndex + _itemsPerPage).clamp(0, widget.albums.length) - _currentIndex} more albums',
                        style: AppTextStyles.body(context).copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: Scale.of(context, 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
