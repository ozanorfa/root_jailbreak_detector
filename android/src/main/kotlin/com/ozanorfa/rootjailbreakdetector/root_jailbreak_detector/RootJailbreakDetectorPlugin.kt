package com.ozanorfa.rootjailbreakdetector.root_jailbreak_detector

import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import com.scottyab.rootbeer.RootBeer
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors
import java.util.concurrent.RejectedExecutionException

/** Answers root detection queries from the Dart side using RootBeer. */
class RootJailbreakDetectorPlugin : FlutterPlugin, MethodCallHandler {

    private var channel: MethodChannel? = null
    private var context: Context? = null
    private var executor: ExecutorService? = null

    // Only ever touched from the platform thread: the engine callbacks and the
    // posted replies below all run there, so no synchronisation is needed.
    private var attached = false

    // Created lazily so that constructing the plugin does not touch the Android
    // framework — that keeps it usable from plain JVM unit tests.
    private val mainHandler by lazy { Handler(Looper.getMainLooper()) }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        executor = Executors.newSingleThreadExecutor()
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME).apply {
            setMethodCallHandler(this@RootJailbreakDetectorPlugin)
        }
        attached = true
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            METHOD_IS_DEVICE_COMPROMISED -> detectRoot(
                result,
                // Absent or malformed arguments fall back to the stricter answer.
                treatEmulatorAsCompromised = call.argument<Boolean>(ARG_TREAT_EMULATOR) ?: true,
            )
            // Anything else is a bug on the Dart side. Reporting `false` here
            // would look exactly like "this device is clean".
            else -> result.notImplemented()
        }
    }

    /**
     * RootBeer touches the file system and shells out looking for `su`, so it
     * must not run on the platform thread.
     */
    private fun detectRoot(result: Result, treatEmulatorAsCompromised: Boolean) {
        val executor = this.executor
        val context = this.context
        if (executor == null || context == null) {
            result.error(ERROR_UNAVAILABLE, "Plugin is not attached to a Flutter engine.", null)
            return
        }

        try {
            executor.execute {
                val outcome = runCatching {
                    // RootBeer rightly reports an emulator as rooted, so the
                    // opt-out has to be applied before asking it.
                    if (!treatEmulatorAsCompromised && isProbablyEmulator()) {
                        false
                    } else {
                        RootBeer(context).isRooted
                    }
                }
                mainHandler.post {
                    // A scan already in flight when the engine detaches would
                    // otherwise reply on a channel that no longer exists.
                    if (!attached) return@post
                    outcome.fold(
                        onSuccess = { result.success(it) },
                        onFailure = {
                            result.error(
                                ERROR_CHECK_FAILED,
                                it.message ?: "The root check failed.",
                                it.stackTraceToString(),
                            )
                        },
                    )
                }
            }
        } catch (e: RejectedExecutionException) {
            result.error(ERROR_UNAVAILABLE, "Plugin is shutting down.", e.message)
        }
    }

    /**
     * Best-effort emulator recognition, consulted only to honour
     * `treatEmulatorAsCompromised = false`.
     *
     * These are `Build` properties, which a rooted device can forge — which is
     * exactly why the exemption is opt-in rather than the default.
     */
    private fun isProbablyEmulator(): Boolean =
        Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.startsWith("unknown") ||
            Build.FINGERPRINT.contains("emulator", ignoreCase = true) ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for") ||
            Build.MANUFACTURER.contains("Genymotion") ||
            (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
            Build.PRODUCT == "google_sdk" ||
            Build.PRODUCT.startsWith("sdk_gphone") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.HARDWARE.contains("ranchu")

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        attached = false
        channel?.setMethodCallHandler(null)
        channel = null
        context = null
        // shutdownNow rather than shutdown: a queued scan has nowhere to
        // report back to now, so there is no reason to let it run.
        executor?.shutdownNow()
        executor = null
    }

    private companion object {
        const val CHANNEL_NAME = "root_jailbreak_detector"
        const val METHOD_IS_DEVICE_COMPROMISED = "isDeviceCompromised"
        const val ARG_TREAT_EMULATOR = "treatEmulatorAsCompromised"
        const val ERROR_UNAVAILABLE = "unavailable"
        const val ERROR_CHECK_FAILED = "check-failed"
    }
}
