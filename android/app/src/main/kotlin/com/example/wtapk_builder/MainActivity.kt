package com.example.wtapk_builder

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.android.apksig.ApkSigner
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import java.util.zip.ZipOutputStream
import java.nio.charset.StandardCharsets
import java.security.KeyStore
import java.security.PrivateKey
import java.security.cert.X509Certificate

class MainActivity: FlutterActivity() {
    private val CHANNEL = "bd.bro.jubair/apk_builder"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "buildApk") {
                val baseApkPath = call.argument<String>("baseApkPath")!!
                val outputPath = call.argument<String>("outputPath")!!
                val keystorePath = call.argument<String>("keystorePath")!!
                val keyPassword = call.argument<String>("keyPassword")!!
                val alias = call.argument<String>("alias")!!
                val aliasPassword = call.argument<String>("aliasPassword")!!
                val jsonConfigData = call.argument<String>("jsonConfigData")!!

                Thread {
                    try {
                        // 1. Unsigned modified APK path
                        val unsignedApk = File(context.cacheDir, "unsigned.apk")
                        
                        // 2. Patch the APK
                        patchApk(baseApkPath, unsignedApk.absolutePath, jsonConfigData)
                        
                        // 3. Sign the APK
                        signApk(unsignedApk.absolutePath, outputPath, keystorePath, keyPassword, alias, aliasPassword)
                        
                        // 4. Cleanup
                        unsignedApk.delete()
                        
                        runOnUiThread {
                            result.success(true)
                        }
                    } catch (e: Exception) {
                        e.printStackTrace()
                        runOnUiThread {
                            result.error("BUILD_FAILED", e.message, null)
                        }
                    }
                }.start()
            } else {
                result.notImplemented()
            }
        }
    }

    private fun patchApk(inputPath: String, outputPath: String, jsonConfigData: String) {
        val zin = ZipInputStream(FileInputStream(inputPath))
        val zout = ZipOutputStream(FileOutputStream(outputPath))
        
        var entry = zin.nextEntry
        while (entry != null) {
            // Skip existing signature files
            if (entry.name.startsWith("META-INF/")) {
                entry = zin.nextEntry
                continue
            }
            
            val newEntry = ZipEntry(entry.name)
            zout.putNextEntry(newEntry)
            
            if (entry.name == "assets/flutter_assets/assets/config.json") {
                // Inject our custom config
                zout.write(jsonConfigData.toByteArray(StandardCharsets.UTF_8))
            } else {
                // Copy original
                val buffer = ByteArray(4096)
                var len: Int
                while (zin.read(buffer).also { len = it } > 0) {
                    zout.write(buffer, 0, len)
                }
            }
            zout.closeEntry()
            zin.closeEntry()
            entry = zin.nextEntry
        }
        zin.close()
        zout.close()
    }

    private fun signApk(inputPath: String, outputPath: String, keystorePath: String, keyPass: String, alias: String, aliasPass: String) {
        val ks = KeyStore.getInstance("JKS")
        FileInputStream(keystorePath).use { ks.load(it, keyPass.toCharArray()) }
        
        val privateKey = ks.getKey(alias, aliasPass.toCharArray()) as PrivateKey
        val cert = ks.getCertificate(alias) as X509Certificate
        
        val signerConfig = ApkSigner.SignerConfig.Builder("signer", privateKey, listOf(cert)).build()
        
        val signer = ApkSigner.Builder(listOf(signerConfig))
            .setInputApk(File(inputPath))
            .setOutputApk(File(outputPath))
            .setV1SigningEnabled(true)
            .setV2SigningEnabled(true)
            .setV3SigningEnabled(true)
            .build()
            
        signer.sign()
    }
}
