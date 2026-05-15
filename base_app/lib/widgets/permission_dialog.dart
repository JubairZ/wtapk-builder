import 'package:flutter/material.dart';
  import '../config/app_config.dart';
  import '../themes/app_theme.dart';
  import '../services/permission_service.dart';

  // ─────────────────────────────────────────────────────────────────────────────
  //  Permission Dialog — rationale before single permission request
  //  Powered by Jubair Sensei | jubair.bro.bd
  // ─────────────────────────────────────────────────────────────────────────────

  class PermissionRationaleDialog extends StatelessWidget {
    final AppPermission permission;
    final VoidCallback onAllow;
    final VoidCallback onSkip;

    const PermissionRationaleDialog({
      super.key, required this.permission, required this.onAllow, required this.onSkip,
    });

    Color get _primary => AppConfig.useCustomColors
        ? AppConfig.customPrimaryColor : AppTheme.getPalette(AppConfig.themeTemplate).primary;
    Color get _bg => AppConfig.useCustomColors
        ? AppConfig.customSurfaceColor : AppTheme.getPalette(AppConfig.themeTemplate).surface;
    Color get _text => AppConfig.useCustomColors
        ? AppConfig.customTextPrimary : AppTheme.getPalette(AppConfig.themeTemplate).textPrimary;

    @override
    Widget build(BuildContext context) {
      return Dialog(
        backgroundColor: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(PermissionService.getPermissionIcon(permission),
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              Text('${PermissionService.getPermissionName(permission)} Permission',
                  style: TextStyle(color: _text, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(PermissionService.getRationale(permission),
                  style: TextStyle(color: _text.withOpacity(0.75), fontSize: 14, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              Row(children: [
                Expanded(child: OutlinedButton(
                  onPressed: onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _text.withOpacity(0.6),
                    side: BorderSide(color: _text.withOpacity(0.2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: Text(AppConfig.permissionSkipLabel))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(
                  onPressed: onAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                  child: const Text('Allow'))),
              ]),
            ],
          ),
        ),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  Permission Denied Dialog — opens settings when permanently denied
  // ─────────────────────────────────────────────────────────────────────────────

  class PermissionDeniedDialog extends StatelessWidget {
    final AppPermission permission;
    const PermissionDeniedDialog({super.key, required this.permission});

    Color get _primary => AppConfig.useCustomColors
        ? AppConfig.customPrimaryColor : AppTheme.getPalette(AppConfig.themeTemplate).primary;
    Color get _bg => AppConfig.useCustomColors
        ? AppConfig.customSurfaceColor : AppTheme.getPalette(AppConfig.themeTemplate).surface;
    Color get _text => AppConfig.useCustomColors
        ? AppConfig.customTextPrimary : AppTheme.getPalette(AppConfig.themeTemplate).textPrimary;

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        backgroundColor: _bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(AppConfig.permissionDeniedDialogTitle,
            style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
        content: Text(
            '${PermissionService.getPermissionName(permission)}: ${AppConfig.permissionDeniedMessage}',
            style: TextStyle(color: _text.withOpacity(0.75))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppConfig.permissionSkipLabel,
                style: TextStyle(color: _text.withOpacity(0.5)))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); PermissionService.openSettings(); },
            style: ElevatedButton.styleFrom(backgroundColor: _primary),
            child: Text(AppConfig.permissionOpenSettingsLabel,
                style: const TextStyle(color: Colors.white))),
        ],
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  //  Startup Permission Screen — first-launch permission request UI
  // ─────────────────────────────────────────────────────────────────────────────

  class StartupPermissionScreen extends StatefulWidget {
    final VoidCallback onComplete;
    const StartupPermissionScreen({super.key, required this.onComplete});
    @override
    State<StartupPermissionScreen> createState() => _StartupPermissionScreenState();
  }

  class _StartupPermissionScreenState extends State<StartupPermissionScreen> {
    bool _requesting = false;

    Color get _primary => AppConfig.useCustomColors
        ? AppConfig.customPrimaryColor : AppTheme.getPalette(AppConfig.themeTemplate).primary;
    Color get _bg => AppConfig.useCustomColors
        ? AppConfig.customBackgroundColor : AppTheme.getPalette(AppConfig.themeTemplate).background;
    Color get _surface => AppConfig.useCustomColors
        ? AppConfig.customSurfaceColor : AppTheme.getPalette(AppConfig.themeTemplate).surface;
    Color get _text => AppConfig.useCustomColors
        ? AppConfig.customTextPrimary : AppTheme.getPalette(AppConfig.themeTemplate).textPrimary;

    List<Map<String, String>> get _permissionList => [
      if (AppConfig.requestNotificationPermission)
        {'icon': '🔔', 'name': 'Notifications', 'desc': AppConfig.notificationPermissionRationale},
      if (AppConfig.requestCameraPermission)
        {'icon': '📷', 'name': 'Camera', 'desc': AppConfig.cameraPermissionRationale},
      if (AppConfig.requestMicrophonePermission)
        {'icon': '🎤', 'name': 'Microphone', 'desc': AppConfig.microphonePermissionRationale},
      if (AppConfig.requestStoragePermission)
        {'icon': '💾', 'name': 'Storage', 'desc': AppConfig.storagePermissionRationale},
      if (AppConfig.requestLocationPermission)
        {'icon': '📍', 'name': 'Location', 'desc': AppConfig.locationPermissionRationale},
      if (AppConfig.requestBluetoothPermission)
        {'icon': '🔵', 'name': 'Bluetooth', 'desc': AppConfig.bluetoothPermissionRationale},
      if (AppConfig.requestPhoneStatePermission)
        {'icon': '📞', 'name': 'Phone', 'desc': AppConfig.phonePermissionRationale},
    ];

    Future<void> _requestAll() async {
      setState(() => _requesting = true);
      await PermissionService.requestConfiguredPermissions();
      widget.onComplete();
    }

    @override
    Widget build(BuildContext context) {
      final list = _permissionList;
      return Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                Text(AppConfig.permissionScreenTitle,
                    style: TextStyle(color: _text, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 8),
                Text(AppConfig.permissionScreenSubtitle,
                    style: TextStyle(color: _text.withOpacity(0.6), fontSize: 14, height: 1.5)),
                const SizedBox(height: 28),
                Expanded(
                  child: ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final p = list[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _primary.withOpacity(0.2))),
                        child: Row(children: [
                          Text(p['icon']!, style: const TextStyle(fontSize: 28)),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p['name']!, style: TextStyle(
                                  color: _text, fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 3),
                              Text(p['desc']!, style: TextStyle(
                                  color: _text.withOpacity(0.55), fontSize: 12, height: 1.4)),
                            ],
                          )),
                        ]),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requesting ? null : _requestAll,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    child: _requesting
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(AppConfig.permissionAllowAllLabel,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 10),
                Center(child: TextButton(
                  onPressed: _requesting ? null : widget.onComplete,
                  child: Text(AppConfig.permissionSkipAllLabel,
                      style: TextStyle(color: _text.withOpacity(0.45), fontSize: 13)))),
              ],
            ),
          ),
        ),
      );
    }
  }
  