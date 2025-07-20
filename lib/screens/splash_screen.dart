import 'package:flutter/material.dart';
import '../services/gallery_service.dart';
import '../services/swipe_logic_service.dart';
import '../screens/swipe_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late GalleryService _galleryService;
  late SwipeLogicService _swipeLogicService;

  @override
  void initState() {
    super.initState();
    _galleryService = GalleryService();
    _swipeLogicService = SwipeLogicService();
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      await _swipeLogicService.loadState();
      final photos = await _galleryService.fetchGalleryAssets();
      _swipeLogicService.initializeDeck(photos);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => SwipeScreen(
                  swipeLogicService: _swipeLogicService,
                  assets: photos,
                ),
          ),
        );
      }
    } catch (e) {
      // Optionally show error UI
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Error'),
                content: Text('Failed to load app data: $e'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo or icon
            Icon(
              Icons.photo_library_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Loading your gallery...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
