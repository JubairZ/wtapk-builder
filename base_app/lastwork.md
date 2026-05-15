# 📋 lastwork.md — Build Changelog

  ## 🧠 Session: 2026-05-14 (AI Analysis & Full Feature Update)

  ### ✅ New Features Added

  #### 🆕 New Files Created
  | File | Purpose |
  |------|---------|
  | `lib/services/analytics_service.dart` | Local analytics: tracks page visits, session count, time in app |
  | `lib/services/connectivity_service.dart` | Singleton connectivity service with stream-based monitoring |
  | `lib/widgets/offline_banner.dart` | Animated red banner when internet connection is lost |
  | `lib/screens/settings_screen.dart` | In-app settings screen with analytics stats, cache clear, app info |

  #### 🔧 Updated Files
  | File | Changes |
  |------|---------|
  | `lib/config/app_config.dart` | Added sections 13–19: Swipe Nav, Offline, Text Size, QR, Security, Settings, Analytics |
  | `lib/services/update_service.dart` | 3-attempt retry + exponential backoff + offline cache |
  | `lib/screens/webview_screen.dart` | Offline banner, swipe nav, QR share, Copy URL, text size, settings launch, analytics |
  | `lib/main.dart` | Analytics session start on launch |
  | `pubspec.yaml` | Added qr_flutter dependency |
  | `.github/workflows/build_apk.yml` | Gradle cache, pub cache, SHA256 checksums, APK size, minAndroidApi |

  ### 📊 New Features Summary
  1. Swipe left/right for browser back/forward navigation
  2. Animated offline banner (red) when internet lost
  3. QR code dialog to share current URL
  4. Copy current URL to clipboard (one tap)
  5. Text size A+/A- via JavaScript injection
  6. In-app Settings screen with analytics
  7. Local analytics (on-device page visits + session time)
  8. Update service retry logic + offline cache
  9. GitHub Actions: Gradle/pub cache, SHA256, APK size report

  ### 🐛 Previous Fixes
  - v1.1.1: FlutterDownloader crash fix
  - v1.1.0: Tab layout fix
  - v1.0.0: Initial release

  ---
  _Powered by Jubair Sensei | jubair.bro.bd_
  