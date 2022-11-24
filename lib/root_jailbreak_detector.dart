import 'dart:ffi';

import 'root_jailbreak_detector_platform_interface.dart';

class RootJailbreakDetector {
  Future<Bool?> isRootedOrJailbreaked() {
    return RootJailbreakDetectorPlatform.instance.isRootedOrJailbreaked();
  }
}
