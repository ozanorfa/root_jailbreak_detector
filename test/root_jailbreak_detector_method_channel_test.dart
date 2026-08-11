import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('root_jailbreak_detector');
  final platform = MethodChannelRootJailbreakDetector();

  TestDefaultBinaryMessenger messenger() =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  /// Answers the channel with [handler], as the native side would.
  void mockNativeSide(Object? Function(MethodCall call) handler) {
    messenger().setMockMethodCallHandler(
      channel,
      (call) async => handler(call),
    );
  }

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    messenger().setMockMethodCallHandler(channel, null);
  });

  test('invokes isDeviceCompromised on the channel', () async {
    final calls = <MethodCall>[];
    mockNativeSide((call) {
      calls.add(call);
      return false;
    });

    await platform.isDeviceCompromised();

    expect(calls.single.method, 'isDeviceCompromised');
  });

  test('passes the native result through', () async {
    mockNativeSide((_) => true);
    expect(await platform.isDeviceCompromised(), isTrue);

    mockNativeSide((_) => false);
    expect(await platform.isDeviceCompromised(), isFalse);
  });

  test('throws instead of reporting a clean device when the result is null',
      () async {
    mockNativeSide((_) => null);

    await expectLater(
      platform.isDeviceCompromised(),
      throwsA(
        isA<RootJailbreakDetectorException>()
            .having((e) => e.code, 'code', 'null-result'),
      ),
    );
  });

  test('wraps a PlatformException from the native side', () async {
    mockNativeSide(
      (_) => throw PlatformException(code: 'check-failed', message: 'boom'),
    );

    await expectLater(
      platform.isDeviceCompromised(),
      throwsA(
        isA<RootJailbreakDetectorException>()
            .having((e) => e.code, 'code', 'check-failed')
            .having((e) => e.message, 'message', 'boom')
            .having((e) => e.cause, 'cause', isA<PlatformException>()),
      ),
    );
  });

  test('wraps a missing native implementation', () async {
    // No mock handler registered, which is what an unregistered plugin looks
    // like from Dart.
    await expectLater(
      platform.isDeviceCompromised(),
      throwsA(
        isA<RootJailbreakDetectorException>()
            .having((e) => e.code, 'code', 'missing-plugin'),
      ),
    );
  });

  group('unsupported platforms', () {
    test('report as unsupported and never reach the channel', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      var reached = false;
      mockNativeSide((_) {
        reached = true;
        return true;
      });

      expect(platform.isSupported, isFalse);
      expect(await platform.isDeviceCompromised(), isFalse);
      expect(reached, isFalse);
    });

    test('treat android and iOS as supported', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(platform.isSupported, isTrue);

      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(platform.isSupported, isTrue);
    });
  });
}
