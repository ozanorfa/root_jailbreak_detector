import 'dart:ffi';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'root_jailbreak_detector_method_channel.dart';

abstract class RootJailbreakDetectorPlatform extends PlatformInterface {
  RootJailbreakDetectorPlatform() : super(token: _token);

  static final Object _token = Object();

  static RootJailbreakDetectorPlatform _instance =
      MethodChannelRootJailbreakDetector();

  static RootJailbreakDetectorPlatform get instance => _instance;

  static set instance(RootJailbreakDetectorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<Bool?> isRootedOrJailbreaked() {
    throw UnimplementedError(
        'Root or Jailbreak detector has not been implemented.');
  }
}
