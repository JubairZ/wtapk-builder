import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const OfflineBuilderApp());
}

class OfflineBuilderApp extends StatelessWidget {
  const OfflineBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web to APK Maker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC17D3C),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0500),
        useMaterial3: true,
      ),
      home: const BuilderScreen(),
    );
  }
}

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  static const platform = MethodChannel('bd.bro.jubair/apk_builder');
  static const _telegramUrl = 'https://t.me/JubairSensei';
  static const _youtubeUrl = 'https://youtube.com/@jubairsensei';
  static const _websiteUrl = 'https://jubair.bro.bd';
  static const _githubUrl = 'https://github.com/JubairZ';

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController(text: "My Web App");
  final _urlCtrl = TextEditingController(text: "https://jubair.bro.bd");
  String _selectedTheme = "ThemeTemplate.darkEspresso";
  String _selectedSplash = "SplashTemplate.classicCenter";

  bool _isBuilding = false;
  String _status = '';
  String? _builtApkPath;

  final List<String> _themes = [
    'ThemeTemplate.darkEspresso',
    'ThemeTemplate.lightCream',
    'ThemeTemplate.midnightCoffee',
    'ThemeTemplate.redWine',
    'ThemeTemplate.forestGreen',
    'ThemeTemplate.oceanBlue',
    'ThemeTemplate.sunsetOrange',
    'ThemeTemplate.purpleMocha',
    'ThemeTemplate.mintLatte',
    'ThemeTemplate.roseGold',
    'ThemeTemplate.carbonBlack',
    'ThemeTemplate.vanillaSky',
  ];

  final List<String> _splashes = [
    'SplashTemplate.classicCenter',
    'SplashTemplate.photoFull',
    'SplashTemplate.gradientWave',
    'SplashTemplate.minimalText',
    'SplashTemplate.iconLarge',
    'SplashTemplate.neonGlow',
    'SplashTemplate.splitScreen',
    'SplashTemplate.typewriter',
    'SplashTemplate.slideUp',
    'SplashTemplate.fadeCircle',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  String _normalizeUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    return 'https://$trimmed';
  }

  String _safeFileName(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '_');
    return cleaned.isEmpty ? 'webview_app' : cleaned;
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<File> _copyAssetToFile(String assetPath, String fileName) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
      return file;
    } catch (e) {
      throw Exception("Failed to load $assetPath: $e");
    }
  }

  Future<void> _buildApk() async {
    if (!_formKey.currentState!.validate()) return;
    final appName = _nameCtrl.text.trim();
    final websiteUrl = _normalizeUrl(_urlCtrl.text);
    _urlCtrl.text = websiteUrl;

    setState(() {
      _isBuilding = true;
      _status = 'Extracting base resources...';
      _builtApkPath = null;
    });

    try {
      final baseApk = await _copyAssetToFile('assets/base.apk', 'base.apk');
      final keystore = await _copyAssetToFile(
        'assets/signer.jks',
        'signer.jks',
      );

      if (!await keystore.exists()) throw Exception("JKS file not created!");

      final outDir = Directory('/storage/emulated/0/Download');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }
      final outPath = '${outDir.path}/${_safeFileName(appName)}.apk';

      final configJson = jsonEncode({
        'appName': appName,
        'websiteUrl': websiteUrl,
        'themeTemplate': _selectedTheme,
        'splashTemplate': _selectedSplash,
      });

      setState(() => _status = 'Patching config and signing APK...');

      await platform.invokeMethod('buildApk', {
        'baseApkPath': baseApk.path,
        'outputPath': outPath,
        'keystorePath': keystore.path,
        'keyPassword': 'wtapk123',
        'alias': 'wtapk',
        'aliasPassword': 'wtapk123',
        'jsonConfigData': configJson,
      });

      setState(() {
        _status = 'Success! APK saved and ready to share.';
        _builtApkPath = outPath;
        _isBuilding = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Build Failed: ${e.toString()}';
        _isBuilding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web to APK Maker'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Telegram',
            onPressed: () => _launchExternal(_telegramUrl),
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _heroCard(),
              const SizedBox(height: 18),
              _sectionTitle('Create Android WebView App'),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'App Name',
                  hintText: 'Example: My Shop',
                  prefixIcon: Icon(Icons.apps_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter app name';
                  }
                  if (value.trim().length < 2) return 'App name is too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlCtrl,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Website URL',
                  hintText: 'https://example.com',
                  prefixIcon: Icon(Icons.language_rounded),
                ),
                validator: (value) {
                  final raw = value?.trim() ?? '';
                  if (raw.isEmpty) return 'Enter website URL';
                  final uri = Uri.tryParse(_normalizeUrl(raw));
                  if (uri == null || uri.host.isEmpty) return 'Enter valid URL';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _sectionTitle('Design'),
              DropdownButtonFormField<String>(
                value: _selectedTheme,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Theme Template',
                  prefixIcon: Icon(Icons.palette_rounded),
                ),
                items: _themes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedTheme = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedSplash,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Splash Template',
                  prefixIcon: Icon(Icons.auto_awesome_rounded),
                ),
                items: _splashes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.split('.').last),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedSplash = v!),
              ),
              const SizedBox(height: 18),
              _featureGrid(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isBuilding ? null : _buildApk,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(20),
                  backgroundColor: const Color(0xFFC17D3C),
                  foregroundColor: Colors.white,
                ),
                child: _isBuilding
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'GENERATE WEB TO APK',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              if (_status.isNotEmpty)
                Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (_builtApkPath != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'File Saved:\n$_builtApkPath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Share.shareXFiles([
                      XFile(_builtApkPath!),
                    ], text: 'Here is your new App!');
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share / Install APK'),
                ),
              ],
              const SizedBox(height: 24),
              _sectionTitle('About Jubair Sensei'),
              _aboutCard(),
              const SizedBox(height: 28),
              const Text(
                'Powered by Jubair Sensei | jubair.bro.bd',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A0F00), Color(0xFF6B3A14)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.android_rounded, size: 42, color: Color(0xFFFFC27A)),
          SizedBox(height: 12),
          Text(
            'Web to APK Maker',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8),
          Text(
            'Enter app name, website URL, theme, and splash style. This app patches a base APK and signs it offline.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _featureGrid() {
    const features = [
      ('Offline build', Icons.offline_bolt_rounded),
      ('Signed APK', Icons.verified_rounded),
      ('12 themes', Icons.palette_rounded),
      ('10 splashes', Icons.auto_awesome_rounded),
      ('Share ready', Icons.share_rounded),
      ('No Replit needed', Icons.phone_android_rounded),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: features.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.$2, size: 17, color: const Color(0xFFC17D3C)),
              const SizedBox(width: 7),
              Text(
                item.$1,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _aboutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Jubair Ahmad',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tech Enthusiast | Jubair Sensei',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          const Text(
            'Learn with easy tutorials. Build useful Android WebView apps from websites and share them with your users.',
            style: TextStyle(color: Colors.white70, height: 1.4),
          ),
          const SizedBox(height: 14),
          _linkTile(
            Icons.language_rounded,
            'Website',
            'jubair.bro.bd',
            _websiteUrl,
          ),
          _linkTile(
            Icons.send_rounded,
            'Telegram',
            '@JubairSensei',
            _telegramUrl,
          ),
          _linkTile(
            Icons.play_circle_rounded,
            'YouTube',
            '@jubairsensei',
            _youtubeUrl,
          ),
          _linkTile(Icons.code_rounded, 'GitHub', 'JubairZ', _githubUrl),
        ],
      ),
    );
  }

  Widget _linkTile(IconData icon, String title, String subtitle, String url) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon, color: const Color(0xFFC17D3C)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.open_in_new_rounded, size: 18),
      onTap: () => _launchExternal(url),
    );
  }
}
