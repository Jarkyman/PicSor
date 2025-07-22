import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';

class PhotoPermissionScreen extends StatefulWidget {
  final VoidCallback onNext;
  const PhotoPermissionScreen({super.key, required this.onNext});

  @override
  State<PhotoPermissionScreen> createState() => _PhotoPermissionScreenState();
}

class _PhotoPermissionScreenState extends State<PhotoPermissionScreen> {
  bool _requested = false;
  bool _granted = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.photos.request();
    setState(() {
      _requested = true;
      _granted = status.isGranted;
    });
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: AppSpacing.xl + AppSpacing.lg),
                Container(
                  width: Scale.of(context, 100),
                  height: Scale.of(context, 100),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.lg),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: Scale.of(context, 56),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.7),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Photo Access Required',
                  style: AppTextStyles.headline(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'PicSor works 100% offline and never uploads your photos.\n\nWe only use your photos and videos to help you sort and organize your gallery on your device.',
                  style: AppTextStyles.body(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl + AppSpacing.md),
                if (!_granted && _requested)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openSettings,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: Scale.of(context, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius,
                          ),
                        ),
                      ),
                      child: Text(
                        'Go to settings',
                        style: AppTextStyles.button(context),
                      ),
                    ),
                  )
                else if (_granted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: Scale.of(context, 16),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.buttonRadius,
                          ),
                        ),
                      ),
                      child: Text('Next', style: AppTextStyles.button(context)),
                    ),
                  ),
                SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
