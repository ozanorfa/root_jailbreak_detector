import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'root_jailbreak_detector_platform_interface.dart';

class MethodChannelRootJailbreakDetector extends RootJailbreakDetectorPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('root_jailbreak_detector');

  @override
  Future<Bool?> isRooted() async {
    final root = await methodChannel.invokeMethod<Bool>('getRoot');
    return root;
  }

  @override
  Future<Bool?> isJailbreaked() async {
    final root = await methodChannel.invokeMethod<Bool>('getJailbreak');
    return root;
  }
}
