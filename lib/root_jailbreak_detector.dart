import 'root_jailbreak_detector_platform_interface.dart';

class RootJailbreakDetector {
  /// it is used to run native codes of Android to detect root
  Future<bool?> isRooted() {
    return RootJailbreakDetectorPlatform.instance.isRooted();
  }

  /// it is used to run native codes of iOS to detect jailbreak
  Future<bool?> isJailbreaked() {
    return RootJailbreakDetectorPlatform.instance.isJailbreaked();
  }
}
