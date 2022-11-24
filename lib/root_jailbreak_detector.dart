import 'root_jailbreak_detector_platform_interface.dart';

class RootJailbreakDetector {
  /// The methods below are to check status device is rooted, jailbreaked or not
  ///
  /// These methods returns::
  ///
  /// - `true` => if the device is rooted or jailbreaked
  /// - `false` => if the device is safe
  ///

  /// it is used to run native codes of Android to detect root
  Future<bool?> isRooted() {
    return RootJailbreakDetectorPlatform.instance.isRooted();
  }

  /// it is used to run native codes of iOS to detect jailbreak
  Future<bool?> isJailbreaked() {
    return RootJailbreakDetectorPlatform.instance.isJailbreaked();
  }
}
