package com.ozanorfa.rootjailbreakdetector.root_jailbreak_detector

import androidx.annotation.NonNull
import com.scottyab.rootbeer.RootBeer
import android.content.Context

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** RootJailbreakDetectorPlugin */
class RootJailbreakDetectorPlugin: FlutterPlugin, MethodCallHandler {

  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "root_jailbreak_detector")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getRoot") {
      result.success(isDeviceRooted())
    } else {
      result.success(false)
    }
  }

  private fun isDeviceRooted(): Boolean {

    val rootBeer = RootBeer(context)

    return rootBeer.isRooted
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
