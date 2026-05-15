import 'package:permission_handler/permission_handler.dart';
  import '../config/app_config.dart';

  // ─────────────────────────────────────────────────────────────────────────────
  //  PermissionService — handles all runtime permission requests
  //  Powered by Jubair Sensei | jubair.bro.bd
  // ─────────────────────────────────────────────────────────────────────────────

  enum AppPermission {
    camera,
    microphone,
    storage,
    location,
    notifications,
    bluetooth,
    phone,
  }

  class PermissionResult {
    final AppPermission permission;
    final bool granted;
    final bool permanentlyDenied;

    const PermissionResult({
      required this.permission,
      required this.granted,
      required this.permanentlyDenied,
    });
  }

  class PermissionService {
    // ── Request all enabled permissions from config ────────────────────────────
    static Future<List<PermissionResult>> requestConfiguredPermissions() async {
      final results = <PermissionResult>[];

      final toRequest = <AppPermission, Permission>{};

      if (AppConfig.requestCameraPermission) {
        toRequest[AppPermission.camera] = Permission.camera;
      }
      if (AppConfig.requestMicrophonePermission) {
        toRequest[AppPermission.microphone] = Permission.microphone;
      }
      if (AppConfig.requestStoragePermission) {
        toRequest[AppPermission.storage] = Permission.storage;
      }
      if (AppConfig.requestLocationPermission) {
        toRequest[AppPermission.location] = Permission.locationWhenInUse;
      }
      if (AppConfig.requestNotificationPermission) {
        toRequest[AppPermission.notifications] = Permission.notification;
      }
      if (AppConfig.requestBluetoothPermission) {
        toRequest[AppPermission.bluetooth] = Permission.bluetooth;
      }
      if (AppConfig.requestPhoneStatePermission) {
        toRequest[AppPermission.phone] = Permission.phone;
      }

      if (toRequest.isEmpty) return results;

      // Request all permissions at once
      final statuses = await [
        ...toRequest.values,
      ].request();

      for (final entry in toRequest.entries) {
        final status = statuses[entry.value];
        results.add(PermissionResult(
          permission: entry.key,
          granted: status?.isGranted ?? false,
          permanentlyDenied: status?.isPermanentlyDenied ?? false,
        ));
      }

      return results;
    }

    // ── Check single permission status ────────────────────────────────────────
    static Future<bool> isGranted(Permission permission) async {
      return (await permission.status).isGranted;
    }

    // ── Open app settings (for permanently denied) ────────────────────────────
    static Future<void> openSettings() async {
      await openAppSettings();
    }

    // ── Get permission display name ────────────────────────────────────────────
    static String getPermissionName(AppPermission p) {
      switch (p) {
        case AppPermission.camera:       return 'Camera';
        case AppPermission.microphone:   return 'Microphone';
        case AppPermission.storage:      return 'Storage';
        case AppPermission.location:     return 'Location';
        case AppPermission.notifications: return 'Notifications';
        case AppPermission.bluetooth:    return 'Bluetooth';
        case AppPermission.phone:        return 'Phone';
      }
    }

    // ── Get permission rationale from config ───────────────────────────────────
    static String getRationale(AppPermission p) {
      switch (p) {
        case AppPermission.camera:       return AppConfig.cameraPermissionRationale;
        case AppPermission.microphone:   return AppConfig.microphonePermissionRationale;
        case AppPermission.storage:      return AppConfig.storagePermissionRationale;
        case AppPermission.location:     return AppConfig.locationPermissionRationale;
        case AppPermission.notifications: return AppConfig.notificationPermissionRationale;
        case AppPermission.bluetooth:    return AppConfig.bluetoothPermissionRationale;
        case AppPermission.phone:        return AppConfig.phonePermissionRationale;
      }
    }

    // ── Get permission icon ────────────────────────────────────────────────────
    static String getPermissionIcon(AppPermission p) {
      switch (p) {
        case AppPermission.camera:       return '📷';
        case AppPermission.microphone:   return '🎤';
        case AppPermission.storage:      return '💾';
        case AppPermission.location:     return '📍';
        case AppPermission.notifications: return '🔔';
        case AppPermission.bluetooth:    return '🔵';
        case AppPermission.phone:        return '📞';
      }
    }
  }
  