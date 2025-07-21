import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoPermissionScreen extends StatefulWidget {
  final VoidCallback onNext;
  const PhotoPermissionScreen({Key? key, required this.onNext})
    : super(key: key);

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
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Kamera/billede placeholder
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Photo Access Required',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'PicSor works 100% offline and never uploads your photos.\n\nWe only use your photos and videos to help you sort and organize your gallery on your device.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                if (!_granted && _requested)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _openSettings,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Go to settings',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )
                else if (_granted)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onNext,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Next', style: TextStyle(fontSize: 18)),
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
