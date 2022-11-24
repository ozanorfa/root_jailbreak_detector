import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'root_jailbreak_detector_platform_interface.dart';

class MethodChannelRootJailbreakDetector extends RootJailbreakDetectorPlatform {
  @visibleForTesting
  final methodChannel = const MethodChannel('root_jailbreak_detector');

  @override
  Future<Bool?> isRootedOrJailbreaked() async {
    if (Platform.isAndroid) {
      final root = await methodChannel.invokeMethod<Bool>('getRoot');
      return root;
    } else if (Platform.isIOS) {
      final jailbreak = await methodChannel.invokeMethod<Bool>('getJailbreak');
      return jailbreak;
    } else {
      return null;
    }
  }
}
