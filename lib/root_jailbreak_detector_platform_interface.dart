import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'root_jailbreak_detector_method_channel.dart';
import 'src/root_jailbreak_detector_exception.dart';

/// The interface that implementations of `root_jailbreak_detector` must extend.
///
/// Platform implementations should extend this class rather than implement it.
/// Extending ensures that new members added here do not silently break existing
/// implementations — they inherit a default instead.
abstract class RootJailbreakDetectorPlatform extends PlatformInterface {
  /// Constructs a [RootJailbreakDetectorPlatform].
  RootJailbreakDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static RootJailbreakDetectorPlatform _instance =
      MethodChannelRootJailbreakDetector();

  /// The default instance to use.
  static RootJailbreakDetectorPlatform get instance => _instance;

  /// Sets the instance, for use by platform implementations and tests.
  static set instance(RootJailbreakDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Whether this implementation can actually inspect the current device.
  ///
  /// Returns `false` on platforms where the concept does not apply (web and
  /// desktop), which lets callers tell "checked and clean" apart from
  /// "never checked".
  bool get isSupported => false;

  /// Whether the device shows signs of being rooted or jailbroken.
  ///
  /// When [treatEmulatorAsCompromised] is `false`, an implementation that can
  /// recognise a simulator or emulator should report it as clean.
  ///
  /// Implementations must throw a [RootJailbreakDetectorException] when the
  /// check cannot be completed. Returning `false` on failure would report a
  /// possibly compromised device as safe.
  Future<bool> isDeviceCompromised({bool treatEmulatorAsCompromised = true}) {
    throw UnimplementedError('isDeviceCompromised() has not been implemented.');
  }
}
