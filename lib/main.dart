import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const OfflineBuilderApp());
}

class OfflineBuilderApp extends StatelessWidget {
  const OfflineBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Offline App Maker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
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

  final _nameCtrl = TextEditingController(text: "My Web App");
  final _urlCtrl = TextEditingController(text: "https://jubair.bro.bd");
  String _selectedTheme = "ThemeTemplate.darkEspresso";
  String _selectedSplash = "SplashTemplate.classicCenter";

  bool _isBuilding = false;
  String _status = '';
  String? _builtApkPath;

  final List<String> _themes = [
    'ThemeTemplate.darkEspresso', 'ThemeTemplate.lightCream', 
    'ThemeTemplate.midnightCoffee', 'ThemeTemplate.redWine',
    'ThemeTemplate.forestGreen', 'ThemeTemplate.oceanBlue',
    'ThemeTemplate.sunsetOrange', 'ThemeTemplate.purpleMocha',
  ];

  final List<String> _splashes = [
    'SplashTemplate.classicCenter', 'SplashTemplate.photoFull',
    'SplashTemplate.gradientWave', 'SplashTemplate.minimalText',
    'SplashTemplate.iconLarge', 'SplashTemplate.neonGlow',
  ];

  Future<File> _copyAssetToFile(String assetPath, String fileName) async {
    final byteData = await rootBundle.load(assetPath);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file;
  }

  Future<void> _buildApk() async {
    if (_nameCtrl.text.isEmpty || _urlCtrl.text.isEmpty) return;

    setState(() {
      _isBuilding = true;
      _status = 'Extracting base resources...';
      _builtApkPath = null;
    });

    try {
      // 1. Copy base APK and Keystore from assets to Temp Dir
      final baseApk = await _copyAssetToFile('assets/base.apk', 'base.apk');
      final keystore = await _copyAssetToFile('assets/signer.jks', 'signer.jks');

      // 2. Prepare Output Path (Save directly to Downloads)
      final outDir = Directory('/storage/emulated/0/Download');
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
      }
      final outPath = '${outDir.path}/${_nameCtrl.text.replaceAll(' ', '_')}.apk';

      // 3. Prepare Config JSON
      final configJson = jsonEncode({
        'appName': _nameCtrl.text,
        'websiteUrl': _urlCtrl.text,
        'themeTemplate': _selectedTheme,
        'splashTemplate': _selectedSplash
      });

      setState(() => _status = 'Patching & Cryptographically Signing APK...');

      // 4. Call Native Kotlin Code
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
        _status = 'Success! Saved to Downloads folder.';
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
      appBar: AppBar(title: const Text('Offline App Maker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Inputs
            const Text('App Name'),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Website URL'),
            TextField(controller: _urlCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 16),
            const Text('Theme Template'),
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _themes.map((t) => DropdownMenuItem(value: t, child: Text(t.split('.').last))).toList(),
              onChanged: (v) => setState(() => _selectedTheme = v!),
            ),
            const SizedBox(height: 16),
            const Text('Splash Template'),
            DropdownButtonFormField<String>(
              value: _selectedSplash,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _splashes.map((t) => DropdownMenuItem(value: t, child: Text(t.split('.').last))).toList(),
              onChanged: (v) => setState(() => _selectedSplash = v!),
            ),
            const SizedBox(height: 32),

            // Build Button
            ElevatedButton(
              onPressed: _isBuilding ? null : _buildApk,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
              child: _isBuilding 
                  ? const CircularProgressIndicator()
                  : const Text('GENERATE OFFLINE APK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),

            // Share Button
            if (_builtApkPath != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                child: Text('File Saved:\n$_builtApkPath', textAlign: TextAlign.center, style: const TextStyle(color: Colors.green, fontSize: 12)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Share.shareXFiles([XFile(_builtApkPath!)], text: 'Here is your new App!');
                },
                icon: const Icon(Icons.share),
                label: const Text('Share / Install APK'),
              )
            ]
          ],
        ),
      ),
    );
  }
}
