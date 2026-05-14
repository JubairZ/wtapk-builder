import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const AppBuilder());
}

class AppBuilder extends StatelessWidget {
  const AppBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Maker',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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
  final _urlCtrl = TextEditingController(text: 'https://');
  final _nameCtrl = TextEditingController();
  String _selectedTheme = 'ThemeTemplate.darkEspresso';
  bool _isBuilding = false;
  String _status = '';
  Timer? _timer;

  final List<String> _themes = [
    'ThemeTemplate.darkEspresso',
    'ThemeTemplate.oceanBlue',
    'ThemeTemplate.forestGreen',
    'ThemeTemplate.redWine',
  ];

  void _startBuild() async {
    if (_nameCtrl.text.isEmpty || _urlCtrl.text.isEmpty) return;
    
    setState(() {
      _isBuilding = true;
      _status = 'Triggering build engine...';
    });

    try {
      final res = await http.post(
        Uri.parse('https://wtapk-api.tamimahmed501ip.workers.dev/build'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'appName': _nameCtrl.text,
          'url': _urlCtrl.text,
          'theme': _selectedTheme
        })
      );

      if (res.statusCode == 200) {
        setState(() => _status = 'Build triggered! Compiling APK in cloud...');
        _pollStatus();
      } else {
        setState(() {
          _isBuilding = false;
          _status = 'Error triggering build.';
        });
      }
    } catch (e) {
      setState(() {
        _isBuilding = false;
        _status = 'Connection error.';
      });
    }
  }

  void _pollStatus() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        final res = await http.get(Uri.parse('https://wtapk-api.tamimahmed501ip.workers.dev/status'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          if (data['status'] == 'completed') {
            timer.cancel();
            setState(() {
              _isBuilding = false;
              _status = data['conclusion'] == 'success' 
                  ? 'Build Success! Check GitHub Releases.' 
                  : 'Build Failed. Check Logs.';
            });
          } else {
            setState(() => _status = 'Compiling... (Status: ${data['status']})');
          }
        }
      } catch (e) {
        // ignore
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create App'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Enter Website URL', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _urlCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'https://example.com'),
            ),
            const SizedBox(height: 20),
            const Text('App Name', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'My Awesome App'),
            ),
            const SizedBox(height: 20),
            const Text('App Theme', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: _themes.map((t) => DropdownMenuItem(value: t, child: Text(t.split('.').last))).toList(),
              onChanged: (v) => setState(() => _selectedTheme = v!),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isBuilding ? null : _startBuild,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isBuilding 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('GENERATE NATIVE APK', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
