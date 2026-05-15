import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../themes/app_theme.dart';
import '../services/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsScreen extends StatefulWidget {
  final WebViewController? webController;
  const SettingsScreen({super.key, this.webController});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _totalSessions = 0;
  String _totalTime = '0s';
  List<MapEntry<String, int>> _topPages = [];
  String _appVersion = '';
  String _buildNumber = '';
  bool _loadingAnalytics = true;

  Color get _primary => AppConfig.useCustomColors
      ? AppConfig.customPrimaryColor
      : AppTheme.getPalette(AppConfig.themeTemplate).primary;
  Color get _bg => AppConfig.useCustomColors
      ? AppConfig.customBackgroundColor
      : AppTheme.getPalette(AppConfig.themeTemplate).background;
  Color get _surface => AppConfig.useCustomColors
      ? AppConfig.customSurfaceColor
      : AppTheme.getPalette(AppConfig.themeTemplate).surface;
  Color get _textPrimary => AppConfig.useCustomColors
      ? AppConfig.customTextPrimary
      : AppTheme.getPalette(AppConfig.themeTemplate).textPrimary;
  Color get _textSecondary => AppConfig.useCustomColors
      ? AppConfig.customTextSecondary
      : AppTheme.getPalette(AppConfig.themeTemplate).textSecondary;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final info = await PackageInfo.fromPlatform();
    final sessions = await AnalyticsService.getTotalSessions();
    final time = await AnalyticsService.getTotalTimeFormatted();
    final pages = await AnalyticsService.getTopPages();
    if (mounted) {
      setState(() {
        _appVersion = info.version;
        _buildNumber = info.buildNumber;
        _totalSessions = sessions;
        _totalTime = time;
        _topPages = pages;
        _loadingAnalytics = false;
      });
    }
  }

  Future<void> _clearCache() async {
    if (widget.webController != null) {
      await widget.webController!.clearCache();
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Cache cleared successfully!'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _clearAnalytics() async {
    await AnalyticsService.clearAll();
    await _loadData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Analytics data cleared!'),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Clear All Data?',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
            'This will clear cache, cookies, analytics and all stored data. This action cannot be undone.',
            style: TextStyle(color: _textSecondary, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      if (widget.webController != null) {
        await widget.webController!.clearCache();
        await widget.webController!.clearLocalStorage();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await AnalyticsService.clearAll();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('All data cleared!'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _surface,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: Text('Settings',
            style: TextStyle(color: _textPrimary, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── App Info ──────────────────────────────────────────────────
          _sectionHeader('App Info'),
          _card([
            _infoRow(Icons.apps_rounded, 'App Name', AppConfig.appName),
            _divider(),
            _infoRow(Icons.link_rounded, 'Website', AppConfig.websiteUrl),
            _divider(),
            _infoRow(Icons.tag_rounded, 'Version', 'v$_appVersion+$_buildNumber'),
            _divider(),
            _infoRow(Icons.android_rounded, 'Min Android', 'API ${AppConfig.packageName.isNotEmpty ? "21" : "21"}'),
          ]),

          // ── Browser Actions ───────────────────────────────────────────
          if (widget.webController != null) ...[
            const SizedBox(height: 16),
            _sectionHeader('Browser'),
            _card([
              _actionRow(Icons.cached_rounded, 'Clear Cache',
                  'Free up storage space', Colors.orange, _clearCache),
              _divider(),
              _actionRow(Icons.delete_sweep_rounded, 'Clear All Data',
                  'Cache, cookies, analytics', Colors.redAccent, _clearAllData),
              _divider(),
              _actionRow(Icons.home_rounded, 'Go to Homepage',
                  AppConfig.websiteUrl, _primary, () {
                widget.webController!.loadRequest(Uri.parse(AppConfig.websiteUrl));
                Navigator.pop(context);
              }),
            ]),
          ],

          // ── Usage Analytics ───────────────────────────────────────────
          if (AppConfig.enableLocalAnalytics) ...[
            const SizedBox(height: 16),
            _sectionHeader('Usage Analytics'),
            _card([
              _statRow(Icons.smartphone_rounded, 'Total Sessions', '$_totalSessions'),
              _divider(),
              _statRow(Icons.timer_rounded, 'Time in App', _totalTime),
            ]),

            if (!_loadingAnalytics && _topPages.isNotEmpty) ...[
              const SizedBox(height: 8),
              _card([
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text('Top Visited Pages',
                      style: TextStyle(
                          color: _textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                ..._topPages.asMap().entries.map((entry) => Column(children: [
                      ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: _primary.withOpacity(0.15),
                          child: Text('${entry.key + 1}',
                              style: TextStyle(
                                  color: _primary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        title: Text(entry.value.key,
                            style: TextStyle(color: _textPrimary, fontSize: 13)),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: _primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10)),
                          child: Text('${entry.value.value}x',
                              style: TextStyle(
                                  color: _primary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (entry.key < _topPages.length - 1) _divider(),
                    ])),
                _divider(),
                _actionRow(Icons.delete_outline_rounded, 'Clear Analytics Data', '',
                    Colors.redAccent, _clearAnalytics),
              ]),
            ],
          ],

          // ── Features Status ─────────────────────────────────────────
          const SizedBox(height: 16),
          _sectionHeader('Features'),
          _card([
            _featureRow('Swipe Navigation', AppConfig.enableSwipeNavigation),
            _divider(),
            _featureRow('Offline Banner', AppConfig.showOfflineBanner),
            _divider(),
            _featureRow('QR Share', AppConfig.showQrShareButton),
            _divider(),
            _featureRow('Text Size Control', AppConfig.showTextSizeControls),
            _divider(),
            _featureRow('Pull to Refresh', AppConfig.enablePullToRefresh),
            _divider(),
            _featureRow('Auto Update', AppConfig.enableAutoUpdate),
            _divider(),
            _featureRow('Local Analytics', AppConfig.enableLocalAnalytics),
          ]),

          // ── Developer / About ─────────────────────────────────────────
          const SizedBox(height: 16),
          _sectionHeader('Developer'),
          _card([
            _linkRow(Icons.person_rounded, 'Jubair Ahmad',
                'jubair.bro.bd', 'https://jubair.bro.bd', _primary),
            _divider(),
            _linkRow(Icons.play_circle_rounded, 'YouTube',
                '@jubairsensei', AppConfig.youtubeUrl,
                const Color(0xFFFF0000)),
            _divider(),
            _linkRow(Icons.send_rounded, 'Telegram',
                '@JubairSensei', AppConfig.developerTelegramUrl,
                const Color(0xFF0088CC)),
            _divider(),
            _linkRow(Icons.code_rounded, 'GitHub',
                'JubairZ', AppConfig.githubUrl,
                _textPrimary),
          ]),

          const SizedBox(height: 12),
          Center(
            child: Text(
              AppConfig.poweredBy,
              style: TextStyle(color: _textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'v$_appVersion+$_buildNumber',
              style: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 10),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(),
            style: TextStyle(
                color: _textSecondary, fontSize: 11,
                fontWeight: FontWeight.w700, letterSpacing: 1.1)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10, offset: const Offset(0, 2))]),
        child: Column(children: children),
      );

  Widget _divider() => Divider(
      height: 1, indent: 16, endIndent: 0,
      color: _textSecondary.withOpacity(0.1));

  Widget _infoRow(IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: _primary, size: 20),
        title: Text(label, style: TextStyle(color: _textSecondary, fontSize: 12)),
        trailing: Flexible(
          child: Text(value,
              textAlign: TextAlign.end, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      );

  Widget _statRow(IconData icon, String label, String value) => ListTile(
        leading: Icon(icon, color: _primary, size: 20),
        title: Text(label, style: TextStyle(color: _textPrimary, fontSize: 13)),
        trailing: Text(value,
            style: TextStyle(color: _primary, fontSize: 16, fontWeight: FontWeight.bold)),
      );

  Widget _featureRow(String label, bool enabled) => ListTile(
        dense: true,
        title: Text(label, style: TextStyle(color: _textPrimary, fontSize: 13)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: enabled
                ? Colors.green.withOpacity(0.15)
                : Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            enabled ? 'ON' : 'OFF',
            style: TextStyle(
              color: enabled ? Colors.green : Colors.red,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _actionRow(IconData icon, String title, String subtitle,
          Color color, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(title, style: TextStyle(
            color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: subtitle.isEmpty ? null : Text(subtitle,
            style: TextStyle(color: _textSecondary, fontSize: 11),
            overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.chevron_right_rounded,
            color: _textSecondary.withOpacity(0.5), size: 18),
        onTap: onTap,
      );

  Widget _linkRow(IconData icon, String title, String subtitle,
          String url, Color color) =>
      ListTile(
        leading: Icon(icon, color: color, size: 20),
        title: Text(title, style: TextStyle(
            color: _textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle,
            style: TextStyle(color: _textSecondary, fontSize: 11)),
        trailing: Icon(Icons.open_in_new_rounded,
            color: _textSecondary.withOpacity(0.5), size: 16),
        onTap: () => _launchUrl(url),
      );
}
