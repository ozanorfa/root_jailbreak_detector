import Foundation
import MachO
import UIKit

/// Heuristic jailbreak checks.
///
/// Each check looks for a trace that jailbreaking normally leaves behind. Any
/// single hit is enough to call the device compromised. None of them are
/// authoritative — a determined attacker can defeat all of them, so treat the
/// result as a signal rather than a gate. See the package README.
enum JailbreakDetector {

  /// Whether the current device shows signs of being jailbroken.
  ///
  /// The simulator answers with `treatSimulatorAsCompromised` rather than
  /// running the checks below. It is a macOS process on a writable filesystem,
  /// usually with a debugger attached, so there is no device integrity to
  /// vouch for — but the checks would key off whatever macOS happens to have
  /// on disk (`/bin/bash` and friends) and report a jailbreak for the wrong
  /// reason, so the answer is fixed rather than measured.
  static func isDeviceJailbroken(treatSimulatorAsCompromised: Bool) -> Bool {
    if isSimulator { return treatSimulatorAsCompromised }

    return hasSuspiciousFiles()
      || hasSuspiciousURLSchemes()
      || hasInjectedLibraries()
      || canWriteOutsideSandbox()
  }

  private static var isSimulator: Bool {
    #if targetEnvironment(simulator)
      return true
    #else
      return false
    #endif
  }

  /// Package managers, tweaks and daemons installed by jailbreak tooling.
  private static func hasSuspiciousFiles() -> Bool {
    suspiciousPaths.contains { FileManager.default.fileExists(atPath: $0) }
  }

  /// Package managers register URL schemes.
  ///
  /// Every scheme has to appear in the host app's `LSApplicationQueriesSchemes`
  /// — without it `canOpenURL` always answers `false` on iOS 9 and later and
  /// this check silently does nothing. The README lists the required entries.
  private static func hasSuspiciousURLSchemes() -> Bool {
    suspiciousURLSchemes
      .compactMap { URL(string: $0) }
      .contains { UIApplication.shared.canOpenURL($0) }
  }

  /// Tweak injection shows up as extra images in the loaded dyld list.
  ///
  /// This catches runtime hooking that leaves no trace on disk, which the file
  /// checks above would miss.
  private static func hasInjectedLibraries() -> Bool {
    for index in 0..<_dyld_image_count() {
      guard let rawName = _dyld_get_image_name(index) else { continue }
      let imagePath = String(cString: rawName)
      if suspiciousLibraryNames.contains(where: { imagePath.contains($0) }) {
        return true
      }
    }
    return false
  }

  /// A sandboxed app cannot write outside its own container; a jailbroken one can.
  private static func canWriteOutsideSandbox() -> Bool {
    // The path must be absolute and outside the container. A bare file name
    // would resolve *inside* the sandbox and succeed on a healthy device,
    // reporting every user as jailbroken.
    let probePath = "/private/\(UUID().uuidString)"
    do {
      try "jailbreak-probe".write(toFile: probePath, atomically: true, encoding: .utf8)
      // Leave nothing behind on devices that really are jailbroken.
      try? FileManager.default.removeItem(atPath: probePath)
      return true
    } catch {
      return false
    }
  }

  private static let suspiciousURLSchemes = [
    "cydia://",
    "sileo://",
    "zbra://",
    "filza://",
    "undecimus://",
    "activator://",
  ]

  private static let suspiciousLibraryNames = [
    "MobileSubstrate",
    "SubstrateLoader",
    "SubstrateInserter",
    "TweakInject",
    "libhooker",
    "RocketBootstrap",
  ]

  private static let suspiciousPaths = [
    // Package managers and jailbreak-era apps.
    "/Applications/Cydia.app",
    "/Applications/Sileo.app",
    "/Applications/Zebra.app",
    "/Applications/blackra1n.app",
    "/Applications/FakeCarrier.app",
    "/Applications/Icy.app",
    "/Applications/IntelliScreen.app",
    "/Applications/MxTube.app",
    "/Applications/RockApp.app",
    "/Applications/SBSettings.app",
    "/Applications/WinterBoard.app",
    // Tweak injection frameworks.
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
    "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
    "/usr/lib/libhooker.dylib",
    "/usr/lib/substrate",
    "/usr/lib/TweakInject",
    // Rootless jailbreaks (Dopamine, palera1n) stage everything under /var/jb.
    "/var/jb",
    // Package manager state.
    "/private/var/lib/apt",
    "/private/var/lib/cydia",
    "/private/var/mobile/Library/SBSettings/Themes",
    "/private/var/stash",
    "/private/var/tmp/cydia.log",
    "/etc/apt",
    // Daemons and shells that a stock device does not expose.
    "/System/Library/LaunchDaemons/com.ikey.bbot.plist",
    "/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
    "/bin/bash",
    "/etc/ssh/sshd_config",
    "/usr/bin/ssh",
    "/usr/bin/sshd",
    "/usr/libexec/sftp-server",
    "/usr/sbin/frida-server",
    "/usr/sbin/sshd",
  ]
}
