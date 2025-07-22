import 'package:flutter/material.dart';
import '../models/photo_action.dart';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../models/photo_model.dart';
import '../core/theme.dart';

class SortLaterScreen extends StatefulWidget {
  final List<PhotoAction> actions;
  const SortLaterScreen({super.key, required this.actions});

  @override
  State<SortLaterScreen> createState() => _SortLaterScreenState();
}

class _SortLaterScreenState extends State<SortLaterScreen> {
  late List<PhotoAction> _sortLaterActions;
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _sortLaterActions =
        widget.actions
            .where((a) => a.action == PhotoActionType.sortLater)
            .toList();
    _selectedIds = _sortLaterActions.map((a) => a.photo.id).toSet();
  }

  void _toggleSelect(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _returnSelected() {
    final selectedPhotos =
        _sortLaterActions
            .where((a) => _selectedIds.contains(a.photo.id))
            .map((a) => a.photo)
            .toList();
    if (selectedPhotos.isNotEmpty) {
      Navigator.pop(context, selectedPhotos);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Returned to swipe queue',
            style: AppTextStyles.body(context),
          ),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_sortLaterActions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Sort Later', style: AppTextStyles.title(context)),
        ),
        body: Center(
          child: Text('Nothing here yet', style: AppTextStyles.body(context)),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Sort Later', style: AppTextStyles.title(context)),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(AppSpacing.sm),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: _sortLaterActions.length,
        itemBuilder: (context, index) {
          final action = _sortLaterActions[index];
          final id = action.photo.id;
          return FutureBuilder<Uint8List?>(
            future: action.photo.asset.thumbnailDataWithSize(
              const ThumbnailSize(200, 200),
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final selected = _selectedIds.contains(id);
              return GestureDetector(
                onTap: () => _toggleSelect(id),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.memory(snapshot.data!, fit: BoxFit.cover),
                    if (selected)
                      Container(
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: Scale.of(context, 32),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          _selectedIds.isNotEmpty
              ? FloatingActionButton.extended(
                onPressed: _returnSelected,
                icon: Icon(Icons.keyboard_return, size: Scale.of(context, 24)),
                label: Text('Return Selected to Swipe Queue'),
              )
              : null,
    );
  }
}
