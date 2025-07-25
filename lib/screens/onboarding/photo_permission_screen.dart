import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme.dart';
import '../../widgets/onboarding/onboarding_icon.dart';
import '../../widgets/onboarding/onboarding_title.dart';
import '../../widgets/onboarding/onboarding_body.dart';
import '../../widgets/onboarding/onboarding_button_row.dart';

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
                        OnboardingIcon(icon: Icons.camera_alt_outlined),
                        SizedBox(height: AppSpacing.xl),
                        OnboardingTitle(text: 'Photo Access Required'),
                        SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: OnboardingBody(
                              text:
                                  'PicSor works 100% offline and never uploads your photos.\n\nWe only use your photos and videos to help you sort and organize your gallery on your device.',
                            ),
                          ),
                        ),
                        if (!_granted && !_requested)
                          Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: AppSpacing.lg),
                              Text(
                                'Checking photo access...',
                                style: AppTextStyles.body(context),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        else if (!_granted && _requested)
                          Column(
                            children: [
                              SizedBox(height: AppSpacing.lg),
                              OnboardingButtonRow(
                                buttons: [
                                  ElevatedButton(
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
                                ],
                              ),
                              SizedBox(height: AppSpacing.lg),
                            ],
                          )
                        else if (_granted)
                          Column(
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
