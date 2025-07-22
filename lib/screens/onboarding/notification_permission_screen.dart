import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';
import '../../core/theme.dart';

class NotificationPermissionScreen extends StatefulWidget {
  final VoidCallback onNext;
  const NotificationPermissionScreen({super.key, required this.onNext});

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen>
    with WidgetsBindingObserver {
  bool _requested = false;
  bool _granted = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
    }
  }

  Future<void> _refreshPermissionStatus() async {
    final status = await Permission.notification.status;
    setState(() {
      _granted = status.isGranted;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestPermissionIfNeeded();
  }

  Future<void> _requestPermissionIfNeeded() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      final req = await Permission.notification.request();
      setState(() {
        _requested = true;
        _granted = req.isGranted;
      });
    } else {
      setState(() {
        _requested = true;
        _granted = true;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() {
      _requested = true;
      _granted = status.isGranted;
    });
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
                      Icons.notifications_active_outlined,
                      size: Scale.of(context, 56),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Enable Notifications',
                  style: AppTextStyles.headline(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'PicSor can remind you when you have new swipes available, or when it’s time to clean up your gallery.\n\nNotifications are optional and you can always change this later in settings.',
                  style: AppTextStyles.body(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xl + AppSpacing.md),
                _granted
                    ? Row(
                      children: [
                        Expanded(
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
                            child: Text(
                              'Next',
                              style: AppTextStyles.button(context),
                            ),
                          ),
                        ),
                      ],
                    )
                    : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final status =
                                  await Permission.notification.status;
                              if (status.isDenied) {
                                await _requestPermission();
                              } else {
                                await openAppSettings();
                              }
                            },
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
                            child: FutureBuilder<PermissionStatus>(
                              future: Permission.notification.status,
                              builder: (context, snap) {
                                if (snap.hasData && snap.data!.isDenied) {
                                  return Text(
                                    'Try again',
                                    style: AppTextStyles.button(context),
                                  );
                                } else {
                                  return Text(
                                    'Go to settings',
                                    style: AppTextStyles.button(context),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onNext,
                            style: OutlinedButton.styleFrom(
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
                              'Skip',
                              style: AppTextStyles.button(context),
                            ),
                          ),
                        ),
                      ],
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
