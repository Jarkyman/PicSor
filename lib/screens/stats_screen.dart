import 'package:flutter/material.dart';
import '../services/gallery_service.dart';
import '../models/photo_action.dart';
import '../models/photo_model.dart';
import '../core/theme.dart';

class StatsScreen extends StatefulWidget {
  final List<PhotoAction> actions;
  const StatsScreen({super.key, required this.actions});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  late Future<List<PhotoModel>> _futureAssets;
  int _totalPhotos = 0;
  int _totalVideos = 0;
  int _deletedCount = 0;
  int _keptCount = 0;
  int _swipedCount = 0;
  int _totalBytes = 0;
  int _deletedBytes = 0;
  int _keptBytes = 0;

  @override
  void initState() {
    super.initState();
    _futureAssets = GalleryService().fetchGalleryAssets();
  }

  Future<void> _calculateStats(List<PhotoModel> assets) async {
    _totalPhotos = assets.where((a) => !a.isVideo).length;
    _totalVideos = assets.where((a) => a.isVideo).length;
    _totalBytes = 0;
    _deletedCount = 0;
    _keptCount = 0;
    _swipedCount = 0;
    _deletedBytes = 0;
    _keptBytes = 0;
    final deletedIds =
        widget.actions
            .where((a) => a.action == PhotoActionType.delete)
            .map((a) => a.photo.id)
            .toSet();
    final keptIds =
        widget.actions
            .where((a) => a.action == PhotoActionType.keep)
            .map((a) => a.photo.id)
            .toSet();
    final swipedIds = widget.actions.map((a) => a.photo.id).toSet();
    for (final asset in assets) {
      final file = await asset.asset.file;
      final size = file != null ? await file.length() : 0;
      _totalBytes += size;
      if (deletedIds.contains(asset.id)) {
        _deletedCount++;
        _deletedBytes += size;
      }
      if (keptIds.contains(asset.id)) {
        _keptCount++;
        _keptBytes += size;
      }
      if (swipedIds.contains(asset.id)) {
        _swipedCount++;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stats', style: AppTextStyles.title(context))),
      body: FutureBuilder<List<PhotoModel>>(
        future: _futureAssets,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No media found.',
                style: AppTextStyles.body(context),
              ),
            );
          }
          return FutureBuilder<void>(
            future: _calculateStats(snapshot.data!),
            builder: (context, statsSnap) {
              if (statsSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final percentSwiped =
                  _totalPhotos + _totalVideos == 0
                      ? 0.0
                      : (_swipedCount / (_totalPhotos + _totalVideos)) * 100;
              return ListView(
                padding: EdgeInsets.all(AppSpacing.lg),
                children: [
                  _StatBlock(
                    icon: Icons.photo_library,
                    label: 'Total Photos',
                    value: '$_totalPhotos',
                  ),
                  _StatBlock(
                    icon: Icons.videocam,
                    label: 'Total Videos',
                    value: '$_totalVideos',
                  ),
                  _StatBlock(
                    icon: Icons.delete,
                    label: 'Photos Deleted',
                    value: '$_deletedCount',
                  ),
                  _StatBlock(
                    icon: Icons.sd_storage,
                    label: 'GB Freed',
                    value: (_deletedBytes / 1e9).toStringAsFixed(2),
                  ),
                  _StatBlock(
                    icon: Icons.percent,
                    label: 'Gallery Swiped',
                    value: '${percentSwiped.toStringAsFixed(1)}%',
                  ),
                  _StatBlock(
                    icon: Icons.check_circle,
                    label: 'GB Kept',
                    value: (_keptBytes / 1e9).toStringAsFixed(2),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatBlock({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: Scale.of(context, 32)),
          SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.label(context))),
          Text(value, style: AppTextStyles.headline(context)),
        ],
      ),
    );
  }
}
