import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../models/photo_model.dart';
import '../../models/album_info.dart';
import '../../core/theme.dart';
import '../../services/photo_action_service.dart';

Future<String?> showAlbumPickerDialog(
  BuildContext context,
  PhotoModel photo,
) async {
  final albums = await PhotoActionService.getAlbums();
  if (albums.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No albums found.', style: AppTextStyles.body(context)),
      ),
    );
    return null;
  }
  return showDialog<String>(
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
                child: Container(color: Colors.black.withValues(alpha: 0.25)),
              ),
            ),
          ),
          Center(child: AlbumPickerDialog(albums: albums)),
        ],
      );
    },
  );
}

class AlbumPickerDialog extends StatelessWidget {
  final List<String> albums;
  const AlbumPickerDialog({super.key, required this.albums});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        width: Scale.of(context, 400),
        height: Scale.of(context, 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text('Add to Album', style: AppTextStyles.title(context)),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<AlbumInfo>>(
                future: _fetchAlbumInfos(albums),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final albumInfos = snap.data!;
                  return ListView.separated(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    itemCount: albumInfos.length,
                    separatorBuilder:
                        (context, index) => SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, i) {
                      final info = albumInfos[i];
                      return Row(
                        children: [
                          SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Material(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.md,
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.md,
                                ),
                                onTap:
                                    () => Navigator.of(context).pop(info.name),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: AppSpacing.md,
                                    horizontal: AppSpacing.lg,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.photo,
                                        size: Scale.of(context, 16),
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: AppSpacing.sm,
                                          ),
                                          child: Text(
                                            info.name,
                                            style: AppTextStyles.label(
                                              context,
                                            ).copyWith(
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${info.count}',
                                            style: AppTextStyles.body(
                                              context,
                                            ).copyWith(
                                              fontSize: Scale.of(context, 14),
                                              color:
                                                  Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                            ),
                                          ),
                                          SizedBox(width: AppSpacing.xs),
                                          if (info.thumb != null)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    AppSpacing.xs,
                                                  ),
                                              child: Image.memory(
                                                info.thumb!,
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.lg),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppSpacing.md,
                horizontal: AppSpacing.md,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Material(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        onTap: () async {
                          final albumName = await showDialog<String>(
                            context: context,
                            builder: (context) => NewAlbumDialog(),
                          );
                          if (albumName != null && albumName.isNotEmpty) {
                            Navigator.of(
                              context,
                            ).pop('CREATE_ALBUM:$albumName');
                          }
                        },
                        child: SizedBox(
                          height: Scale.of(context, 48),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: Scale.of(context, 22),
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                                SizedBox(width: AppSpacing.sm),
                                Text(
                                  'Add',
                                  style: AppTextStyles.button(context).copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Material(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppSpacing.md),
                        onTap: () => Navigator.of(context).pop(),
                        child: SizedBox(
                          height: Scale.of(context, 48),
                          child: Center(
                            child: Text(
                              'Close',
                              style: AppTextStyles.button(context).copyWith(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NewAlbumDialog extends StatefulWidget {
  const NewAlbumDialog({super.key});

  @override
  State<NewAlbumDialog> createState() => _NewAlbumDialogState();
}

class _NewAlbumDialogState extends State<NewAlbumDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('New Album', style: AppTextStyles.title(context)),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Album name',
          hintStyle: AppTextStyles.body(context),
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (value) {
          final name = value.trim();
          if (name.isNotEmpty) {
            Navigator.of(context).pop(name);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: AppTextStyles.button(context)),
        ),
        ElevatedButton(
          onPressed:
              _controller.text.trim().isEmpty
                  ? null
                  : () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text('Create', style: AppTextStyles.button(context)),
        ),
      ],
    );
  }
}

Future<List<AlbumInfo>> _fetchAlbumInfos(List<String> albums) async {
  final List<AlbumInfo> infos = [];
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
        infos.add(AlbumInfo(name: name, count: await count, thumb: thumb));
      } else {
        infos.add(AlbumInfo(name: name, count: 0, thumb: null));
      }
    } catch (_) {
      infos.add(AlbumInfo(name: name, count: 0, thumb: null));
    }
  }
  return infos;
}
