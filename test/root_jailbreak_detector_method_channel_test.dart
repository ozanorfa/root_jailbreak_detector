import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector_method_channel.dart';

void main() {
  MethodChannelRootJailbreakDetector platform =
      MethodChannelRootJailbreakDetector();
  const MethodChannel channel = MethodChannel('root_jailbreak_detector');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return false;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getRoot', () async {
    expect(await platform.isRootedOrJailbreaked(), false);
  });

  test('getJailbreak', () async {
    expect(await platform.isRootedOrJailbreaked(), false);
  });
}
