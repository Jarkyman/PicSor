import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  final VoidCallback onAccept;
  const PrivacyPolicyScreen({super.key, required this.onAccept});

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
                      Icons.privacy_tip_outlined,
                      size: Scale.of(context, 56),
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Privacy Policy',
                  style: AppTextStyles.headline(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.lg),
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
                SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAccept,
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
                      'I accept',
                      style: AppTextStyles.button(context),
                    ),
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
