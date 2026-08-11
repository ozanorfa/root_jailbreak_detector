package com.ozanorfa.rootjailbreakdetector.root_jailbreak_detector

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.ArgumentMatchers.anyString
import org.mockito.ArgumentMatchers.eq
import org.mockito.Mockito
import kotlin.test.Test

/*
 * Unit tests for the Kotlin side of the plugin.
 *
 * Once you have built the example app — which generates the Gradle wrapper, as
 * it is not checked in — run these with
 * `./gradlew :root_jailbreak_detector:testDebugUnitTest` from `example/android/`,
 * or straight from Android Studio.
 */
internal class RootJailbreakDetectorPluginTest {

    @Test
    fun onMethodCall_unknownMethod_reportsNotImplemented() {
        val plugin = RootJailbreakDetectorPlugin()
        val result = Mockito.mock(MethodChannel.Result::class.java)

        plugin.onMethodCall(MethodCall("getRoot", null), result)

        // A removed or misspelled method must not be answered with `false`,
        // which the Dart side would read as "this device is clean".
        Mockito.verify(result).notImplemented()
        Mockito.verify(result, Mockito.never()).success(Mockito.any())
    }

    @Test
    fun onMethodCall_whenDetached_reportsErrorRatherThanFalse() {
        val plugin = RootJailbreakDetectorPlugin()
        val result = Mockito.mock(MethodChannel.Result::class.java)

        // The plugin was never attached to an engine, so no check can run.
        plugin.onMethodCall(MethodCall("isDeviceCompromised", null), result)

        Mockito.verify(result).error(eq("unavailable"), anyString(), Mockito.isNull())
        Mockito.verify(result, Mockito.never()).success(Mockito.any())
    }
}
