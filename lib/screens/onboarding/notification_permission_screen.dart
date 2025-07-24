import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../widgets/onboarding/onboarding_icon.dart';
import '../../widgets/onboarding/onboarding_title.dart';
import '../../widgets/onboarding/onboarding_body.dart';
import '../../widgets/onboarding/onboarding_button_row.dart';

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
        _granted = req.isGranted;
      });
    } else {
      setState(() {
        _granted = true;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.notification.request();
    setState(() {
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
            child: LayoutBuilder(
              builder:
                  (context, constraints) => ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: AppSpacing.xl + AppSpacing.lg),
                        OnboardingIcon(
                          icon: Icons.notifications_active_outlined,
                        ),
                        SizedBox(height: AppSpacing.xl),
                        OnboardingTitle(text: 'Enable Notifications'),
                        SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: OnboardingBody(
                              text:
                                  'PicSor can remind you when you have new swipes available, or when it\u2019s time to clean up your gallery.\n\nNotifications are optional and you can always change this later in settings.',
                            ),
                          ),
                        ),
                        _granted
                            ? Column(
                              children: [
                                SizedBox(height: AppSpacing.lg),
                                OnboardingButtonRow(
                                  buttons: [
                                    ElevatedButton(
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
                                  ],
                                ),
                                SizedBox(height: AppSpacing.lg),
                              ],
                            )
                            : Column(
                              children: [
                                SizedBox(height: AppSpacing.lg),
                                OnboardingButtonRow(
                                  buttons: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        final status =
                                            await Permission
                                                .notification
                                                .status;
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
                                          if (snap.hasData &&
                                              snap.data!.isDenied) {
                                            return Text(
                                              'Try again',
                                              style: AppTextStyles.button(
                                                context,
                                              ),
                                            );
                                          } else {
                                            return Text(
                                              'Go to settings',
                                              style: AppTextStyles.button(
                                                context,
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    OutlinedButton(
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
                                  ],
                                ),
                                SizedBox(height: AppSpacing.lg),
                              ],
                            ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
