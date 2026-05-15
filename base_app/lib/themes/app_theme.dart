import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────
///  12 Built-in Theme Templates
///  Users pick by setting AppConfig.themeTemplate
/// ──────────────────────────────────────────────
enum ThemeTemplate {
  darkEspresso,    // 1  Default — very dark coffee + caramel
  lightCream,      // 2  Warm cream bg + coffee text
  midnightCoffee,  // 3  Navy + coffee accents
  redWine,         // 4  Deep red + brown
  forestGreen,     // 5  Dark green + wood brown
  oceanBlue,       // 6  Deep blue + sandy brown
  sunsetOrange,    // 7  Warm orange + dark brown
  purpleMocha,     // 8  Purple + coffee
  mintLatte,       // 9  Mint + cream
  roseGold,        // 10 Rose gold + dark brown
  carbonBlack,     // 11 Carbon + lime accent
  vanillaSky,      // 12 Light yellow + warm brown
}

class AppTheme {
  static ThemeData getTheme(ThemeTemplate template, bool dark) {
    final palette = _palettes[template]!;
    final brightness = palette.isDark ? Brightness.dark : Brightness.light;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        brightness: brightness,
        primary: palette.primary,
        secondary: palette.secondary,
        surface: palette.surface,
        background: palette.background,
      ),
      scaffoldBackgroundColor: palette.background,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.toolbar,
        foregroundColor: palette.toolbarText,
        elevation: 0,
        centerTitle: true,
      ),
      drawerTheme: DrawerThemeData(backgroundColor: palette.surface),
      textTheme: TextTheme(
        bodyLarge: TextStyle(color: palette.textPrimary),
        bodyMedium: TextStyle(color: palette.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  static const Map<ThemeTemplate, _ThemePalette> _palettes = {
    ThemeTemplate.darkEspresso: _ThemePalette(
      primary: Color(0xFFC17D3C),
      secondary: Color(0xFFD4860A),
      background: Color(0xFF0D0500),
      surface: Color(0xFF1A0800),
      toolbar: Color(0xFF1A0800),
      toolbarText: Color(0xFFF5E6D0),
      textPrimary: Color(0xFFF5E6D0),
      textSecondary: Color(0xFF8B5E3C),
      isDark: true,
    ),
    ThemeTemplate.lightCream: _ThemePalette(
      primary: Color(0xFF4A2200),
      secondary: Color(0xFF8B5E3C),
      background: Color(0xFFFFF8F0),
      surface: Color(0xFFF5E6D0),
      toolbar: Color(0xFF3E1C00),
      toolbarText: Color(0xFFFFF8F0),
      textPrimary: Color(0xFF2D1400),
      textSecondary: Color(0xFF6B3A2A),
      isDark: false,
    ),
    ThemeTemplate.midnightCoffee: _ThemePalette(
      primary: Color(0xFFC17D3C),
      secondary: Color(0xFF8B5E3C),
      background: Color(0xFF0A0E1A),
      surface: Color(0xFF141929),
      toolbar: Color(0xFF141929),
      toolbarText: Color(0xFFF5E6D0),
      textPrimary: Color(0xFFF5E6D0),
      textSecondary: Color(0xFF8B5E3C),
      isDark: true,
    ),
    ThemeTemplate.redWine: _ThemePalette(
      primary: Color(0xFF8B0000),
      secondary: Color(0xFFC17D3C),
      background: Color(0xFF0D0000),
      surface: Color(0xFF1A0000),
      toolbar: Color(0xFF1A0000),
      toolbarText: Color(0xFFF5E6D0),
      textPrimary: Color(0xFFF5E6D0),
      textSecondary: Color(0xFF8B0000),
      isDark: true,
    ),
    ThemeTemplate.forestGreen: _ThemePalette(
      primary: Color(0xFF2D5A1B),
      secondary: Color(0xFF8B5E3C),
      background: Color(0xFF030D00),
      surface: Color(0xFF0A1A05),
      toolbar: Color(0xFF0A1A05),
      toolbarText: Color(0xFFE8F5E9),
      textPrimary: Color(0xFFE8F5E9),
      textSecondary: Color(0xFF4CAF50),
      isDark: true,
    ),
    ThemeTemplate.oceanBlue: _ThemePalette(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFFC17D3C),
      background: Color(0xFF00050D),
      surface: Color(0xFF000A1A),
      toolbar: Color(0xFF000A1A),
      toolbarText: Color(0xFFE3F2FD),
      textPrimary: Color(0xFFE3F2FD),
      textSecondary: Color(0xFF42A5F5),
      isDark: true,
    ),
    ThemeTemplate.sunsetOrange: _ThemePalette(
      primary: Color(0xFFE65100),
      secondary: Color(0xFFC17D3C),
      background: Color(0xFF0D0400),
      surface: Color(0xFF1A0800),
      toolbar: Color(0xFF1A0800),
      toolbarText: Color(0xFFFFF3E0),
      textPrimary: Color(0xFFFFF3E0),
      textSecondary: Color(0xFFFF9800),
      isDark: true,
    ),
    ThemeTemplate.purpleMocha: _ThemePalette(
      primary: Color(0xFF6A1B9A),
      secondary: Color(0xFFC17D3C),
      background: Color(0xFF07000D),
      surface: Color(0xFF0E001A),
      toolbar: Color(0xFF0E001A),
      toolbarText: Color(0xFFF3E5F5),
      textPrimary: Color(0xFFF3E5F5),
      textSecondary: Color(0xFFCE93D8),
      isDark: true,
    ),
    ThemeTemplate.mintLatte: _ThemePalette(
      primary: Color(0xFF00695C),
      secondary: Color(0xFF8B5E3C),
      background: Color(0xFFF1F8F6),
      surface: Color(0xFFE0F2F1),
      toolbar: Color(0xFF004D40),
      toolbarText: Color(0xFFE0F2F1),
      textPrimary: Color(0xFF004D40),
      textSecondary: Color(0xFF00695C),
      isDark: false,
    ),
    ThemeTemplate.roseGold: _ThemePalette(
      primary: Color(0xFFB5686B),
      secondary: Color(0xFFC17D3C),
      background: Color(0xFF0D0608),
      surface: Color(0xFF1A0D10),
      toolbar: Color(0xFF1A0D10),
      toolbarText: Color(0xFFFCE4EC),
      textPrimary: Color(0xFFFCE4EC),
      textSecondary: Color(0xFFB5686B),
      isDark: true,
    ),
    ThemeTemplate.carbonBlack: _ThemePalette(
      primary: Color(0xFFAEEA00),
      secondary: Color(0xFF76FF03),
      background: Color(0xFF050505),
      surface: Color(0xFF0F0F0F),
      toolbar: Color(0xFF0F0F0F),
      toolbarText: Color(0xFFAEEA00),
      textPrimary: Color(0xFFF5F5F5),
      textSecondary: Color(0xFFAEEA00),
      isDark: true,
    ),
    ThemeTemplate.vanillaSky: _ThemePalette(
      primary: Color(0xFF6D4C1F),
      secondary: Color(0xFFD4860A),
      background: Color(0xFFFFFBF0),
      surface: Color(0xFFFFF8E1),
      toolbar: Color(0xFF4E3000),
      toolbarText: Color(0xFFFFF8E1),
      textPrimary: Color(0xFF3E2000),
      textSecondary: Color(0xFF8B6914),
      isDark: false,
    ),
  };

  static _ThemePalette getPalette(ThemeTemplate t) => _palettes[t]!;
}

class _ThemePalette {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color toolbar;
  final Color toolbarText;
  final Color textPrimary;
  final Color textSecondary;
  final bool isDark;

  const _ThemePalette({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.toolbar,
    required this.toolbarText,
    required this.textPrimary,
    required this.textSecondary,
    required this.isDark,
  });
}
