import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'root_jailbreak_detector_platform_interface.dart';

class MethodChannelRootJailbreakDetector extends RootJailbreakDetectorPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('root_jailbreak_detector');

  @override
  Future<bool?> isRooted() async {
    final root = await methodChannel.invokeMethod<bool>('getRoot');
    return root;
  }

  @override
  Future<bool?> isJailbreaked() async {
    final root = await methodChannel.invokeMethod<bool>('getJailbreak');
    return root;
  }
}
