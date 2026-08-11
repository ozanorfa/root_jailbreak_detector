/// Detects whether the current device is rooted (Android) or jailbroken (iOS).
///
/// ```dart
/// const detector = RootJailbreakDetector();
///
/// // Treat an unknown result as compromised.
/// if (await detector.isCompromisedOrElse(true)) {
///   // Degrade the experience, warn the user, or report to your backend.
/// }
/// ```
///
/// These checks are a signal, not a barrier — see the package README for what
/// they can and cannot guarantee.
library;

import 'package:flutter/foundation.dart';

import 'root_jailbreak_detector_platform_interface.dart';
import 'src/root_jailbreak_detector_exception.dart';

export 'src/root_jailbreak_detector_exception.dart';

/// Entry point for root and jailbreak detection.
class RootJailbreakDetector {
  /// Creates a detector. The class holds no state, so a `const` instance is
  /// fine to share across your app.
  const RootJailbreakDetector({this.treatEmulatorAsCompromised = true});

  /// Whether the iOS simulator and Android emulators count as compromised.
  ///
  /// Defaults to `true`. An emulated environment runs on a writable filesystem,
  /// usually under a debugger, and offers none of the guarantees these checks
  /// exist to verify — so the honest answer is that its integrity cannot be
  /// vouched for.
  ///
  /// The cost is that your own team sees a positive result while developing —
  /// always on the iOS simulator, and on Android whenever RootBeer flags the
  /// system image (test-keys builds do, "Google Play" images usually do not).
  /// Pass `false` to opt out of that.
  ///
  /// Weigh it first: on Android the exemption rests on `Build` properties,
  /// which a rooted device can forge, so `false` also hands a real attacker a
  /// way to look like an emulator and skip the check entirely. If you only want
  /// your development builds unblocked, prefer leaving this alone and skipping
  /// the call instead:
  ///
  /// ```dart
  /// final flagged = kDebugMode ? false : await detector.isCompromisedOrElse(true);
  /// ```
  final bool treatEmulatorAsCompromised;

  static RootJailbreakDetectorPlatform get _platform =>
      RootJailbreakDetectorPlatform.instance;

  /// Whether detection is available on the current platform.
  ///
  /// `true` on Android and iOS, `false` everywhere else. Use it to tell
  /// "checked and clean" apart from "never checked" — [isCompromised] returns
  /// `false` on unsupported platforms, because there is no root or jailbreak
  /// concept there to report on.
  bool get isSupported => _platform.isSupported;

  /// Whether the device shows signs of being rooted or jailbroken.
  ///
  /// Returns `false` on platforms other than Android and iOS.
  ///
  /// Throws a [RootJailbreakDetectorException] when the check cannot be
  /// completed on a supported platform. That is deliberate: a failed check
  /// means the device integrity is *unknown*, and reporting unknown as safe is
  /// how a security control quietly stops working. If you would rather pick a
  /// default than handle the error, use [isCompromisedOrElse].
  ///
  /// The error always arrives as a failed future, never as a synchronous throw.
  // Hence `async`: it converts a platform implementation that throws
  // synchronously — as the unimplemented base class does — into a failed
  // future, so `catchError` callers see it too.
  Future<bool> isCompromised() async => _platform.isDeviceCompromised(
        treatEmulatorAsCompromised: treatEmulatorAsCompromised,
      );

  /// Like [isCompromised], but returns [fallback] instead of throwing when the
  /// check cannot be completed.
  ///
  /// Pass `true` to fail closed (treat an unknown device as compromised) or
  /// `false` to fail open. There is no default — which one is right depends on
  /// what your app does when it sees `true`.
  Future<bool> isCompromisedOrElse(bool fallback) async {
    try {
      return await isCompromised();
    } catch (_) {
      // Deliberately catches everything. This method promises never to throw,
      // and narrowing it to RootJailbreakDetectorException would let other
      // failures past that promise — a platform implementation that reports
      // `isSupported` but leaves `isDeviceCompromised()` unimplemented throws
      // an UnimplementedError, not ours.
      return fallback;
    }
  }

  /// Whether an Android device is rooted.
  ///
  /// Always returns `false` on other platforms, which means forgetting a
  /// platform guard silently reports every iOS device as safe.
  @Deprecated(
    'Use isCompromised() or isCompromisedOrElse(), which cover both platforms. '
    'This will be removed in 2.0.0.',
  )
  Future<bool> isRooted() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    return isCompromisedOrElse(false);
  }

  /// Whether an iOS device is jailbroken.
  ///
  /// Always returns `false` on other platforms, which means forgetting a
  /// platform guard silently reports every Android device as safe.
  @Deprecated(
    'Use isCompromised() or isCompromisedOrElse(), which cover both platforms. '
    'This will be removed in 2.0.0.',
  )
  Future<bool> isJailbreaked() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return false;
    return isCompromisedOrElse(false);
  }
}
