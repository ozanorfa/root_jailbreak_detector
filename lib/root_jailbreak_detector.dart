import 'dart:ffi';

import 'root_jailbreak_detector_platform_interface.dart';

class RootJailbreakDetector {
  Future<Bool?> isRooted() {
    return RootJailbreakDetectorPlatform.instance.isRooted();
  }

  Future<Bool?> isJailbreaked() {
    return RootJailbreakDetectorPlatform.instance.isJailbreaked();
  }
}
