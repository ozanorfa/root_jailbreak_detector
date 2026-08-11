import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector_method_channel.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector_platform_interface.dart';

/// A platform implementation whose answer the test controls.
class _FakeDetectorPlatform extends RootJailbreakDetectorPlatform {
  _FakeDetectorPlatform.answers(bool result)
      : _result = result,
        _error = null;

  _FakeDetectorPlatform.fails()
      : _result = null,
        _error = const RootJailbreakDetectorException(
          'the check could not run',
          code: 'test',
        );

  final bool? _result;
  final RootJailbreakDetectorException? _error;

  @override
  bool get isSupported => true;

  @override
  Future<bool> isDeviceCompromised() async {
    final error = _error;
    if (error != null) throw error;
    return _result!;
  }
}

/// Claims to support the current platform but never implements the check —
/// the shape of a half-finished platform implementation, which reaches the
/// `UnimplementedError` on the base class.
class _UnimplementedPlatform extends RootJailbreakDetectorPlatform {
  @override
  bool get isSupported => true;
}

void main() {
  const detector = RootJailbreakDetector();
  final initialPlatform = RootJailbreakDetectorPlatform.instance;

  tearDown(() {
    RootJailbreakDetectorPlatform.instance = initialPlatform;
    debugDefaultTargetPlatformOverride = null;
  });

  test('defaults to the method channel implementation', () {
    expect(initialPlatform, isA<MethodChannelRootJailbreakDetector>());
  });

  group('isCompromised', () {
    test('reports a compromised device', () async {
      RootJailbreakDetectorPlatform.instance =
          _FakeDetectorPlatform.answers(true);
      expect(await detector.isCompromised(), isTrue);
    });

    test('reports a clean device', () async {
      RootJailbreakDetectorPlatform.instance =
          _FakeDetectorPlatform.answers(false);
      expect(await detector.isCompromised(), isFalse);
    });

    test('rethrows so a failed check is never mistaken for a clean device',
        () async {
      RootJailbreakDetectorPlatform.instance = _FakeDetectorPlatform.fails();

      await expectLater(
        detector.isCompromised(),
        throwsA(isA<RootJailbreakDetectorException>()),
      );
    });
  });

  group('isCompromisedOrElse', () {
    test('returns the real answer when the check succeeds', () async {
      RootJailbreakDetectorPlatform.instance =
          _FakeDetectorPlatform.answers(true);
      expect(await detector.isCompromisedOrElse(false), isTrue);
    });

    test('fails closed when asked to', () async {
      RootJailbreakDetectorPlatform.instance = _FakeDetectorPlatform.fails();
      expect(await detector.isCompromisedOrElse(true), isTrue);
    });

    test('fails open when asked to', () async {
      RootJailbreakDetectorPlatform.instance = _FakeDetectorPlatform.fails();
      expect(await detector.isCompromisedOrElse(false), isFalse);
    });

    test('holds its never-throws promise against any error, not just ours',
        () async {
      // This platform throws UnimplementedError from the base class rather
      // than a RootJailbreakDetectorException.
      RootJailbreakDetectorPlatform.instance = _UnimplementedPlatform();

      expect(await detector.isCompromisedOrElse(true), isTrue);
      expect(await detector.isCompromisedOrElse(false), isFalse);
    });
  });

  test('isCompromised reports an unimplemented platform as a failed future',
      () async {
    // The strict entry point stays loud: only isCompromisedOrElse absorbs this.
    // It must arrive as a failed future rather than a synchronous throw, or
    // `catchError` callers would miss it.
    RootJailbreakDetectorPlatform.instance = _UnimplementedPlatform();

    await expectLater(
      detector.isCompromised(),
      throwsA(isA<UnimplementedError>()),
    );
  });

  group('deprecated platform-specific API', () {
    test('isRooted answers on android and stays silent elsewhere', () async {
      RootJailbreakDetectorPlatform.instance =
          _FakeDetectorPlatform.answers(true);

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // ignore: deprecated_member_use_from_same_package
      expect(await detector.isRooted(), isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      // This `false` on a compromised device is exactly why the method is
      // deprecated: it reads as "clean" on the wrong platform.
      // ignore: deprecated_member_use_from_same_package
      expect(await detector.isRooted(), isFalse);
    });

    test('isJailbreaked answers on iOS and stays silent elsewhere', () async {
      RootJailbreakDetectorPlatform.instance =
          _FakeDetectorPlatform.answers(true);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      // ignore: deprecated_member_use_from_same_package
      expect(await detector.isJailbreaked(), isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      // ignore: deprecated_member_use_from_same_package
      expect(await detector.isJailbreaked(), isFalse);
    });

    test('never throws, preserving the pre-1.0 contract', () async {
      RootJailbreakDetectorPlatform.instance = _FakeDetectorPlatform.fails();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      // ignore: deprecated_member_use_from_same_package
      expect(await detector.isRooted(), isFalse);
    });

    test('holds that contract for an unimplemented platform too', () async {
      RootJailbreakDetectorPlatform.instance = _UnimplementedPlatform();
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      // ignore: deprecated_member_use_from_same_package
      expect(await detector.isRooted(), isFalse);
    });
  });
}
