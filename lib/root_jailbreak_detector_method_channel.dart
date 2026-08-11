import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'root_jailbreak_detector_platform_interface.dart';
import 'src/root_jailbreak_detector_exception.dart';

/// An implementation of [RootJailbreakDetectorPlatform] that uses method
/// channels to reach the Android and iOS native checks.
class MethodChannelRootJailbreakDetector extends RootJailbreakDetectorPlatform {
  /// The method channel used to talk to the native side.
  @visibleForTesting
  final methodChannel = const MethodChannel('root_jailbreak_detector');

  @override
  bool get isSupported {
    // `defaultTargetPlatform` reports android/iOS for mobile browsers too, so
    // the web check has to come first. It is also overridable in tests, unlike
    // `dart:io`'s `Platform`, and it keeps this file safe to compile for web.
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  Future<bool> isDeviceCompromised({bool treatEmulatorAsCompromised = true}) async {
    if (!isSupported) return false;

    try {
      final compromised = await methodChannel.invokeMethod<bool>(
        'isDeviceCompromised',
        <String, Object?>{
          'treatEmulatorAsCompromised': treatEmulatorAsCompromised,
        },
      );
      if (compromised == null) {
        throw const RootJailbreakDetectorException(
          'The native side returned no result.',
          code: 'null-result',
        );
      }
      return compromised;
    } on MissingPluginException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        RootJailbreakDetectorException(
          'The native implementation is not registered. A full app restart is '
          'usually needed after adding the plugin.',
          code: 'missing-plugin',
          cause: error,
        ),
        stackTrace,
      );
    } on PlatformException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        RootJailbreakDetectorException(
          error.message ?? 'The native check failed.',
          code: error.code,
          cause: error,
        ),
        stackTrace,
      );
    }
  }
}
