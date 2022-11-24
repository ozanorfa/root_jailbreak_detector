import 'dart:ffi';

import 'package:flutter_test/flutter_test.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector_platform_interface.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockRootJailbreakDetectorPlatform
    with MockPlatformInterfaceMixin
    implements RootJailbreakDetectorPlatform {
  @override
  Future<Bool?> isJailbreaked() {
    //return Future.value(false);
    return Future.value(null);
  }

  @override
  Future<Bool?> isRooted() {
    //return Future.value(false);
    return Future.value(null);
  }
}

void main() {
  final RootJailbreakDetectorPlatform initialPlatform =
      RootJailbreakDetectorPlatform.instance;

  test('$MethodChannelRootJailbreakDetector is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelRootJailbreakDetector>());
  });

  test('getRoot', () async {
    RootJailbreakDetector rootJailbreakDetectorPlugin = RootJailbreakDetector();
    MockRootJailbreakDetectorPlatform fakePlatform =
        MockRootJailbreakDetectorPlatform();
    RootJailbreakDetectorPlatform.instance = fakePlatform;

    expect(await rootJailbreakDetectorPlugin.isRooted(), false);
  });

  test('getJailbreak', () async {
    RootJailbreakDetector rootJailbreakDetectorPlugin = RootJailbreakDetector();
    MockRootJailbreakDetectorPlatform fakePlatform =
        MockRootJailbreakDetectorPlatform();
    RootJailbreakDetectorPlatform.instance = fakePlatform;

    expect(await rootJailbreakDetectorPlugin.isJailbreaked(), false);
  });
}
