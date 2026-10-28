package com.sevensoft.device_security

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File
import java.util.concurrent.Executors

class DeviceSecurityPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "device_security")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        executor.shutdown()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        // Root checks hit the filesystem and may spawn a process; keep them off the main thread.
        executor.execute {
            val outcome: Any? = try {
                when (call.method) {
                    "isRooted" -> RootDetector.isRooted(context)
                    "isEmulator" -> EmulatorDetector.isEmulator()
                    "isUsbDebugging" -> isUsbDebugging()
                    "isDeveloperOptions" -> isDeveloperOptions()
                    "check" -> mapOf(
                        "isRooted" to RootDetector.isRooted(context),
                        "isEmulator" to EmulatorDetector.isEmulator(),
                        "isUsbDebugging" to isUsbDebugging(),
                        "isDeveloperOptions" to isDeveloperOptions(),
                    )
                    else -> NotImplemented
                }
            } catch (e: Exception) {
                e
            }
            mainHandler.post {
                when (outcome) {
                    NotImplemented -> result.notImplemented()
                    is Exception -> result.error("DEVICE_SECURITY", outcome.message, null)
                    else -> result.success(outcome)
                }
            }
        }
    }

    private object NotImplemented

    private fun isUsbDebugging(): Boolean =
        Settings.Global.getInt(context.contentResolver, Settings.Global.ADB_ENABLED, 0) == 1

    private fun isDeveloperOptions(): Boolean =
        Settings.Global.getInt(
            context.contentResolver, Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0
        ) == 1
}

internal object RootDetector {
    fun isRooted(context: Context): Boolean =
        hasTestKeys() || hasSuBinary() || hasRootPaths() || hasRootApps(context) || canRunSu()

    private fun hasTestKeys(): Boolean = Build.TAGS?.contains("test-keys") == true

    private val suPaths = listOf(
        "/system/app/Superuser.apk",
        "/sbin/su", "/system/bin/su", "/system/xbin/su", "/system/sd/xbin/su",
        "/system/bin/failsafe/su", "/data/local/xbin/su", "/data/local/bin/su",
        "/data/local/su", "/su/bin/su", "/su/bin", "/system/xbin/daemonsu",
        "/system/etc/init.d/99SuperSUDaemon", "/system/xbin/busybox",
    )

    private val rootPaths = listOf(
        "/sbin/.magisk", "/data/adb/magisk", "/data/adb/modules", "/data/adb/ksu",
        "/data/adb/ap", "/cache/.disable_magisk", "/dev/.magisk.unblock",
        "/system/lib/libxposed_art.so", "/system/lib64/libxposed_art.so",
    )

    private fun hasSuBinary(): Boolean = suPaths.any { File(it).exists() }

    private fun hasRootPaths(): Boolean = rootPaths.any { File(it).exists() }

    private val rootApps = listOf(
        "com.topjohnwu.magisk", "eu.chainfire.supersu", "com.noshufou.android.su",
        "com.koushikdutta.superuser", "com.thirdparty.superuser", "com.kingroot.kinguser",
        "me.phh.superuser", "com.zachspong.temprootremovejb", "io.github.huskydg.magisk",
        "me.weishu.kernelsu", "com.rifsxd.ksunext", "de.robv.android.xposed.installer",
        "org.lsposed.manager",
    )

    private fun hasRootApps(context: Context): Boolean {
        val pm = context.packageManager
        return rootApps.any {
            try {
                pm.getPackageInfo(it, 0)
                true
            } catch (e: Exception) {
                false
            }
        }
    }

    private fun canRunSu(): Boolean {
        var process: Process? = null
        return try {
            process = Runtime.getRuntime().exec(arrayOf("/system/xbin/which", "su"))
            process.inputStream.bufferedReader().readLine() != null
        } catch (e: Exception) {
            false
        } finally {
            process?.destroy()
        }
    }
}

internal object EmulatorDetector {
    fun isEmulator(): Boolean {
        val fp = Build.FINGERPRINT.lowercase()
        val model = Build.MODEL.lowercase()
        val product = Build.PRODUCT.lowercase()
        val hw = Build.HARDWARE.lowercase()
        val brand = Build.BRAND.lowercase()
        val device = Build.DEVICE.lowercase()
        val manufacturer = Build.MANUFACTURER.lowercase()
        val board = Build.BOARD.lowercase()

        return fp.startsWith("generic") || fp.startsWith("unknown") || fp.contains("emulator")
            || model.contains("google_sdk") || model.contains("emulator")
            || model.contains("android sdk built for") || model.contains("sdk_gphone")
            || manufacturer.contains("genymotion")
            || hw.contains("goldfish") || hw.contains("ranchu") || hw.contains("vbox86")
            || product.contains("sdk") || product.contains("emulator") || product.contains("simulator")
            || product.contains("vbox86p") || product.contains("google_sdk")
            || board.contains("nox") || board.contains("goldfish")
            || (brand.startsWith("generic") && device.startsWith("generic"))
            || device.contains("generic_x86") || device.contains("vbox86p")
            || File("/dev/socket/qemud").exists() || File("/dev/qemu_pipe").exists()
            || File("/system/lib/libc_malloc_debug_qemu.so").exists()
            || File("/system/bin/nox-prop").exists() || File("/system/bin/ldinit").exists()
            || File("/system/bin/microvirtd").exists()
    }
}
