# 📌 NOTE.md — Important Notes for Developers

> **Project:** Web to APK Maker  
> **Powered by:** Jubair Sensei  
> **GitHub:** [github.com/jubairbro](https://github.com/jubairbro) | **YouTube:** [@jubairsensei](https://youtube.com/@jubairsensei) | **Telegram:** [t.me/JubairSensei](https://t.me/JubairSensei)

---

## 🏗️ Project Structure

```
web-to-apk-maker/
├── .github/
│   └── workflows/
│       └── build_apk.yml          ← GitHub Actions APK builder
├── android/
│   ├── app/
│   │   ├── build.gradle           ← Android build config (package name, min SDK, etc.)
│   │   ├── proguard-rules.pro     ← ProGuard rules for release builds
│   │   └── src/main/
│   │       ├── AndroidManifest.xml ← App permissions
│   │       └── res/               ← Resources (icons, colors, etc.)
│   ├── build.gradle               ← Project-level Gradle config
│   ├── gradle.properties          ← Gradle JVM settings
│   └── settings.gradle            ← Flutter plugin loader
├── lib/
│   ├── config/
│   │   └── app_config.dart        ← ✏️ MAIN CONFIG — edit this file
│   ├── themes/
│   │   └── app_theme.dart         ← 12 built-in color themes
│   ├── templates/
│   │   └── templates.dart         ← All template enums & models
│   ├── screens/
│   │   ├── splash_screen.dart     ← Splash screen (10 templates)
│   │   └── webview_screen.dart    ← Main WebView with all features
│   ├── services/
│   │   ├── update_service.dart    ← Checks GitHub for APK updates
│   │   └── expiry_service.dart    ← App expiry date logic
│   ├── widgets/
│   │   ├── update_dialog.dart     ← Update available dialog
│   │   ├── telegram_dialog.dart   ← Telegram join dialog
│   │   ├── announcement_dialog.dart ← Custom announcement dialog
│   │   ├── expiry_dialog.dart     ← App expired dialog
│   │   └── exit_dialog.dart       ← Exit confirmation dialog
│   └── main.dart                  ← App entry point
├── assets/
│   ├── icon/
│   │   ├── icon.png               ← App launcher icon (512×512)
│   │   └── icon_fg.png            ← Adaptive icon foreground (512×512)
│   └── splash/
│       └── logo.png               ← Splash screen logo
├── pubspec.yaml                   ← Dependencies
├── NOTE.md                        ← 📌 This file
├── lastwork.md                    ← 📋 Changelog of what was built/changed
├── update.md                      ← 🔄 How to update and release new versions
└── ses.md                         ← 🗂️ Session/build info
```

---

## ⚠️ Critical Notes

### 1. Repo Structure (Two repos)

| Repo | Visibility | Purpose |
|------|-----------|---------|
| `JubairZ/wtapk` | 🔒 **Private** | Source code (Flutter app) |
| `JubairZ/wtapk-up` | 🌐 **Public** | APK releases + version.json |

> **Why two repos?**  
> GitHub Releases from **private** repos are NOT publicly downloadable without authentication.  
> The APK is built in the private repo but **released to the public repo** using `PAT_TOKEN`.  
> This means the download URL is always public ✅

### 2. Download URL Format

```
https://github.com/JubairZ/wtapk-up/releases/download/v{VERSION}/web-to-apk-v{VERSION}.apk
```

This URL is **always public** regardless of the source repo being private. ✅

### 3. Update Check URL

```
https://raw.githubusercontent.com/JubairZ/wtapk-up/main/version.json
```

The app fetches this URL on every launch to check for updates.

### 4. version.json Format

```json
{
  "version": "1.0.1",
  "versionCode": 2,
  "downloadUrl": "https://github.com/JubairZ/wtapk-up/releases/download/v1.0.1/web-to-apk-v1.0.1.apk",
  "changelog": "Bug fixes and new features.",
  "forceUpdate": false,
  "releaseDate": "2026-05-13T00:00:00Z"
}
```

> `forceUpdate: true` = users CANNOT skip the update (no "Later" button).

---

## 🔐 GitHub Secrets Required

Set these in the **private repo** settings → Secrets and variables → Actions:

| Secret | Description | Required |
|--------|-------------|---------|
| `PAT_TOKEN` | Personal Access Token with `repo` + `workflow` permission | ✅ YES |
| `KEYSTORE_BASE64` | Base64-encoded `.jks` keystore file | Optional (debug key used otherwise) |
| `KEYSTORE_PASSWORD` | Keystore password | Optional |
| `KEY_ALIAS` | Key alias name | Optional |
| `KEY_PASSWORD` | Key password | Optional |

### Generate keystore:
```bash
keytool -genkey -v -keystore release.jks -keyalg RSA -keysize 2048 \
  -validity 10000 -alias my-key-alias
```

### Encode keystore to base64:
```bash
base64 -i release.jks | pbcopy   # macOS
base64 release.jks               # Linux
```

---

## 📱 Minimum Requirements

- **Android:** 5.0+ (API 21)
- **Flutter:** 3.22.0+
- **Dart:** 3.0.0+
- **Java:** 17

---

## 🎨 Theme System

12 built-in themes in `lib/themes/app_theme.dart`:

| # | Name | Primary Color | Background |
|---|------|--------------|-----------|
| 1 | darkEspresso | Caramel #C17D3C | Dark #0D0500 |
| 2 | lightCream | Coffee #4A2200 | Cream #FFF8F0 |
| 3 | midnightCoffee | Caramel #C17D3C | Navy Dark |
| 4 | redWine | Deep Red #8B0000 | Near Black |
| 5 | forestGreen | Forest #2D5A1B | Dark Green |
| 6 | oceanBlue | Ocean #0D47A1 | Near Black |
| 7 | sunsetOrange | Burnt #E65100 | Dark |
| 8 | purpleMocha | Purple #6A1B9A | Dark |
| 9 | mintLatte | Teal #00695C | Light |
| 10 | roseGold | Rose #B5686B | Dark |
| 11 | carbonBlack | Lime #AEEA00 | Carbon Black |
| 12 | vanillaSky | Mocha #6D4C1F | Vanilla |

---

## 🚀 Quick Customization Checklist

- [ ] Change `appName` in `app_config.dart`
- [ ] Change `websiteUrl` to your website
- [ ] Change `packageName` (must match `android/app/build.gradle`)
- [ ] Set `themeTemplate` to your preferred theme
- [ ] Set `telegramUrl` to your Telegram group
- [ ] Set `updateCheckUrl` (if you fork to your own repo)
- [ ] Replace `assets/icon/icon.png` with your icon (512×512 PNG)
- [ ] Replace `assets/splash/logo.png` with your logo
- [ ] Add GitHub secrets (`PAT_TOKEN`, keystore if signing)
- [ ] Run GitHub Actions → Build & Release APK
