import 'root_jailbreak_detector_platform_interface.dart';

class RootJailbreakDetector {
  Future<bool?> isRooted() {
    return RootJailbreakDetectorPlatform.instance.isRooted();
  }

  Future<bool?> isJailbreaked() {
    return RootJailbreakDetectorPlatform.instance.isJailbreaked();
  }
}
