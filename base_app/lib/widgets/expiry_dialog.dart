import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../themes/app_theme.dart';

class ExpiryDialog extends StatelessWidget {
  const ExpiryDialog({super.key});

  Color get _primary => AppConfig.useCustomColors
      ? AppConfig.customPrimaryColor
      : AppTheme.getPalette(AppConfig.themeTemplate).primary;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !AppConfig.expiryBlockApp,
      child: AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.red.shade900,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Column(
                children: [
                  Text('⏰', style: TextStyle(fontSize: 52)),
                  SizedBox(height: 8),
                  Text(
                    'App Expired',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    AppConfig.expiryDialogMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.grey.shade700, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  if (AppConfig.expiryContactUrl.isNotEmpty)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final uri =
                              Uri.parse(AppConfig.expiryContactUrl);
                          if (await canLaunchUrl(uri)) {
                            launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          padding:
                              const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(AppConfig.expiryContactLabel,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (AppConfig.expiryBlockApp) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          SystemNavigator.pop(),
                      child: Text('Close App',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
