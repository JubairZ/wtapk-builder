# Flutter core
  -keep class io.flutter.** { *; }
  -keep class io.flutter.plugins.** { *; }
  -keep class io.flutter.embedding.** { *; }
  -dontwarn io.flutter.embedding.**
  -keepattributes Signature
  -keepattributes *Annotation*
  -keepattributes EnclosingMethod
  -keepattributes InnerClasses

  # AndroidX
  -keep class androidx.** { *; }
  -dontwarn androidx.**

  # Google Play / Core
  -dontwarn com.google.android.play.core.**
  -keep class com.google.android.play.core.** { *; }
  -keep class com.google.android.gms.** { *; }

  # Multidex
  -keep class androidx.multidex.** { *; }

  # WebView / webview_flutter
  -keep class android.webkit.** { *; }
  -keep class io.flutter.plugins.webviewflutter.** { *; }

  # permission_handler
  -keep class com.baseflow.permissionhandler.** { *; }

  # local_auth (biometric)
  -keep class io.flutter.plugins.localauth.** { *; }
  -keep class androidx.biometric.** { *; }
  -keep class androidx.fragment.** { *; }

  # flutter_downloader
  -keep class vn.hunghd.flutterdownloader.** { *; }
  -keep class vn.hunghd.** { *; }

  # connectivity_plus / package_info_plus / shared_preferences / url_launcher / share_plus
  -keep class dev.fluttercommunity.plus.** { *; }
  -keep class io.flutter.plugins.sharedpreferences.** { *; }
  -keep class io.flutter.plugins.urllauncher.** { *; }

  # FileProvider
  -keep class androidx.core.content.FileProvider { *; }

  # Kotlin
  -keep class kotlin.** { *; }
  -keep class kotlinx.** { *; }
  -dontwarn kotlin.**
  