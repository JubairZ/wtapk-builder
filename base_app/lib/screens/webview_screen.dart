import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../config/app_config.dart';
import '../templates/templates.dart';
import '../themes/app_theme.dart';
import '../widgets/exit_dialog.dart';
import '../widgets/offline_banner.dart';
import '../screens/settings_screen.dart';
import '../services/analytics_service.dart';
import '../services/connectivity_service.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData, HapticFeedback;
import 'package:qr_flutter/qr_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> with WidgetsBindingObserver {
  late WebViewController _ctrl;
  bool _isLoading = true;
  bool _hasError = false;
  bool _canGoBack = false;
  bool _canGoForward = false;
  int _loadProgress = 0;
  int _selectedBottomNav = 0;
  bool _isOffline = false;
  double _textScale = AppConfig.defaultTextScale;
  double _swipeStartX = 0.0;
  String _currentUrl = AppConfig.websiteUrl;
  bool _findInPageOpen = false;
  final TextEditingController _findController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  StreamSubscription? _connectivitySub;
  int _pageLoadCount = 0;

  // Theme helpers
  Color get _primary => AppConfig.useCustomColors
      ? AppConfig.customPrimaryColor
      : AppTheme.getPalette(AppConfig.themeTemplate).primary;

  Color get _bg => AppConfig.useCustomColors
      ? AppConfig.customBackgroundColor
      : AppTheme.getPalette(AppConfig.themeTemplate).background;

  Color get _surface => AppConfig.useCustomColors
      ? AppConfig.customSurfaceColor
      : AppTheme.getPalette(AppConfig.themeTemplate).surface;

  Color get _toolbarColor => AppConfig.useCustomColors
      ? AppConfig.customToolbarColor
      : AppTheme.getPalette(AppConfig.themeTemplate).toolbar;

  Color get _toolbarText => AppConfig.useCustomColors
      ? AppConfig.customToolbarTextColor
      : AppTheme.getPalette(AppConfig.themeTemplate).toolbarText;

  Color get _textPrimary => AppConfig.useCustomColors
      ? AppConfig.customTextPrimary
      : AppTheme.getPalette(AppConfig.themeTemplate).textPrimary;

  Color get _textSecondary => AppConfig.useCustomColors
      ? AppConfig.customTextSecondary
      : AppTheme.getPalette(AppConfig.themeTemplate).textSecondary;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initWebView();
    _initConnectivity();
    if (AppConfig.enableLocalAnalytics) {
      AnalyticsService.startSession();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    _findController.dispose();
    if (AppConfig.enableLocalAnalytics) {
      AnalyticsService.endSession();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      AnalyticsService.endSession();
    } else if (state == AppLifecycleState.resumed) {
      AnalyticsService.startSession();
    }
  }

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((result) {
      // connectivity_plus 5.x returns List<ConnectivityResult>
      final bool offline;
      if (result is List) {
        offline = (result as List).every((r) => r == ConnectivityResult.none);
      } else {
        offline = result == ConnectivityResult.none;
      }
      if (mounted) {
        setState(() => _isOffline = offline);
        if (!offline && _hasError) {
          setState(() => _hasError = false);
          _ctrl.reload();
        }
      }
    });
  }

  void _initWebView() {
    _ctrl = WebViewController()
      ..setJavaScriptMode(
        AppConfig.enableJavaScript
            ? JavaScriptMode.unrestricted
            : JavaScriptMode.disabled,
      )
      ..setBackgroundColor(_bg)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _loadProgress = p),
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
              _currentUrl = url;
            });
            _updateNavState();
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
              _currentUrl = url;
            });
            _updateNavState();
            _pageLoadCount++;

            // Track page visit
            if (AppConfig.enableLocalAnalytics) {
              AnalyticsService.trackPageVisit(url);
            }

            // Inject custom JavaScript
            if (AppConfig.customJavaScript.isNotEmpty) {
              _ctrl.runJavaScript(AppConfig.customJavaScript);
            }

            // Inject custom CSS
            if (AppConfig.customCSS.isNotEmpty) {
              _ctrl.runJavaScript(
                'var _wtapkStyle = document.createElement("style");'
                '_wtapkStyle.textContent = "${AppConfig.customCSS.replaceAll('"', '\\"')}";'
                'document.head.appendChild(_wtapkStyle);'
              );
            }

            // Re-apply text scale if changed
            if (_textScale != 1.0) {
              _applyTextScale();
            }
          },
          onWebResourceError: (_) {
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
          onNavigationRequest: (req) {
            if (AppConfig.openExternalLinksInBrowser) {
              final uri = Uri.parse(req.url);
              final base = Uri.parse(AppConfig.websiteUrl);
              final isInternal = AppConfig.internalDomains
                  .any((d) => uri.host.contains(d));
              if (!isInternal &&
                  uri.host != base.host &&
                  req.isMainFrame) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.websiteUrl));

    if (AppConfig.customUserAgent.isNotEmpty) {
      _ctrl.setUserAgent(AppConfig.customUserAgent);
    }
  }

  Future<void> _updateNavState() async {
    final back = await _ctrl.canGoBack();
    final fwd = await _ctrl.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = back;
        _canGoForward = fwd;
      });
    }
  }

  Future<bool> _handleBackPress() async {
    // Close find-in-page if open
    if (_findInPageOpen) {
      setState(() => _findInPageOpen = false);
      _ctrl.runJavaScript('window.find("",false,false,false,false,false,false);');
      return false;
    }

    if (await _ctrl.canGoBack()) {
      if (AppConfig.enableHapticFeedback) HapticFeedback.lightImpact();
      await _ctrl.goBack();
      return false;
    }
    if (AppConfig.showExitDialog) {
      final exit = await showDialog<bool>(
        context: context,
        builder: (_) => const ExitDialog(),
      );
      return exit ?? false;
    }
    return true;
  }

  void _shareCurrentUrl() async {
    final url = await _ctrl.currentUrl() ?? AppConfig.websiteUrl;
    Share.share(url, subject: AppConfig.appName);
  }

  // ── Feature Methods ───────────────────────────────────────────────────

  void _applyTextScale() {
    final pct = (_textScale * 100).round();
    _ctrl.runJavaScript(
        'document.body.style.zoom="$pct%";'
        'document.body.style.webkitTextSizeAdjust="$pct%";');
  }

  void _showQrDialog() async {
    final url = await _ctrl.currentUrl() ?? AppConfig.websiteUrl;
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Share via QR Code',
            style: TextStyle(color: _textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: QrImageView(data: url, version: QrVersions.auto, size: 200),
          ),
          const SizedBox(height: 12),
          Text(url, style: TextStyle(color: _textSecondary, fontSize: 11),
              textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: _primary)),
          ),
        ],
      ),
    );
  }

  void _copyCurrentUrl() async {
    final url = await _ctrl.currentUrl() ?? AppConfig.websiteUrl;
    await Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('URL copied to clipboard!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: _primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _adjustTextSize(double delta) {
    setState(() {
      _textScale = (_textScale + delta)
          .clamp(AppConfig.minTextScale, AppConfig.maxTextScale);
    });
    _applyTextScale();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Text size: ${(_textScale * 100).round()}%'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _primary,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _clearCacheAndReload() async {
    await _ctrl.clearCache();
    await _ctrl.reload();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cache cleared!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _openSettings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => SettingsScreen(webController: _ctrl),
    ));
  }

  void _toggleFindInPage() {
    setState(() => _findInPageOpen = !_findInPageOpen);
    if (!_findInPageOpen) {
      _findController.clear();
      // Clear highlights
      _ctrl.runJavaScript('window.find("",false,false,false,false,false,false);');
    }
  }

  void _findInPage(String query) {
    if (query.isEmpty) return;
    _ctrl.runJavaScript(
      'window.find("$query", false, false, true, false, true, false);'
    );
  }

  void _openDeveloperPage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildDeveloperSheet(),
    );
  }

  Widget _buildDeveloperSheet() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _textSecondary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Avatar
          CircleAvatar(
            radius: 36,
            backgroundColor: _primary,
            child: const Text('JS', style: TextStyle(
              color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text('Jubair Ahmad', style: TextStyle(
            color: _textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Tech Enthusiast & Developer', style: TextStyle(
            color: _textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          // Links
          _developerLink(Icons.language_rounded, 'Website', 'jubair.bro.bd',
              'https://jubair.bro.bd', _primary),
          _developerLink(Icons.play_circle_rounded, 'YouTube', '@jubairsensei',
              AppConfig.youtubeUrl, const Color(0xFFFF0000)),
          _developerLink(Icons.send_rounded, 'Telegram', '@JubairSensei',
              AppConfig.developerTelegramUrl, const Color(0xFF0088CC)),
          _developerLink(Icons.code_rounded, 'GitHub', 'JubairZ',
              AppConfig.githubUrl, _textPrimary),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppConfig.poweredBy,
              style: TextStyle(color: _textSecondary, fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _developerLink(IconData icon, String title, String subtitle,
      String url, Color color) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color, size: 22),
      title: Text(title, style: TextStyle(
          color: _textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(
          color: _textSecondary, fontSize: 12)),
      trailing: Icon(Icons.open_in_new_rounded,
          color: _textSecondary.withOpacity(0.4), size: 16),
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
    );
  }

  // ── Floating Action Button ────────────────────────────────────────────────
  Widget? _buildFab() {
    if (!AppConfig.showFloatingButton) return null;
    return FloatingActionButton(
      onPressed: _launchFabAction,
      tooltip: AppConfig.floatingButtonTooltip,
      backgroundColor: _fabColor(),
      child: Icon(_fabIcon(), color: Colors.white),
    );
  }

  Color _fabColor() {
    switch (AppConfig.floatingButtonType) {
      case 'telegram': return const Color(0xFF0088CC);
      case 'phone':    return _primary;
      case 'email':    return const Color(0xFFEA4335);
      default:         return const Color(0xFF25D366);
    }
  }

  IconData _fabIcon() {
    switch (AppConfig.floatingButtonType) {
      case 'telegram': return Icons.send_rounded;
      case 'phone':    return Icons.phone_rounded;
      case 'email':    return Icons.email_rounded;
      default:         return Icons.chat_rounded;
    }
  }

  void _launchFabAction() async {
    Uri uri;
    switch (AppConfig.floatingButtonType) {
      case 'whatsapp':
        final msg = Uri.encodeComponent(AppConfig.whatsAppMessage);
        uri = Uri.parse('https://wa.me/${AppConfig.whatsAppNumber}?text=$msg');
        break;
      case 'telegram':
        uri = Uri.parse(AppConfig.telegramUrl);
        break;
      case 'phone':
        uri = Uri.parse('tel:${AppConfig.floatingButtonPhone}');
        break;
      case 'email':
        uri = Uri.parse('mailto:${AppConfig.floatingButtonEmail}');
        break;
      default:
        uri = Uri.parse(AppConfig.telegramUrl);
    }
    if (await canLaunchUrl(uri)) {
      launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Error Page ──────────────────────────────────────────────────────────────
  Widget _buildErrorPage() {
    switch (AppConfig.errorTemplate) {
      case ErrorTemplate.fullScreenDark:
        return _errorDark();
      case ErrorTemplate.cardCentered:
        return _errorCard();
      case ErrorTemplate.minimalText:
        return _errorMinimal();
      default:
        return _errorDefault();
    }
  }

  Widget _errorDefault() => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 90,
                  color: _textSecondary.withOpacity(0.4)),
              const SizedBox(height: 24),
              Text(AppConfig.errorTitle,
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(AppConfig.errorMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _textSecondary, fontSize: 14, height: 1.5)),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _hasError = false);
                  _ctrl.reload();
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(AppConfig.errorRetryLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 13),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _errorDark() => Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off_rounded, size: 80, color: _primary),
              const SizedBox(height: 20),
              const Text('No Connection',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(AppConfig.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 13)),
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: () {
                  setState(() => _hasError = false);
                  _ctrl.reload();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white),
                child: Text(AppConfig.errorRetryLabel),
              ),
            ],
          ),
        ),
      );

  Widget _errorCard() => Container(
        color: _primary.withOpacity(0.08),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 70, color: _primary),
                  const SizedBox(height: 16),
                  Text(AppConfig.errorTitle,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(AppConfig.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() => _hasError = false);
                      _ctrl.reload();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white),
                    child: Text(AppConfig.errorRetryLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _errorMinimal() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppConfig.errorTitle,
                style: TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() => _hasError = false);
                _ctrl.reload();
              },
              child: Text(AppConfig.errorRetryLabel,
                  style: TextStyle(color: _primary)),
            ),
          ],
        ),
      );

  // ── Drawer ──────────────────────────────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: _surface,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...AppConfig.drawerItems.map((item) => ListTile(
                      leading: Icon(item.icon, color: _primary, size: 22),
                      title: Text(item.title,
                          style: TextStyle(color: _textPrimary, fontSize: 14)),
                      subtitle: item.subtitle != null
                          ? Text(item.subtitle!,
                              style: TextStyle(
                                  color: _textSecondary, fontSize: 11))
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        if (item.openInBrowser) {
                          launchUrl(Uri.parse(item.url),
                              mode: LaunchMode.externalApplication);
                        } else {
                          _ctrl.loadRequest(Uri.parse(item.url));
                        }
                      },
                    )),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // Developer links in drawer
                ListTile(
                  leading: Icon(Icons.play_circle_rounded,
                      color: const Color(0xFFFF0000), size: 22),
                  title: Text('YouTube',
                      style: TextStyle(color: _textPrimary, fontSize: 14)),
                  subtitle: Text('@jubairsensei',
                      style: TextStyle(color: _textSecondary, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse(AppConfig.youtubeUrl),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.send_rounded,
                      color: const Color(0xFF0088CC), size: 22),
                  title: Text('Telegram',
                      style: TextStyle(color: _textPrimary, fontSize: 14)),
                  subtitle: Text('@JubairSensei',
                      style: TextStyle(color: _textSecondary, fontSize: 11)),
                  onTap: () {
                    Navigator.pop(context);
                    launchUrl(Uri.parse(AppConfig.developerTelegramUrl),
                        mode: LaunchMode.externalApplication);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.info_outline_rounded,
                      color: _primary, size: 22),
                  title: Text('About Developer',
                      style: TextStyle(color: _textPrimary, fontSize: 14)),
                  onTap: () {
                    Navigator.pop(context);
                    _openDeveloperPage();
                  },
                ),
                if (AppConfig.showSettingsButton)
                  ListTile(
                    leading: Icon(Icons.settings_rounded,
                        color: _textSecondary, size: 22),
                    title: Text('Settings',
                        style: TextStyle(color: _textPrimary, fontSize: 14)),
                    onTap: () {
                      Navigator.pop(context);
                      _openSettings();
                    },
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              AppConfig.poweredBy,
              style: TextStyle(color: _textSecondary, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    switch (AppConfig.drawerTemplate) {
      case DrawerTemplate.avatarName:
        return DrawerHeader(
          decoration: BoxDecoration(color: _surface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: _primary,
                child: const Icon(Icons.web_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 10),
              Text(AppConfig.drawerHeaderTitle,
                  style: TextStyle(
                      color: _textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              Text(AppConfig.drawerHeaderSubtitle,
                  style: TextStyle(color: _textSecondary, fontSize: 12)),
            ],
          ),
        );
      case DrawerTemplate.colorHeader:
      default:
        return Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_primary, _primary.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.web_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 10),
                Text(AppConfig.drawerHeaderTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                Text(AppConfig.drawerHeaderSubtitle,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11)),
              ],
            ),
          ),
        );
    }
  }

  // ── Loading Widget ────────────────────────────────────────────────────────
  Widget _buildLoading() {
    switch (AppConfig.loadingTemplate) {
      case LoadingTemplate.circularCenter:
        return Container(
          color: _bg,
          child: Center(
            child: CircularProgressIndicator(color: _primary),
          ),
        );
      case LoadingTemplate.dotsPulse:
        return Container(
          color: _bg,
          child: const Center(child: _PulseDots()),
        );
      case LoadingTemplate.skeleton:
        return Container(color: _bg);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Overflow Menu ─────────────────────────────────────────────────────────
  Widget _buildOverflowMenu() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, color: _toolbarText),
      color: _surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (value) {
        switch (value) {
          case 'find':
            _toggleFindInPage();
            break;
          case 'qr':
            _showQrDialog();
            break;
          case 'copy':
            _copyCurrentUrl();
            break;
          case 'text_increase':
            _adjustTextSize(AppConfig.textScaleStep);
            break;
          case 'text_decrease':
            _adjustTextSize(-AppConfig.textScaleStep);
            break;
          case 'text_reset':
            setState(() => _textScale = 1.0);
            _applyTextScale();
            break;
          case 'clear_cache':
            _clearCacheAndReload();
            break;
          case 'settings':
            _openSettings();
            break;
          case 'developer':
            _openDeveloperPage();
            break;
          case 'desktop_mode':
            _ctrl.setUserAgent(
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
              '(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
            _ctrl.reload();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Desktop mode enabled'),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ));
            break;
          case 'mobile_mode':
            _ctrl.setUserAgent(AppConfig.customUserAgent.isNotEmpty
                ? AppConfig.customUserAgent : '');
            _ctrl.reload();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Mobile mode enabled'),
              backgroundColor: _primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ));
            break;
        }
      },
      itemBuilder: (_) => [
        _menuItem('find', Icons.search_rounded, 'Find in Page'),
        if (AppConfig.showQrShareButton)
          _menuItem('qr', Icons.qr_code_rounded, 'QR Code'),
        if (AppConfig.showCopyUrlButton)
          _menuItem('copy', Icons.copy_rounded, 'Copy URL'),
        const PopupMenuDivider(),
        if (AppConfig.showTextSizeControls) ...[
          _menuItem('text_increase', Icons.text_increase_rounded, 'Increase Text'),
          _menuItem('text_decrease', Icons.text_decrease_rounded, 'Decrease Text'),
          _menuItem('text_reset', Icons.format_size_rounded, 'Reset Text Size'),
          const PopupMenuDivider(),
        ],
        _menuItem('desktop_mode', Icons.desktop_windows_rounded, 'Desktop Mode'),
        _menuItem('mobile_mode', Icons.smartphone_rounded, 'Mobile Mode'),
        const PopupMenuDivider(),
        if (AppConfig.showClearCacheButton)
          _menuItem('clear_cache', Icons.cached_rounded, 'Clear Cache'),
        if (AppConfig.showSettingsButton)
          _menuItem('settings', Icons.settings_rounded, 'Settings'),
        _menuItem('developer', Icons.person_rounded, 'About Developer'),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: _textSecondary),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: _textPrimary, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Find in Page Bar ──────────────────────────────────────────────────────
  Widget _buildFindBar() {
    return AnimatedSlide(
      offset: _findInPageOpen ? Offset.zero : const Offset(0, -1),
      duration: const Duration(milliseconds: 250),
      child: AnimatedOpacity(
        opacity: _findInPageOpen ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          height: 48,
          color: _surface,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _findController,
                  autofocus: true,
                  style: TextStyle(color: _textPrimary, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Find in page...',
                    hintStyle: TextStyle(color: _textSecondary, fontSize: 14),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onSubmitted: _findInPage,
                  onChanged: (v) {
                    if (v.length > 2) _findInPage(v);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_upward_rounded, color: _textSecondary, size: 20),
                onPressed: () => _findInPage(_findController.text),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: _textSecondary, size: 20),
                onPressed: _toggleFindInPage,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────
  PreferredSizeWidget? _buildAppBar() {
    if (!AppConfig.showToolbar) return null;
    return AppBar(
      backgroundColor: _toolbarColor,
      foregroundColor: _toolbarText,
      elevation: 0,
      leading: AppConfig.showDrawer
          ? IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            )
          : AppConfig.showBackButton
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: _canGoBack ? () {
                    if (AppConfig.enableHapticFeedback) HapticFeedback.lightImpact();
                    _ctrl.goBack();
                  } : null,
                )
              : null,
      title: AppConfig.showToolbarTitle
          ? Text(
              AppConfig.toolbarTitle,
              style: TextStyle(
                  color: _toolbarText,
                  fontWeight: FontWeight.w700,
                  fontSize: 16),
            )
          : null,
      actions: [
        if (AppConfig.showForwardButton)
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
            onPressed: _canGoForward ? () {
              if (AppConfig.enableHapticFeedback) HapticFeedback.lightImpact();
              _ctrl.goForward();
            } : null,
          ),
        if (AppConfig.showHomeButton)
          IconButton(
            icon: const Icon(Icons.home_rounded),
            onPressed: () =>
                _ctrl.loadRequest(Uri.parse(AppConfig.websiteUrl)),
          ),
        if (AppConfig.showRefreshButton)
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              if (AppConfig.enableHapticFeedback) HapticFeedback.lightImpact();
              _ctrl.reload();
            },
          ),
        if (AppConfig.showShareButton)
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: _shareCurrentUrl,
          ),
        // Overflow menu with all extra features
        _buildOverflowMenu(),
      ],
      bottom: AppConfig.showProgressBar && _isLoading
          ? PreferredSize(
              preferredSize: const Size.fromHeight(3),
              child: LinearProgressIndicator(
                value: _loadProgress > 0 ? _loadProgress / 100 : null,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                    _primary.withOpacity(0.6)),
                minHeight: 3,
              ),
            )
          : null,
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget? _buildBottomNav() {
    if (!AppConfig.showBottomNav ||
        AppConfig.bottomNavItems.isEmpty) return null;

    return NavigationBar(
      selectedIndex: _selectedBottomNav,
      backgroundColor: _surface,
      indicatorColor: _primary.withOpacity(0.2),
      onDestinationSelected: (i) {
        setState(() => _selectedBottomNav = i);
        _ctrl.loadRequest(
            Uri.parse(AppConfig.bottomNavItems[i].url));
      },
      destinations: AppConfig.bottomNavItems
          .map((item) => NavigationDestination(
                icon: Icon(item.icon,
                    color: _textSecondary),
                selectedIcon: Icon(
                    item.activeIcon ?? item.icon,
                    color: _primary),
                label: item.label,
              ))
          .toList(),
    );
  }

  // ── Swipe Gesture Handling ────────────────────────────────────────────────
  void _onHorizontalDragStart(DragStartDetails details) {
    _swipeStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (!AppConfig.enableSwipeNavigation) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = _swipeStartX; // We track start only
    // Use velocity instead
    final velocity = details.primaryVelocity ?? 0;
    if (velocity > 300 && _canGoBack) {
      // Swipe right = go back
      if (AppConfig.enableHapticFeedback) HapticFeedback.lightImpact();
      _ctrl.goBack();
    } else if (velocity < -300 && _canGoForward) {
      // Swipe left = go forward
      if (AppConfig.enableHapticFeedback) HapticFeedback.lightImpact();
      _ctrl.goForward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _bg,
        appBar: _buildAppBar(),
        drawer: AppConfig.showDrawer ? _buildDrawer() : null,
        body: Column(
          children: [
            // Offline banner
            if (AppConfig.showOfflineBanner)
              OfflineBanner(isOffline: _isOffline),
            // Find in page bar
            if (_findInPageOpen) _buildFindBar(),
            // Main content
            Expanded(
              child: _hasError
                  ? _buildErrorPage()
                  : Stack(
                      children: [
                        GestureDetector(
                          onHorizontalDragStart: AppConfig.enableSwipeNavigation
                              ? _onHorizontalDragStart : null,
                          onHorizontalDragEnd: AppConfig.enableSwipeNavigation
                              ? _onHorizontalDragEnd : null,
                          child: AppConfig.enablePullToRefresh
                              ? RefreshIndicator(
                                  onRefresh: () async => _ctrl.reload(),
                                  color: _primary,
                                  child: WebViewWidget(controller: _ctrl),
                                )
                              : WebViewWidget(controller: _ctrl),
                        ),
                        if (_isLoading && AppConfig.showLoadingIndicator)
                          _buildLoading(),
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: _buildFab(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }
}

// ── Pulse Dots ────────────────────────────────────────────────────────────────
class _PulseDots extends StatefulWidget {
  const _PulseDots();
  @override
  State<_PulseDots> createState() => _PulseDotsState();
}

class _PulseDotsState extends State<_PulseDots> with TickerProviderStateMixin {
  final List<AnimationController> _ctls = [];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      _ctls.add(c);
      Future.delayed(Duration(milliseconds: i * 160), () {
        if (mounted) c.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _ctls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (i) => AnimatedBuilder(
          animation: _ctls[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.3 + _ctls[i].value * 0.7),
            ),
          ),
        ),
      ),
    );
  }
}
