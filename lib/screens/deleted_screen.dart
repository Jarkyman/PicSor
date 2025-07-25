import 'package:flutter/material.dart';
import '../models/photo_action.dart';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../core/theme.dart';

class DeletedScreen extends StatefulWidget {
  final List<PhotoAction> actions;
  const DeletedScreen({super.key, required this.actions});

  @override
  State<DeletedScreen> createState() => _DeletedScreenState();
}

class _DeletedScreenState extends State<DeletedScreen> {
  late List<PhotoAction> _deletedActions;
  late Set<String> _selectedIds;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _deletedActions =
        widget.actions
            .where((a) => a.action == PhotoActionType.delete)
            .toList();
    _selectedIds = _deletedActions.map((a) => a.photo.id).toSet();
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

  Future<void> _deleteSelected() async {
    setState(() => _deleting = true);
    final toDelete =
        _deletedActions
            .where((a) => _selectedIds.contains(a.photo.id))
            .toList();
    int deletedCount = 0;
    if (toDelete.isNotEmpty) {
      final ids = toDelete.map((a) => a.photo.id).toList();
      final result = await PhotoManager.editor.deleteWithIds(ids);
      deletedCount = result.length;
    }
    setState(() {
      _deletedActions.removeWhere((a) => _selectedIds.contains(a.photo.id));
      _selectedIds = _deletedActions.map((a) => a.photo.id).toSet();
      _deleting = false;
    });
    if (deletedCount > 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deleted $deletedCount photo(s)',
              style: AppTextStyles.body(context),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
    if (_deletedActions.isEmpty && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_deletedActions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Deleted', style: AppTextStyles.title(context)),
        ),
        body: Center(
          child: Text(
            'No photos to delete',
            style: AppTextStyles.body(context),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Deleted', style: AppTextStyles.title(context)),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(AppSpacing.sm),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: _deletedActions.length,
        itemBuilder: (context, index) {
          final action = _deletedActions[index];
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
                          color: AppColors.secondary,
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
          _selectedIds.isNotEmpty && !_deleting
              ? FloatingActionButton.extended(
                onPressed: _deleteSelected,
                icon: Icon(Icons.delete, size: Scale.of(context, 24)),
                label: Text('Delete Selected'),
              )
              : null,
    );
  }
}
