import 'dart:convert';
  import 'package:http/http.dart' as http;
  import 'package:shared_preferences/shared_preferences.dart';
  import '../config/app_config.dart';

  class UpdateInfo {
    final String version;
    final int versionCode;
    final String downloadUrl;
    final String changelog;
    final bool forceUpdate;
    final String? releaseDate;

    const UpdateInfo({
      required this.version,
      required this.versionCode,
      required this.downloadUrl,
      required this.changelog,
      required this.forceUpdate,
      this.releaseDate,
    });

    factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
          version: json['version'] ?? '',
          versionCode: json['versionCode'] ?? 0,
          downloadUrl: json['downloadUrl'] ?? '',
          changelog: json['changelog'] ?? 'Bug fixes and performance improvements.',
          forceUpdate: json['forceUpdate'] ?? false,
          releaseDate: json['releaseDate'],
        );

    Map<String, dynamic> toJson() => {
          'version': version,
          'versionCode': versionCode,
          'downloadUrl': downloadUrl,
          'changelog': changelog,
          'forceUpdate': forceUpdate,
          'releaseDate': releaseDate,
        };
  }

  class UpdateService {
    static const _cacheKey = 'cached_update_info';
    static const _maxRetries = 3;

    /// Check for update from remote. Falls back to cached result if offline.
    static Future<UpdateInfo?> checkForUpdate() async {
      if (!AppConfig.enableAutoUpdate) return null;

      // Try with retry + exponential backoff
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          final res = await http
              .get(
                Uri.parse(AppConfig.updateCheckUrl),
                headers: {'Cache-Control': 'no-cache'},
              )
              .timeout(const Duration(seconds: 10));

          if (res.statusCode == 200) {
            final json = jsonDecode(res.body) as Map<String, dynamic>;
            final info = UpdateInfo.fromJson(json);

            // Cache for offline fallback
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_cacheKey, jsonEncode(info.toJson()));

            if (info.versionCode > AppConfig.appVersionCode) return info;
            return null;
          }
        } catch (_) {
          if (attempt == _maxRetries) break;
          // Exponential backoff: 1s, 2s, 4s
          await Future.delayed(Duration(seconds: 1 << (attempt - 1)));
        }
      }

      // Offline fallback: use cached update info
      return _getCachedUpdate();
    }

    /// Returns cached update if available and still newer than current version.
    static Future<UpdateInfo?> _getCachedUpdate() async {
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(_cacheKey);
        if (raw == null) return null;
        final info = UpdateInfo.fromJson(jsonDecode(raw));
        if (info.versionCode > AppConfig.appVersionCode) return info;
      } catch (_) {}
      return null;
    }

    /// Clear cached update data
    static Future<void> clearCache() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
    }
  }
  