import 'dart:convert';
  import 'package:shared_preferences/shared_preferences.dart';

  /// Local Analytics — tracks page visits & sessions using SharedPreferences.
  /// No internet required. Data stays on device.
  class AnalyticsService {
    static const _keyVisits = 'analytics_visits';
    static const _keySessions = 'analytics_sessions';
    static const _keyTotalTime = 'analytics_total_ms';
    static DateTime? _sessionStart;

    /// Call on app launch
    static Future<void> startSession() async {
      _sessionStart = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final sessions = prefs.getInt(_keySessions) ?? 0;
      await prefs.setInt(_keySessions, sessions + 1);
    }

    /// Call on app pause/close
    static Future<void> endSession() async {
      if (_sessionStart == null) return;
      final elapsed = DateTime.now().difference(_sessionStart!).inMilliseconds;
      final prefs = await SharedPreferences.getInstance();
      final total = prefs.getInt(_keyTotalTime) ?? 0;
      await prefs.setInt(_keyTotalTime, total + elapsed);
      _sessionStart = null;
    }

    /// Track a page URL visit
    static Future<void> trackPageVisit(String url) async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyVisits) ?? '{}';
      final Map<String, dynamic> map = jsonDecode(raw);
      final host = Uri.tryParse(url)?.host ?? url;
      map[host] = (map[host] ?? 0) + 1;
      await prefs.setString(_keyVisits, jsonEncode(map));
    }

    /// Get total sessions
    static Future<int> getTotalSessions() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keySessions) ?? 0;
    }

    /// Get total time in app (formatted)
    static Future<String> getTotalTimeFormatted() async {
      final prefs = await SharedPreferences.getInstance();
      final ms = prefs.getInt(_keyTotalTime) ?? 0;
      final dur = Duration(milliseconds: ms);
      if (dur.inHours > 0) return '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
      if (dur.inMinutes > 0) return '${dur.inMinutes}m ${dur.inSeconds.remainder(60)}s';
      return '${dur.inSeconds}s';
    }

    /// Get top visited pages (sorted by count)
    static Future<List<MapEntry<String, int>>> getTopPages() async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyVisits) ?? '{}';
      final Map<String, dynamic> map = jsonDecode(raw);
      final entries = map.entries
          .map((e) => MapEntry(e.key, (e.value as num).toInt()))
          .toList();
      entries.sort((a, b) => b.value.compareTo(a.value));
      return entries.take(10).toList();
    }

    /// Clear all analytics data
    static Future<void> clearAll() async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyVisits);
      await prefs.remove(_keySessions);
      await prefs.remove(_keyTotalTime);
    }
  }
  