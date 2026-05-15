import 'package:flutter/material.dart';

/// ──────────────────────────────────────────────
///  All Template Enums for Web to APK Maker
///  Powered by Jubair Sensei | jubair.bro.bd
/// ──────────────────────────────────────────────

// ─── Splash Screen Templates ─────────────────────────────────────────────────
enum SplashTemplate {
  classicCenter,    // 1  Logo centered + title + tagline
  photoFull,        // 2  Full background photo + text overlay
  gradientWave,     // 3  Gradient background + animated wave
  minimalText,      // 4  Just app name, clean minimal
  iconLarge,        // 5  Big icon + bouncing animation
  splitScreen,      // 6  Top logo / bottom branding
  typewriter,       // 7  Typewriter text animation
  slideUp,          // 8  Elements slide up from bottom
  fadeCircle,       // 9  Circular reveal animation
  neonGlow,         // 10 Neon glowing icon + dark bg
}

// ─── Dialog Templates ────────────────────────────────────────────────────────
enum DialogTemplate {
  materialRounded,  // 1  Material 3 rounded card
  bottomSheet,      // 2  Modal bottom sheet style
  fullScreenModal,  // 3  Full screen overlay
  bubblePop,        // 4  Bouncy scale-in animation
  sideSlide,        // 5  Slides in from right
  minimalClean,     // 6  Minimal border only
  boldBanner,       // 7  Colored top banner + white body
  cardElevated,     // 8  Elevated card with shadow
  glassMorphism,    // 9  Frosted glass effect
  gradientHeader,   // 10 Gradient top + content below
  iconCentered,     // 11 Large icon centered + text
  alertStyle,       // 12 Classic alert with divider
}

// ─── Loading Templates ────────────────────────────────────────────────────────
enum LoadingTemplate {
  linearProgress,   // 1  Thin line at top of screen
  circularCenter,   // 2  Circular spinner centered
  dotsPulse,        // 3  Three dots pulsing
  skeleton,         // 4  Shimmer skeleton loading
  brandColorBar,    // 5  Thick colored bar at top
}

// ─── Toolbar Templates ────────────────────────────────────────────────────────
enum ToolbarTemplate {
  standard,         // 1  Normal app bar
  transparent,      // 2  Transparent with shadow on scroll
  gradient,         // 3  Gradient colored toolbar
  minimal,          // 4  Just title, no buttons
  floating,         // 5  Floating card-style toolbar
}

// ─── Nav Drawer Templates ────────────────────────────────────────────────────
enum DrawerTemplate {
  modernMinimal,    // 1  Clean, minimal design
  colorHeader,      // 2  Full colored header
  avatarName,       // 3  Circle avatar + name + role
  compactList,      // 4  Dense compact item list
  categorized,      // 5  Items grouped by category
}

// ─── Error Page Templates ────────────────────────────────────────────────────
enum ErrorTemplate {
  illustrationRetry,// 1  Illustration + retry button
  iconMessage,      // 2  Big icon + message + retry
  fullScreenDark,   // 3  Dark full screen error
  cardCentered,     // 4  White card on colored bg
  minimalText,      // 5  Just text + small button
}

// ─── Bottom Nav Templates ────────────────────────────────────────────────────
enum BottomNavTemplate {
  materialNav,      // 1  Material 3 navigation bar
  floatingBar,      // 2  Floating pill-shaped bar
  iconOnly,         // 3  Icons without labels
  labeledClassic,   // 4  Classic tab bar with labels
  coloredActive,    // 5  Filled colored active tab
}

// ─── Drawer Item Model ────────────────────────────────────────────────────────
class DrawerItem {
  final String title;
  final String url;
  final IconData icon;
  final String? subtitle;
  final Color? iconColor;
  final bool openInBrowser;

  const DrawerItem({
    required this.title,
    required this.url,
    required this.icon,
    this.subtitle,
    this.iconColor,
    this.openInBrowser = false,
  });
}

// ─── Bottom Nav Item Model ────────────────────────────────────────────────────
class BottomNavItem {
  final String label;
  final String url;
  final IconData icon;
  final IconData? activeIcon;

  const BottomNavItem({
    required this.label,
    required this.url,
    required this.icon,
    this.activeIcon,
  });
}

// ─── Announcement Item Model ──────────────────────────────────────────────────
class AnnouncementConfig {
  final bool enabled;
  final String title;
  final String message;
  final String? actionLabel;
  final String? actionUrl;
  final String? imageUrl;
  final DialogTemplate dialogTemplate;
  final bool showOnce;
  final int showAfterSeconds;

  const AnnouncementConfig({
    required this.enabled,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionUrl,
    this.imageUrl,
    this.dialogTemplate = DialogTemplate.boldBanner,
    this.showOnce = true,
    this.showAfterSeconds = 0,
  });
}
