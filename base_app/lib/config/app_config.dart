import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../templates/templates.dart';

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                   WEB TO APK MAKER — app_config.dart                    ║
// ║                   Powered by Jubair Sensei                               ║
// ║                                                                          ║
// ║  ✏️  EDIT THIS FILE to fully customize your Android APK.                ║
// ║  After editing, push to GitHub and run "Build & Release APK" action.    ║
// ║                                                                          ║
// ║  📌 SECTIONS:                                                            ║
// ║   1. App Info          6. Dialogs (Update/Telegram/Announcement)        ║
// ║   2. Theme & Colors    7. App Expiry                                    ║
// ║   3. Splash Screen     8. Navigation                                    ║
// ║   4. Toolbar           9. Ads (AdMob)                                   ║
// ║   5. WebView          10. Rating | Exit | Permissions | Credits         ║
// ╚══════════════════════════════════════════════════════════════════════════╝

class AppConfig {
  // ══════════════════════════════════════════════════════════════
  //  11. FLOATING ACTION BUTTON
  //  Add a WhatsApp / Telegram / Phone / Email chat button
  // ══════════════════════════════════════════════════════════════

  /// Show a floating action button on the main screen
  static bool showFloatingButton = true;

  /// FAB type: 'whatsapp' | 'telegram' | 'phone' | 'email'
  static String floatingButtonType = 'telegram';

  /// WhatsApp number with country code, no + (e.g. '8801712345678')
  static String whatsAppNumber = '';

  /// Pre-filled WhatsApp chat message
  static String whatsAppMessage = 'Hello! I need help.';

  /// Phone number for 'phone' type (with country code)
  static String floatingButtonPhone = '';

  /// Email address for 'email' type
  static String floatingButtonEmail = '';

  /// Tooltip shown when user long-presses the FAB
  static String floatingButtonTooltip = 'Join @JubairSensei';

  // ══════════════════════════════════════════════════════════════
  //  12. CUSTOM JAVASCRIPT INJECTION
  //  Run your own JS on every page load inside the WebView
  // ══════════════════════════════════════════════════════════════

  /// JavaScript injected after every page load (empty = disabled)
  /// Example: "document.querySelectorAll('.ads').forEach(e => e.remove());"
  static String customJavaScript = '';

  // ══════════════════════════════════════════════════════════════
  //  1. APP INFO
  // ══════════════════════════════════════════════════════════════

  /// Your app name shown everywhere in the app
  static String appName = 'Web to APK Maker';

  /// Package name (reverse domain format) — must match build.gradle
  static String packageName = 'bd.bro.jubair.wtapk';

  /// Current version (semantic versioning)
  static String appVersion = '1.0.0';

  /// Version code — increment by 1 with every release
  static const int appVersionCode = 1;

  /// Your website / web app URL that loads inside the WebView
  static String websiteUrl = 'https://jubair.bro.bd';

  // ══════════════════════════════════════════════════════════════
  //  2. THEME & COLORS
  //  Choose one of 12 built-in themes OR use custom colors
  // ══════════════════════════════════════════════════════════════

  /// Pick a theme template (1–12):
  ///   darkEspresso | lightCream | midnightCoffee | redWine
  ///   forestGreen  | oceanBlue  | sunsetOrange   | purpleMocha
  ///   mintLatte    | roseGold   | carbonBlack    | vanillaSky
  static ThemeTemplate themeTemplate = ThemeTemplate.darkEspresso;

  /// Set to true to override theme colors with your own custom colors below
  static bool useCustomColors = false;

  // Custom colors (only used when useCustomColors = true)
  static const Color customPrimaryColor = Color(0xFFC17D3C);
  static const Color customSecondaryColor = Color(0xFFD4860A);
  static const Color customBackgroundColor = Color(0xFF0D0500);
  static const Color customSurfaceColor = Color(0xFF1A0800);
  static const Color customToolbarColor = Color(0xFF1A0800);
  static const Color customToolbarTextColor = Color(0xFFF5E6D0);
  static const Color customTextPrimary = Color(0xFFF5E6D0);
  static const Color customTextSecondary = Color(0xFF8B5E3C);

  // Status bar icon brightness (light = white icons, dark = black icons)
  static const Brightness statusBarBrightness = Brightness.light;

  // ══════════════════════════════════════════════════════════════
  //  3. SPLASH SCREEN
  //  10 built-in templates + full customization
  // ══════════════════════════════════════════════════════════════

  /// Splash template (1–10):
  ///   classicCenter | photoFull | gradientWave | minimalText | iconLarge
  ///   splitScreen   | typewriter | slideUp    | fadeCircle  | neonGlow
  static SplashTemplate splashTemplate = SplashTemplate.classicCenter;

  /// Show logo/photo on splash screen
  static bool showSplashLogo = true;

  /// Path to splash logo image (put your image in assets/splash/)
  /// Leave empty to use default icon widget
  static String splashLogoAsset = 'assets/splash/logo.png';

  /// Show logo as circle (true) or rectangle with rounded corners (false)
  static bool splashRoundedCircle = false;

  /// Logo corner radius (only when splashRoundedCircle = false)
  static const double splashLogoRadius = 24.0;

  /// Logo size in pixels
  static const double splashLogoSize = 120.0;

  /// Main title on splash screen
  static String splashTitle = 'Web to APK Maker';

  /// Subtitle / tagline on splash
  static String splashTagline = 'Turn any website into an Android app';

  /// How many seconds to show splash before loading app
  static const int splashDurationSeconds = 3;

  /// Show progress indicator on splash
  static bool showSplashProgress = true;

  /// Animated dots or circular (true = dots, false = circular)
  static bool splashAnimatedDots = true;

  /// Show "Powered by" credit on splash
  static bool showPoweredBy = true;

  // ══════════════════════════════════════════════════════════════
  //  4. TOOLBAR / APP BAR
  //  5 built-in toolbar templates
  // ══════════════════════════════════════════════════════════════

  /// Show the toolbar at the top
  static bool showToolbar = true;

  /// Toolbar template (1–5):
  ///   standard | transparent | gradient | minimal | floating
  static const ToolbarTemplate toolbarTemplate = ToolbarTemplate.standard;

  /// Title shown in toolbar (empty = show website domain)
  static String toolbarTitle = 'Web to APK Maker';

  /// Show title text in the toolbar (set false to hide it)
  static bool showToolbarTitle = true;

  /// Show the back navigation button
  static bool showBackButton = true;

  /// Show the forward navigation button
  static bool showForwardButton = false;

  /// Show refresh button
  static bool showRefreshButton = true;

  /// Show share button
  static bool showShareButton = true;

  /// Show home button (loads websiteUrl)
  static bool showHomeButton = false;

  /// Show loading progress bar under toolbar
  static bool showProgressBar = true;

  // ══════════════════════════════════════════════════════════════
  //  5. WEBVIEW SETTINGS
  // ══════════════════════════════════════════════════════════════

  /// Enable JavaScript (almost always true)
  static bool enableJavaScript = true;

  /// Allow pinch-to-zoom on pages
  static bool enableZoom = false;

  /// Pull down to refresh the page
  static bool enablePullToRefresh = true;

  /// Show loading indicator while page loads
  static bool showLoadingIndicator = true;

  /// Loading indicator template:
  ///   linearProgress | circularCenter | dotsPulse | skeleton | brandColorBar
  static const LoadingTemplate loadingTemplate = LoadingTemplate.linearProgress;

  /// Allow downloading files from the web
  static bool enableFileDownload = true;

  /// Allow uploading files (camera / gallery / file picker)
  static bool enableFileUpload = true;

  /// Open links to other domains in external browser
  static bool openExternalLinksInBrowser = true;

  /// List of domains that should open inside the app (not in browser)
  static const List<String> internalDomains = [];

  /// Custom user agent string (leave empty for default)
  static String customUserAgent = '';

  /// Enable cookies
  static bool enableCookies = true;

  /// Clear cookies on each launch
  static bool clearCookiesOnLaunch = false;

  /// Clear cache on each launch
  static bool clearCacheOnLaunch = false;

  /// Allow mixed content (http inside https)
  static bool allowMixedContent = true;

  /// Block ads by intercepting known ad domains
  static bool enableAdBlocking = false;

  // ══════════════════════════════════════════════════════════════
  //  6. DIALOGS
  // ══════════════════════════════════════════════════════════════

  // ── 6A. App Update Dialog ──────────────────────────────────────
  /// Auto-check for updates from GitHub raw JSON
  static bool enableAutoUpdate = true;

  /// URL to version.json on raw.githubusercontent.com
  static String updateCheckUrl =
      'https://raw.githubusercontent.com/JubairZ/wtapk-up/main/version.json';

  /// Dialog template for update dialog (1–12)
  static const DialogTemplate updateDialogTemplate =
      DialogTemplate.gradientHeader;

  /// Dialog title when update is available
  static String updateDialogTitle = '🚀 New Update Available!';

  /// Dialog message
  static String updateDialogMessage =
      'A new version is available with exciting improvements. Update now for the best experience!';

  /// Button label to update
  static String updateNowLabel = 'Update Now';

  /// Button label to skip (only shown when not force update)
  static String updateLaterLabel = 'Remind Me Later';

  // ── 6B. Telegram Dialog ────────────────────────────────────────
  /// Show Telegram join dialog on first launch
  static bool showTelegramDialog = true;

  /// Telegram group/channel link
  static String telegramUrl = 'https://t.me/JubairSensei';

  /// Dialog template for Telegram invite
  static const DialogTemplate telegramDialogTemplate =
      DialogTemplate.boldBanner;

  /// Dialog title
  static String telegramDialogTitle = '✈️ Join Jubair Sensei!';

  /// Dialog message
  static String telegramDialogMessage =
      'Get the latest updates, tutorials & exclusive content. Join the community now!';

  /// Join button label
  static String telegramJoinLabel = '✈️  Join @JubairSensei';

  /// Skip button label
  static String telegramSkipLabel = 'Not Now';

  /// Show Telegram dialog again after X days (0 = show once)
  static const int telegramDialogCooldownDays = 3;

  // ── 6C. Announcement Dialog ────────────────────────────────────
  /// Show a custom announcement dialog when the app opens
  static bool showAnnouncementDialog = false;

  /// Announcement dialog template (1–12)
  static const DialogTemplate announcementDialogTemplate =
      DialogTemplate.boldBanner;

  /// Announcement title
  static String announcementTitle = '🚀 Web to APK Maker';

  /// Announcement message
  static String announcementMessage =
      'Write your announcement here. This dialog can be turned on/off anytime.';

  /// Optional action button label (leave empty to hide button)
  static String announcementActionLabel = 'Learn More';

  /// URL opened when action button is tapped
  static String announcementActionUrl = '';

  /// Show announcement only once (true) or every launch (false)
  static bool announcementShowOnce = true;

  /// Show announcement after X seconds of loading
  static const int announcementDelaySeconds = 2;

  // ══════════════════════════════════════════════════════════════
  //  7. APP EXPIRY (Lock app after a date)
  // ══════════════════════════════════════════════════════════════

  /// Enable app expiry feature
  static bool enableExpiry = false;

  /// Expiry date — app shows expiry dialog after this date
  /// Format: DateTime(year, month, day)
  static final DateTime expiryDate = DateTime(2027, 12, 31);

  /// Dialog template for expiry dialog
  static const DialogTemplate expiryDialogTemplate =
      DialogTemplate.fullScreenModal;

  /// Expiry dialog title
  static String expiryDialogTitle = '⏰ App Expired';

  /// Expiry dialog message
  static String expiryDialogMessage =
      'This app version has expired. Please contact the developer for the latest version.';

  /// Contact link shown on expiry dialog (Telegram, WhatsApp, website, etc.)
  static String expiryContactUrl = 'https://t.me/JubairSensei';

  /// Contact button label
  static String expiryContactLabel = 'Contact Developer';

  /// Block app completely on expiry (true = can't use app, false = just show warning)
  static bool expiryBlockApp = true;

  // ══════════════════════════════════════════════════════════════
  //  8. NAVIGATION
  // ══════════════════════════════════════════════════════════════

  // ── 8A. Navigation Drawer ──────────────────────────────────────
  /// Show sidebar navigation drawer
  static bool showDrawer = true;

  /// Drawer template (1–5):
  ///   modernMinimal | colorHeader | avatarName | compactList | categorized
  static const DrawerTemplate drawerTemplate = DrawerTemplate.colorHeader;

  /// App name shown in drawer header
  static String drawerHeaderTitle = 'Web to APK Maker';

  /// Subtitle shown in drawer header
  static String drawerHeaderSubtitle = 'by Jubair Sensei';

  /// Path to avatar/logo in drawer header (leave empty to use default icon)
  static String drawerHeaderLogo = '';

  /// Items in the navigation drawer
  static List<DrawerItem> drawerItems = [
    DrawerItem(title: 'Home', url: websiteUrl, icon: Icons.home_rounded),
    DrawerItem(
      title: 'YouTube',
      url: 'https://youtube.com/@jubairsensei',
      icon: Icons.play_circle_rounded,
      subtitle: '@jubairsensei',
      openInBrowser: true,
    ),
    DrawerItem(
      title: 'Telegram',
      url: 'https://t.me/JubairSensei',
      icon: Icons.send_rounded,
      subtitle: '@JubairSensei',
      openInBrowser: true,
    ),
    DrawerItem(
      title: 'Website',
      url: 'https://jubair.bro.bd',
      icon: Icons.language_rounded,
      subtitle: 'jubair.bro.bd',
    ),
  ];

  // ── 8B. Bottom Navigation Bar ──────────────────────────────────
  /// Show bottom navigation bar
  static bool showBottomNav = false;

  /// Bottom nav template (1–5):
  ///   materialNav | floatingBar | iconOnly | labeledClassic | coloredActive
  static const BottomNavTemplate bottomNavTemplate =
      BottomNavTemplate.materialNav;

  /// Bottom navigation items (max 5 recommended)
  static List<BottomNavItem> bottomNavItems = [
    BottomNavItem(
      label: 'Home',
      url: websiteUrl,
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
    ),
    BottomNavItem(
      label: 'Search',
      url: 'https://jubair.bro.bd',
      icon: Icons.search_rounded,
    ),
    BottomNavItem(
      label: 'About',
      url: 'https://jubair.bro.bd',
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
    ),
  ];

  // ── 8C. Exit Dialog ────────────────────────────────────────────
  /// Show a dialog when user presses back to exit
  static bool showExitDialog = true;

  /// Exit dialog template (1–12)
  static const DialogTemplate exitDialogTemplate =
      DialogTemplate.materialRounded;

  /// Exit dialog title
  static String exitDialogTitle = 'Exit App?';

  /// Exit dialog message
  static String exitDialogMessage =
      'Are you sure you want to exit the app?';

  /// Yes button label
  static String exitYesLabel = 'Exit';

  /// No button label
  static String exitNoLabel = 'Stay';

  // ══════════════════════════════════════════════════════════════
  //  9. ADS (AdMob)
  // ══════════════════════════════════════════════════════════════

  /// Enable Google AdMob ads
  static bool enableAds = false;

  /// AdMob App ID (from AdMob dashboard)
  static String admobAppId = 'ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx';

  /// Banner ad unit ID
  static String bannerAdUnitId = 'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';

  /// Interstitial ad unit ID
  static String interstitialAdUnitId =
      'ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx';

  /// Show banner ad at bottom
  static bool showBannerAd = false;

  /// Show interstitial ad (full screen between page loads)
  static bool showInterstitialAd = false;

  /// Show interstitial every X page loads
  static const int interstitialInterval = 5;

  // ══════════════════════════════════════════════════════════════
  //  10A. RATING DIALOG
  // ══════════════════════════════════════════════════════════════

  /// Ask user to rate app after X days of use
  static bool showRatingDialog = false;

  /// Show rating dialog after X app launches
  static const int ratingAfterLaunches = 5;

  /// Google Play Store URL for rating
  static String playStoreUrl =
      'https://play.google.com/store/apps/details?id=YOUR_PACKAGE';

  /// Rating dialog title
  static String ratingDialogTitle = '⭐ Enjoying the App?';

  /// Rating dialog message
  static String ratingDialogMessage =
      'If you love using this app, please take a moment to rate us on the Play Store. It really helps!';

  // ══════════════════════════════════════════════════════════════
  //  10B. PERMISSIONS
  // ══════════════════════════════════════════════════════════════

  /// Enable camera access (for file upload)
  static bool enableCamera = true;

  /// Enable microphone access
  static bool enableMicrophone = false;

  /// Enable device location / GPS
  static bool enableGeolocation = false;

  /// Enable file storage access
  static bool enableStorage = true;

  // ══════════════════════════════════════════════════════════════
  //  10C. ERROR PAGE
  // ══════════════════════════════════════════════════════════════

  /// Error page template (1–5):
  ///   illustrationRetry | iconMessage | fullScreenDark | cardCentered | minimalText
  static const ErrorTemplate errorTemplate = ErrorTemplate.iconMessage;

  /// Error page title
  static String errorTitle = 'No Internet';

  /// Error page message
  static String errorMessage =
      'Please check your connection and try again.';

  /// Retry button label
  static String errorRetryLabel = 'Try Again';
  // ══════════════════════════════════════════════════════════════
  //  13. SECURITY
  //  Screenshot prevention + Biometric/PIN app lock
  // ══════════════════════════════════════════════════════════════

  /// Prevent screenshots and screen recordings (Android FLAG_SECURE)
  /// ⚠️ Users will see a black screen when trying to screenshot
  static bool preventScreenshots = false;

  // ── 13A. App Lock (Biometric / PIN) ────────────────────────────
  /// Require biometric authentication (fingerprint/face) to open app
  static bool enableAppLock = false;

  /// Title shown on biometric authentication prompt
  static String appLockTitle = 'Unlock App';

  /// Subtitle shown on biometric authentication prompt
  static String appLockSubtitle =
      'Use fingerprint or face ID to continue';

  /// Cancel button label on biometric prompt
  static String appLockCancelLabel = 'Cancel';

  // ══════════════════════════════════════════════════════════════
  //  14. APPEARANCE — Dark / Light Mode
  // ══════════════════════════════════════════════════════════════

  /// Auto-switch theme based on Android system dark/light mode
  /// true  = use darkModeTheme / lightModeTheme below
  /// false = always use themeTemplate from Section 2
  static bool followSystemTheme = false;

  /// Theme used when system is in DARK mode (followSystemTheme must be true)
  static const ThemeTemplate darkModeTheme = ThemeTemplate.darkEspresso;

  /// Theme used when system is in LIGHT mode (followSystemTheme must be true)
  static const ThemeTemplate lightModeTheme = ThemeTemplate.lightCream;

  // ══════════════════════════════════════════════════════════════
  //  15. GESTURES & HAPTICS
  // ══════════════════════════════════════════════════════════════

  /// Enable swipe from left edge to go back in WebView history
  static bool enableSwipeBack = true;

  /// Haptic vibration on navigation actions (back, forward, refresh)
  static bool enableHapticFeedback = false;

  // ══════════════════════════════════════════════════════════════
  //  16. CUSTOM CSS INJECTION
  // ══════════════════════════════════════════════════════════════

  /// CSS injected into every page via <style> tag (empty = disabled)
  /// Example: "body { font-size: 16px !important; } .ads { display: none; }"
  static String customCSS = '';

  // ══════════════════════════════════════════════════════════════
  //  17. COOKIE INJECTION
  // ══════════════════════════════════════════════════════════════

  /// Custom cookies to inject on every page load (empty = disabled)
  /// Format: 'key1=value1; key2=value2'
  static String customCookies = '';

  /// Cookie domain for injection (e.g. '.your-website.com' with leading dot)
  static String cookieDomain = '';

  // ══════════════════════════════════════════════════════════════
  // ══════════════════════════════════════════════════════════════
  //  18. RUNTIME PERMISSIONS
  //  Controls which permissions are requested on app launch
  // ══════════════════════════════════════════════════════════════

  // ── 18A. Permission Screen UI ─────────────────────────────────────────────
  /// Show a full startup screen listing all permissions before requesting
  /// If false, permissions are requested silently in the background
  static bool showPermissionScreen = true;

  /// Title shown on the startup permission screen
  static String permissionScreenTitle = 'App Permissions';

  /// Subtitle/description on the startup permission screen
  static String permissionScreenSubtitle =
      'This app needs the following permissions to work properly. '
      'You can change these anytime in your phone settings.';

  /// Button label — allow all permissions
  static String permissionAllowAllLabel = 'Allow All & Continue';

  /// Text link — skip all permissions
  static String permissionSkipAllLabel = 'Skip for now';

  /// Label for skip button in individual permission dialog
  static String permissionSkipLabel = 'Not Now';

  /// Dialog title shown when permission is denied permanently
  static String permissionDeniedDialogTitle = 'Permission Required';

  /// Message shown when permission is permanently denied
  static String permissionDeniedMessage =
      'This feature needs the permission. Please enable it in your phone Settings.';

  /// Label for "Open Settings" button on denied dialog
  static String permissionOpenSettingsLabel = 'Open Settings';

  // ── 18B. Which Permissions to Request ───────────────────────────────────

  // 🔔 Notifications (required on Android 13+ / API 33+)
  static bool requestNotificationPermission = true;
  static String notificationPermissionRationale =
      'Get important updates, alerts and news directly on your device.';

  // 📷 Camera (for file upload / QR scan inside WebView)
  static bool requestCameraPermission = true;
  static String cameraPermissionRationale =
      'Required to take photos, scan QR codes, and use camera-based features.';

  // 🎤 Microphone (for voice features, audio recording)
  static bool requestMicrophonePermission = false;
  static String microphonePermissionRationale =
      'Required for voice input, audio recording and video calls.';

  // 💾 Storage (read/write files, downloads)
  static bool requestStoragePermission = true;
  static String storagePermissionRationale =
      'Required to save downloaded files and access media on your device.';

  // 📍 Location (GPS / geolocation features)
  static bool requestLocationPermission = false;
  static String locationPermissionRationale =
      'Required to show location-based content, maps and nearby features.';

  // 🔵 Bluetooth (for Bluetooth-based features)
  static bool requestBluetoothPermission = false;
  static String bluetoothPermissionRationale =
      'Required to connect and communicate with nearby Bluetooth devices.';

  // 📞 Phone State (read phone number, network info)
  static bool requestPhoneStatePermission = false;
  static String phonePermissionRationale =
      'Required to access phone state and network information.';

  //  10D. CREDITS (Do not remove — required by license)
  // ══════════════════════════════════════════════════════════════
  static String _developerName = 'Jubair Sensei';
  static String _githubUrl = 'https://github.com/JubairZ';
  static String _youtubeUrl = 'https://youtube.com/@jubairsensei';
  static String _developerTelegramUrl = 'https://t.me/JubairSensei';
  static String _poweredByText =
      'Powered by Jubair Sensei | jubair.bro.bd';

  // Getters (read-only)
  static String get developerName => _developerName;
  static String get githubUrl => _githubUrl;
  static String get youtubeUrl => _youtubeUrl;
  static String get developerTelegramUrl => _developerTelegramUrl;
  static String get poweredBy => _poweredByText;
  // ══════════════════════════════════════════════════════════════
  //  13. SWIPE NAVIGATION
  //  Swipe left/right to navigate browser history
  // ══════════════════════════════════════════════════════════════

  /// Enable swipe left/right gesture to go back/forward in history
  static bool enableSwipeNavigation = true;

  /// Minimum horizontal swipe distance to trigger navigation (pixels)
  static const double swipeThreshold = 80.0;

  // ══════════════════════════════════════════════════════════════
  //  14. OFFLINE MODE
  //  Show animated banner when internet is lost
  // ══════════════════════════════════════════════════════════════

  /// Show animated red banner at top when internet connection is lost
  static bool showOfflineBanner = true;

  /// Message shown in the offline banner
  static String offlineBannerMessage = '📡 No internet connection';

  // ══════════════════════════════════════════════════════════════
  //  15. TEXT SIZE CONTROL
  //  Let users increase/decrease text size via JavaScript
  // ══════════════════════════════════════════════════════════════

  /// Show text size control buttons (A+ / A-) in toolbar overflow menu
  static bool showTextSizeControls = false;

  /// Default text scale factor (1.0 = 100%)
  static const double defaultTextScale = 1.0;

  /// Minimum allowed text scale
  static const double minTextScale = 0.8;

  /// Maximum allowed text scale
  static const double maxTextScale = 1.5;

  /// Step size for each A+/A- press
  static const double textScaleStep = 0.1;

  // ══════════════════════════════════════════════════════════════
  //  16. QR CODE SHARE
  //  Show QR code for current URL — great for sharing between devices
  // ══════════════════════════════════════════════════════════════

  /// Show QR share button in toolbar overflow menu
  static bool showQrShareButton = true;

  // ══════════════════════════════════════════════════════════════
  //  17. SECURITY & PRIVACY
  // ══════════════════════════════════════════════════════════════

  /// Prevent screenshots and screen recording (FLAG_SECURE on Android)
  static bool enableScreenshotPrevention = false;

  /// Show "Copy URL" button in toolbar overflow menu
  static bool showCopyUrlButton = true;

  /// Show "Print" option in toolbar overflow menu
  static bool showPrintButton = false;

  /// Show "Clear Cache" option in toolbar overflow menu
  static bool showClearCacheButton = true;

  // ══════════════════════════════════════════════════════════════
  //  18. IN-APP SETTINGS SCREEN
  //  Settings screen with analytics, cache control, and app info
  // ══════════════════════════════════════════════════════════════

  /// Show Settings option in toolbar overflow menu
  static bool showSettingsButton = true;

  // ══════════════════════════════════════════════════════════════
  //  19. LOCAL ANALYTICS
  //  Track page visits and session time (stored on device only)
  // ══════════════════════════════════════════════════════════════

  /// Enable on-device analytics (page visit counts, session time)
  /// Data is stored locally in SharedPreferences — never sent anywhere
  static bool enableLocalAnalytics = true;
}
