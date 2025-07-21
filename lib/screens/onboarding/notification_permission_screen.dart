import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/scheduler.dart';

class NotificationPermissionScreen extends StatefulWidget {
  final VoidCallback onNext;
  const NotificationPermissionScreen({Key? key, required this.onNext})
    : super(key: key);

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
      if (req.isGranted) widget.onNext();
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
    if (status.isGranted) widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Notifikation-ikon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Enable Notifications',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'PicSor can remind you when you have new swipes available, or when it’s time to clean up your gallery.\n\nNotifications are optional and you can always change this later in settings.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _granted
                    ? Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: widget.onNext,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Next',
                              style: TextStyle(fontSize: 18),
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
                                // Try again
                                await _requestPermission();
                              } else {
                                // Open settings
                                await openAppSettings();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: FutureBuilder<PermissionStatus>(
                              future: Permission.notification.status,
                              builder: (context, snap) {
                                if (snap.hasData && snap.data!.isDenied) {
                                  return const Text(
                                    'Try again',
                                    style: TextStyle(fontSize: 18),
                                  );
                                } else {
                                  return const Text(
                                    'Go to settings',
                                    style: TextStyle(fontSize: 18),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onNext,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Skip',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
