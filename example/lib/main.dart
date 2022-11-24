import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _rootJailbreakDetectorPlugin = RootJailbreakDetector();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? root;
    bool? jailbreak;

    try {
      if (Platform.isAndroid) {
        root = (await _rootJailbreakDetectorPlugin.isRooted() ?? false);
      } else if (Platform.isIOS) {
        jailbreak =
            (await _rootJailbreakDetectorPlugin.isJailbreaked() ?? false);
      }
    } on PlatformException {
      root = false;
      jailbreak = false;
    }

    if (!mounted) return;

    setState(() {
      _platformVersion =
          "Root Kontrolü $root   -    Jailbreak Kontrolü $jailbreak ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('$_platformVersion\n'),
        ),
      ),
    );
  }
}
