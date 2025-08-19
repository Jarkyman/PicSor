import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/theme.dart';
import '../models/photo_model.dart';
import '../services/swipe_logic_service.dart';
import '../services/photo_filter_service.dart';
import '../services/album_service.dart';
import '../widgets/photo_selection/random_section.dart';
import '../widgets/photo_selection/year_section.dart';
import '../widgets/photo_selection/photo_types_section.dart';
import '../widgets/photo_selection/utilities_section.dart';
import '../widgets/photo_selection/albums_section.dart';
import 'swipe_screen.dart';

class PhotoSelectionScreen extends StatefulWidget {
  final SwipeLogicService swipeLogicService;
  final List<PhotoModel> assets;

  const PhotoSelectionScreen({
    super.key,
    required this.swipeLogicService,
    required this.assets,
  });

  @override
  State<PhotoSelectionScreen> createState() => _PhotoSelectionScreenState();
}

class _PhotoSelectionScreenState extends State<PhotoSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  List<int> _years = [];
  List<AssetPathEntity> _albums = [];
  bool _isLoading = true;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _initializeData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Preload shared album info in background for faster access
    _preloadSharedAlbumInfoInBackground();

    await _loadYears();
    await _loadAlbums();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _fadeController.forward();
      _slideController.forward();
    }
  }

  Future<void> _loadYears() async {
    _years = PhotoFilterService.getAvailableYears(widget.assets);
  }

  Future<void> _preloadSharedAlbumInfoInBackground() async {
    // Preload shared album info in background
    try {
      await AlbumService.getSharedAlbumInfo();
    } catch (e) {
      // Ignore errors in background preload
    }
  }

  Future<void> _loadAlbums() async {
    try {
      final paths = await PhotoManager.getAssetPathList();

      // Filter out system albums and date-based albums
      _albums =
          paths.where((path) {
            final name = path.name.toLowerCase();

            // Filter out system albums
            final isSystemAlbum = [
              'recent',
              'favorites',
              'favorite',
              'all photos',
              'camera roll',
              'screenshots',
              'live photos',
              'portrait',
              'panoramas',
              'slo-mo',
              'time-lapse',
              'burst',
              'long exposure',
              'cinematic',
              'photographic styles',
              'depth effect',
              'night mode',
              'macro',
              'wide angle',
              'telephoto',
              'ultra wide',
              'portrait mode',
              'live',
              'portraits',
              'selfies',
              'videos',
              'photos',
              'downloads',
              'imports',
              'shared albums',
              'my photo stream',
              'icloud shared photos',
              'icloud photos',
              'google photos',
              'onedrive',
              'dropbox',
              'sync',
              'backup',
              'trash',
              'deleted',
              'hidden',
              'private',
              'locked',
              'secure',
              'system',
              'default',
              'auto',
              'smart',
              'dynamic',
              'recents',
              'latest',
              'new',
              'today',
              'yesterday',
              'this week',
              'this month',
              'this year',
              'last week',
              'last month',
              'last year',
            ].contains(name);

            // Filter out very generic names
            final isGenericName = [
              'album',
              'photos',
              'pictures',
              'images',
              'media',
              'gallery',
              'camera',
              'screenshots',
              'downloads',
              'documents',
              'files',
            ].contains(name);

            // Filter out date-based albums (YYYY-MM-DD, YYYY/MM/DD, etc.)
            final isDateBased = _isDateBasedAlbum(path.name);

            // Only include meaningful user-created albums
            return !isSystemAlbum && !isGenericName && !isDateBased;
          }).toList();

      // Sort albums by name
      _albums.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      debugPrint('Failed to load albums: $e');
      _albums = [];
    }
  }

  /// Check if album name is date-based (YYYY-MM-DD, YYYY/MM/DD, etc.)
  bool _isDateBasedAlbum(String name) {
    // Common date patterns
    final datePatterns = [
      RegExp(r'^\d{4}-\d{2}-\d{2}$'), // YYYY-MM-DD
      RegExp(r'^\d{4}/\d{2}/\d{2}$'), // YYYY/MM/DD
      RegExp(r'^\d{2}-\d{2}-\d{4}$'), // MM-DD-YYYY
      RegExp(r'^\d{2}/\d{2}/\d{4}$'), // MM/DD/YYYY
      RegExp(r'^\d{4}\.\d{2}\.\d{2}$'), // YYYY.MM.DD
      RegExp(r'^\d{2}\.\d{2}\.\d{4}$'), // MM.DD.YYYY
      RegExp(r'^\d{8}$'), // YYYYMMDD
      RegExp(r'^\d{6}$'), // YYMMDD
      // iOS Photos app date albums with count: "01/02/2013 (1)"
      RegExp(r'^\d{2}/\d{2}/\d{4}\s*\(\d+\)$'),
      RegExp(r'^\d{2}-\d{2}-\d{4}\s*\(\d+\)$'),
      RegExp(r'^\d{4}-\d{2}-\d{2}\s*\(\d+\)$'),
      RegExp(r'^\d{4}/\d{2}/\d{2}\s*\(\d+\)$'),
    ];

    return datePatterns.any((pattern) => pattern.hasMatch(name));
  }

  void _navigateToSwipe(List<PhotoModel> filteredAssets) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => SwipeScreen(
              swipeLogicService: widget.swipeLogicService,
              assets: filteredAssets,
              onStateChanged: () => setState(() {}),
              onUndo: () => setState(() {}),
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  List<PhotoModel> _getAssetsByYear(int year) {
    return PhotoFilterService.filterByYear(widget.assets, year);
  }

  List<PhotoModel> _getRandomAssets() {
    return PhotoFilterService.getRandomAssets(widget.assets);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: EdgeInsets.all(AppSpacing.lg),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    RandomSection(
                      onTap: () => _navigateToSwipe(_getRandomAssets()),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    YearSection(
                      years: _years,
                      onYearSelected:
                          (year) => _navigateToSwipe(_getAssetsByYear(year)),
                      getAssetCount: (year) => _getAssetsByYear(year).length,
                    ),
                    SizedBox(height: AppSpacing.xl),
                    PhotoTypesSection(
                      onTypeSelected:
                          (filter) =>
                              _navigateToSwipe(_getAssetsByType(filter)),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    UtilitiesSection(
                      onUtilitySelected:
                          (filter) =>
                              _navigateToSwipe(_getAssetsByType(filter)),
                    ),
                    SizedBox(height: AppSpacing.xl),
                    AlbumsSection(
                      albums: _albums,
                      onAlbumSelected: (album) async {
                        final albumAssets = await _getAssetsByAlbum(album);
                        if (mounted) {
                          _navigateToSwipe(albumAssets);
                        }
                      },
                    ),
                    SizedBox(height: AppSpacing.xl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Choose Photos',
          style: AppTextStyles.title(context).copyWith(
            fontWeight: FontWeight.w900,
            fontSize: Scale.of(context, 24),
            letterSpacing: -0.5,
          ),
        ),
        titlePadding: EdgeInsets.only(
          left: AppSpacing.lg,
          bottom: AppSpacing.md,
        ),
        background: Container(color: Theme.of(context).colorScheme.background),
      ),
    );
  }

  List<PhotoModel> _getAssetsByType(String filter) {
    return PhotoFilterService.filterByType(widget.assets, filter);
  }

  Future<List<PhotoModel>> _getAssetsByAlbum(AssetPathEntity album) async {
    return await PhotoFilterService.filterByAlbum(widget.assets, album);
  }
}
