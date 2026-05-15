# 🔄 update.md — How to Update & Release

> **Project:** Web to APK Maker  
> **Developer:** Jubair Sensei | [github.com/jubairbro](https://github.com/jubairbro)

---

## 📦 How to Release a New APK Version

### Method 1: GitHub Actions (Recommended ✅)

**Step 1:** Go to your private repo on GitHub  
`github.com/JubairZ/wtapk`

**Step 2:** Click **Actions** tab → **🚀 Build & Release APK**

**Step 3:** Click **Run workflow** → Fill in the fields:

| Field | Example | Description |
|-------|---------|-------------|
| `version_name` | `1.0.1` | Semantic version (shown to users) |
| `version_code` | `2` | Integer, increment by 1 each release |
| `changelog` | `Fixed crash on Android 14` | What changed in this version |
| `force_update` | `false` | `true` = users MUST update |

**Step 4:** Click **Run workflow** → Wait ~5–10 minutes

**What happens automatically:**
1. ✅ Flutter APK is built (universal + arm64 + armv7 + x86_64)
2. ✅ Release created in PUBLIC repo (`web-to-apk-updates`)
3. ✅ `version.json` updated with new version + public download URL
4. ✅ App will show update dialog to all users on next launch

---

### Method 2: Git Tag Push

```bash
git tag v1.0.1
git push origin v1.0.1
```

This automatically triggers the build workflow.

---

## 🔧 How to Update App Content/Customization

### Updating config (no code change needed):

1. Edit `lib/config/app_config.dart`
2. Change what you need (URL, theme, dialogs, etc.)
3. Commit and push:
   ```bash
   git add lib/config/app_config.dart
   git commit -m "config: update website URL and theme"
   git push
   ```
4. Run GitHub Actions to build new APK

---

## 📝 How to Update version.json Manually

If you need to manually update the version.json (e.g., to change download URL):

1. Go to `github.com/JubairZ/wtapk-up`
2. Edit `version.json` directly on GitHub
3. Update the values:

```json
{
  "version": "1.0.1",
  "versionCode": 2,
  "downloadUrl": "https://github.com/JubairZ/wtapk-up/releases/download/v1.0.1/web-to-apk-v1.0.1.apk",
  "changelog": "Bug fixes and improvements.",
  "forceUpdate": false,
  "releaseDate": "2026-05-13T00:00:00Z",
  "poweredBy": "Jubair Sensei",
  "github": "https://github.com/jubairbro",
  "youtube": "https://youtube.com/@jubairsensei",
  "telegram": "https://t.me/JubairSensei"
}
```

> ⚠️ `versionCode` must be **greater** than the value in `AppConfig.appVersionCode` for the update dialog to appear.

---

## 🎨 How to Add a New Theme

1. Open `lib/themes/app_theme.dart`
2. Add your theme to the `ThemeTemplate` enum:
   ```dart
   enum ThemeTemplate {
     ...
     myNewTheme,  // Add here
   }
   ```
3. Add a `_ThemePalette` entry in the `_palettes` map:
   ```dart
   ThemeTemplate.myNewTheme: _ThemePalette(
     primary: Color(0xFFYOUR_COLOR),
     secondary: Color(0xFFYOUR_ACCENT),
     background: Color(0xFF000000),
     surface: Color(0xFF111111),
     toolbar: Color(0xFF111111),
     toolbarText: Colors.white,
     textPrimary: Colors.white,
     textSecondary: Color(0xFF888888),
     isDark: true,
   ),
   ```
4. Set in `app_config.dart`:
   ```dart
   static const ThemeTemplate themeTemplate = ThemeTemplate.myNewTheme;
   ```

---

## 🔔 How to Update the App Icon

1. Create a 512×512 PNG image
2. Replace `assets/icon/icon.png`
3. Also replace `assets/icon/icon_fg.png` (adaptive icon foreground)
4. Run:
   ```bash
   flutter pub run flutter_launcher_icons
   ```
5. Build new APK

---

## 📱 How to Change Package Name

1. Update `app_config.dart`:
   ```dart
   static const String packageName = 'com.yourcompany.yourapp';
   ```
2. Update `android/app/build.gradle`:
   ```groovy
   namespace "com.yourcompany.yourapp"
   defaultConfig {
     applicationId "com.yourcompany.yourapp"
   }
   ```
3. Update `AndroidManifest.xml` if needed
4. Build new APK

> ⚠️ If you already published to Play Store, changing the package name creates a NEW app listing.

---

## 🗑️ How to Force Users to Update

In `app_config.dart`:
```dart
static const bool enableAutoUpdate = true;
```

In version.json:
```json
{
  "forceUpdate": true
}
```

Or when running GitHub Actions, set `force_update` input to `true`.

---

## 🛡️ How to Set App Expiry

In `app_config.dart`:
```dart
static const bool enableExpiry = true;
static final DateTime expiryDate = DateTime(2027, 12, 31);
static const bool expiryBlockApp = true;  // true = can't use app after expiry
static const String expiryContactUrl = 'https://t.me/YourContact';
```

---

## 🔑 How to Set Up Keystore Signing

1. Generate keystore:
   ```bash
   keytool -genkey -v -keystore release.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias my-key-alias
   ```
2. Convert to base64:
   ```bash
   base64 release.jks  # Output this value
   ```
3. Add GitHub secrets:
   - `KEYSTORE_BASE64` = base64 output
   - `KEYSTORE_PASSWORD` = your keystore password
   - `KEY_ALIAS` = my-key-alias
   - `KEY_PASSWORD` = your key password

> 🔒 Keep your keystore file SAFE. If you lose it, you cannot update your app on Play Store.
