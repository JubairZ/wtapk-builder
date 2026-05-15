# Web to APK Maker

**Turn any website into a native Android app — in minutes.**

Flutter-based WebView builder with 50+ customizable features. Edit one config file, push to GitHub, get a signed APK automatically.

**Powered by [Jubair Sensei](https://jubair.bro.bd)** | [YouTube](https://youtube.com/@jubairsensei) | [Telegram](https://t.me/JubairSensei)

---

## Features

### Core
- Full WebView with JavaScript support
- Pull-to-refresh
- Swipe left/right for back/forward navigation
- External link detection (opens in browser)
- Custom JavaScript & CSS injection
- Custom User Agent / Desktop mode toggle
- Cookie management & injection

### UI & Themes
- 12 built-in theme templates (dark & light)
- Custom color override system
- 10 splash screen templates (classic, neon, typewriter, gradient wave, etc.)
- 5 toolbar templates
- 5 drawer templates
- 5 error page templates
- 5 loading indicator styles

### Navigation
- Configurable toolbar with back/forward/home/refresh/share buttons
- Navigation drawer with custom items
- Bottom navigation bar
- Overflow menu with advanced options

### New Features (v1.3.0)
- **Find in Page** — search text within any webpage
- **QR Code sharing** — share current URL as QR code
- **Copy URL** — one-tap URL copy to clipboard
- **Text size control** — increase/decrease/reset text size
- **Desktop/Mobile mode toggle** — switch user agent on the fly
- **Offline banner** — animated banner when internet is lost
- **Swipe navigation** — swipe gestures for back/forward
- **Local analytics** — track sessions, time, top pages (on-device only)
- **Settings screen** — app info, cache control, analytics dashboard
- **About Developer** — bottom sheet with developer links
- **Clear All Data** — one-tap clear cache, cookies, analytics
- **Feature status display** — see which features are ON/OFF in settings

### Dialogs
- Auto-update checker (GitHub-hosted version.json)
- Telegram join dialog with cooldown
- Announcement dialog (one-time or recurring)
- Exit confirmation dialog
- App expiry dialog with contact button

### Security
- Screenshot prevention (FLAG_SECURE)
- Biometric app lock (fingerprint/face)
- Haptic feedback on navigation

### Permissions
- Full startup permission screen with rationale
- Camera, microphone, storage, location, notifications, bluetooth, phone
- Individual permission denied dialog with Settings redirect

### Other
- Floating action button (WhatsApp/Telegram/Phone/Email)
- AdMob integration ready (banner + interstitial)
- Rating dialog
- App expiry system
- SHA256 checksums on release

---

## How Users Build Their App

1. **Fork** this repository
2. **Edit** `lib/config/app_config.dart`:
   - Set `websiteUrl` to your website
   - Set `appName`, choose theme, customize toolbar, etc.
3. **Replace** `assets/icon/icon.png` and `assets/splash/logo.png`
4. **Push** to GitHub
5. **Run** "Build & Release APK" workflow (Actions tab)
6. **Download** your APK from Releases

That's it. No coding required.

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── app_config.dart          # ALL customization options (edit this!)
├── screens/
│   ├── splash_screen.dart       # 10 splash templates
│   ├── webview_screen.dart      # Main WebView + all features
│   └── settings_screen.dart     # Settings & analytics
├── services/
│   ├── analytics_service.dart   # Local analytics (SharedPreferences)
│   ├── connectivity_service.dart # Network status monitoring
│   ├── expiry_service.dart      # App expiry checker
│   ├── permission_service.dart  # Runtime permissions
│   └── update_service.dart      # Auto-update from GitHub
├── templates/
│   └── templates.dart           # All template enums & models
├── themes/
│   └── app_theme.dart           # 12 theme palettes
└── widgets/
    ├── announcement_dialog.dart
    ├── exit_dialog.dart
    ├── expiry_dialog.dart
    ├── offline_banner.dart
    ├── permission_dialog.dart
    ├── telegram_dialog.dart
    └── update_dialog.dart
```

---

## GitHub Actions Workflow

The `Build & Release APK` workflow:
- Builds universal + split APKs (arm64, armeabi, x86_64)
- Signs with keystore (if configured via secrets)
- Creates GitHub Release with all APKs
- Updates `version.json` in the releases repo
- Generates SHA256 checksums

### Secrets (optional, for signed builds):
- `KEYSTORE_BASE64` — base64-encoded keystore file
- `KEYSTORE_PASSWORD` — keystore password
- `KEY_ALIAS` — key alias
- `KEY_PASSWORD` — key password
- `PAT_TOKEN` — GitHub PAT for cross-repo release

---

## Requirements

- Flutter 3.22.0+
- Java 17
- Android SDK (minSdk 21)

---

## Developer

**Jubair Ahmad** — Tech Enthusiast & Developer

- Website: [jubair.bro.bd](https://jubair.bro.bd)
- YouTube: [@jubairsensei](https://youtube.com/@jubairsensei)
- Telegram: [@JubairSensei](https://t.me/JubairSensei)
- GitHub: [JubairZ](https://github.com/JubairZ)

---

## License

This project is provided as-is. Credit to Jubair Sensei must be retained.
