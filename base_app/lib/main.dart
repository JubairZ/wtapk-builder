import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'config/app_config.dart';
import 'themes/app_theme.dart';
import 'templates/templates.dart';
import 'screens/splash_screen.dart';
import 'services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Offline Configuration injected by Builder App
  try {
    final configString = await rootBundle.loadString('assets/config.json');
    final config = jsonDecode(configString);
    
    if (config['appName'] != null) {
      AppConfig.appName = config['appName'];
      AppConfig.toolbarTitle = config['appName'];
    }
    if (config['websiteUrl'] != null) {
      AppConfig.websiteUrl = config['websiteUrl'];
    }
    if (config['themeTemplate'] != null) {
      AppConfig.themeTemplate = ThemeTemplate.values.firstWhere(
        (e) => e.toString() == config['themeTemplate'],
        orElse: () => AppConfig.themeTemplate
      );
    }
    if (config['splashTemplate'] != null) {
      AppConfig.splashTemplate = SplashTemplate.values.firstWhere(
        (e) => e.toString() == config['splashTemplate'],
        orElse: () => AppConfig.splashTemplate
      );
    }
  } catch (e) {
    debugPrint("Could not load config.json, using defaults.");
  }

  // Required: initialize download manager before runApp
  await FlutterDownloader.initialize(debug: false, ignoreSsl: false);

  if (AppConfig.enableLocalAnalytics) {
    await AnalyticsService.startSession();
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final palette = AppConfig.useCustomColors
      ? null
      : AppTheme.getPalette(AppConfig.themeTemplate);

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: AppConfig.statusBarBrightness,
      systemNavigationBarColor:
          palette?.background ?? AppConfig.customBackgroundColor,
    ),
  );

  if (AppConfig.preventScreenshots || AppConfig.enableScreenshotPrevention) {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  runApp(const WebToApkApp());
}

class WebToApkApp extends StatelessWidget {
  const WebToApkApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppConfig.useCustomColors
        ? _buildCustomTheme()
        : AppTheme.getTheme(AppConfig.themeTemplate, true);

    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: const SplashScreen(),
    );
  }

  ThemeData _buildCustomTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConfig.customPrimaryColor,
        primary: AppConfig.customPrimaryColor,
        secondary: AppConfig.customSecondaryColor,
        surface: AppConfig.customSurfaceColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: AppConfig.customBackgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: AppConfig.customToolbarColor,
        foregroundColor: AppConfig.customToolbarTextColor,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
