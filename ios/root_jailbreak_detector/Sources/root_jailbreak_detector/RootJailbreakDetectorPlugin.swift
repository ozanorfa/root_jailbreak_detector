import Flutter
import UIKit

public class RootJailbreakDetectorPlugin: NSObject, FlutterPlugin {

  private static let channelName = "root_jailbreak_detector"
  private static let isDeviceCompromisedMethod = "isDeviceCompromised"

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    registrar.addMethodCallDelegate(RootJailbreakDetectorPlugin(), channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case Self.isDeviceCompromisedMethod:
      // The checks are cheap (file lookups and an in-memory dyld scan) and
      // `canOpenURL` has to run on the main thread anyway, so this stays
      // synchronous on the platform thread.
      result(JailbreakDetector.isDeviceJailbroken())
    default:
      // Never answer `false` here — the Dart side cannot tell that apart from
      // a genuine "this device is clean".
      result(FlutterMethodNotImplemented)
    }
  }
}
