import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onAccept;
  const PrivacyPolicyScreen({Key? key, required this.onAccept})
    : super(key: key);

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
                const SizedBox(height: 48), // Ekstra padding i toppen
                // Privacy ikon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.privacy_tip_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 40), // Mere luft ned til teksten
                Text(
                  'Privacy Policy',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      '''PicSor is designed for privacy.
 
- All sorting and deletion happens 100% offline on your device.
- We never upload, analyze, or share your photos or videos.
- No account or login is required.
- We only request permissions needed to access your gallery and send optional notifications.
- No personal data is collected or tracked.
 
---
 
1. Data Collection
PicSor does not collect, store, or transmit any personal data. All actions, including sorting, deleting, and favoriting photos, are performed locally on your device. We do not access, read, or transmit your photo library beyond what is necessary to display and manage your gallery within the app.
 
2. Permissions
PicSor requests access to your photo library solely to display and manage your photos and videos. Notification permissions are optional and only used to remind you about available swipes or gallery clean-up suggestions. You can revoke these permissions at any time in your device settings.
 
3. Local Storage
All swipe actions, preferences, and app settings are stored locally on your device using secure storage mechanisms. No data is sent to external servers or third parties. If you uninstall the app, all locally stored data will be deleted.
 
4. Third-Party Services
PicSor uses Google AdMob to display non-intrusive ads. AdMob may collect anonymized usage data as described in their own privacy policy. PicSor does not share any personal or photo data with AdMob or any other third party. You can read more about AdMob’s privacy practices at https://policies.google.com/privacy.
 
5. Children’s Privacy
PicSor is not intended for use by children under the age of 13. We do not knowingly collect or solicit any personal information from children. If you believe a child has provided us with personal information, please contact us so we can remove it.
 
6. Changes to This Policy
We may update this privacy policy from time to time. Any changes will be posted within the app. Your continued use of PicSor after changes have been made constitutes your acceptance of the new policy.
 
7. Contact
If you have any questions or concerns about this privacy policy or your data, please contact us at support@picsor.app.
 
---
 
By using PicSor, you agree to this privacy policy and the terms described above. Thank you for trusting us with your photo organization!''',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'I accept',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
