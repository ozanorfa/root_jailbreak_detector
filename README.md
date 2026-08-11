# root_jailbreak_detector

[![pub package](https://img.shields.io/pub/v/root_jailbreak_detector.svg)](https://pub.dev/packages/root_jailbreak_detector)
[![license: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

Detects whether the current device is **rooted** (Android) or **jailbroken** (iOS), so your
app can react to running on a device whose integrity it cannot trust.

On Android the check is delegated to [RootBeer]. On iOS it runs a set of native heuristics.

## What this is, and what it is not

These checks are a **signal, not a barrier**.

Everything here runs inside your app's own process, on a device the attacker fully controls.
Someone with Frida or a Substrate tweak can hook the method channel and make it answer
`false` in a couple of lines. Detection raises the cost of tampering; it does not prevent it.

Use it to *inform* a decision — warn the user, disable a high-risk feature, attach a flag to
your telemetry. If a security decision actually matters, make it on your server, backed by
[Play Integrity API] on Android and [DeviceCheck / App Attest] on iOS.

## Requirements

| | Minimum |
| --- | --- |
| Flutter | **3.44** |
| Android | `minSdk` 24 |
| iOS | 13 |

Flutter 3.44 is a deliberate floor, not an oversight. The Android module and `Package.swift`
track that version's plugin template, and it is the only version the package is built and
tested against. There is no supported fallback for older Flutter versions — 0.5.x does not
build with AGP 8 or newer, which is what this release exists to fix.

## Install

```console
$ flutter pub add root_jailbreak_detector
```

## Configuration

### Android

None.

### iOS

One of the checks asks whether known package managers are installed by probing their URL
schemes. Since iOS 9, `canOpenURL` answers `false` for any scheme the app has not declared —
so **without this entry that check silently does nothing**.

Add it to `ios/Runner/Info.plist`:

```xml
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>cydia</string>
    <string>sileo</string>
    <string>zbra</string>
    <string>filza</string>
    <string>undecimus</string>
    <string>activator</string>
</array>
```

The other iOS checks work without any configuration.

## Usage

```dart
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';

const detector = RootJailbreakDetector();

// Fail closed: an unknown device is treated as compromised.
if (await detector.isCompromisedOrElse(true)) {
  // Warn the user, disable a feature, flag the session…
}
```

`isCompromised()` covers both platforms — there is no need to branch on `Platform.isAndroid`
yourself.

### Handling a failed check

`isCompromised()` throws a `RootJailbreakDetectorException` when the check cannot run. That
is deliberate: a failed check means device integrity is **unknown**, and reporting unknown as
safe is how a security control quietly stops working.

```dart
try {
  final compromised = await detector.isCompromised();
  // …
} on RootJailbreakDetectorException catch (error) {
  // The check did not run. Decide what that means for your app — and consider
  // reporting it, because it should not normally happen.
  debugPrint('Integrity unknown: ${error.message}');
}
```

Use `isCompromisedOrElse(fallback)` when you would rather pick a default than handle the
error. There is no default value on purpose: whether unknown should mean "block" or "allow"
depends on what your app does with the answer.

### Unsupported platforms

On web and desktop there is nothing to detect, so `isCompromised()` returns `false` and
`isSupported` returns `false`. Check `isSupported` when you need to tell *"checked and clean"*
apart from *"never checked"*:

```dart
if (!detector.isSupported) {
  // Detection does not apply on this platform.
}
```

## API

| Member | Description |
| --- | --- |
| `isCompromised()` | `Future<bool>` — fails with `RootJailbreakDetectorException` when the check cannot run. Failures always arrive as a failed future, never as a synchronous throw, so `await` and `catchError` both see them. |
| `isCompromisedOrElse(bool fallback)` | Never throws. Returns `fallback` on *any* error. |
| `isSupported` | Whether detection applies on the current platform. |
| `RootJailbreakDetector({bool treatEmulatorAsCompromised = true})` | Whether the iOS simulator and Android emulators count as compromised. See [Simulators and emulators](#simulators-and-emulators) before turning it off. |

## What gets checked

**Android** — via [RootBeer]: root management and cloaking apps, `su` and BusyBox binaries,
dangerous system properties, writable system paths, test-keys builds, and a native `su` search.

**iOS**:

- known package managers and jailbreak-era apps on disk (Cydia, Sileo, Zebra, …)
- tweak injection frameworks (MobileSubstrate, libhooker, TweakInject, …), including
  rootless jailbreak staging under `/var/jb`
- injected libraries in the loaded dyld image list, which catches runtime hooking that
  leaves nothing on disk
- package manager URL schemes (requires the `Info.plist` entry above)
- whether the app can write outside its sandbox — rootless jailbreaks (Dopamine, palera1n)
  keep the root filesystem read-only, so this one only fires on rootful jailbreaks; the
  `/var/jb` path check covers the rootless case

### Simulators and emulators

Both are reported as **compromised**, and that is the intended answer rather than a false
positive. An emulated environment runs on a writable filesystem, usually under a debugger,
with none of the guarantees the checks above exist to verify — there is no device integrity
here to vouch for. iOS returns a fixed `true` for the simulator; on Android, RootBeer reaches
the same conclusion by itself on test-keys images (AOSP and "Google APIs" system images).

The practical consequence: **expect a positive result while developing.** If that gets in the
way, say so explicitly:

```dart
const detector = RootJailbreakDetector(treatEmulatorAsCompromised: false);
```

Weigh that first. On Android the exemption reads `Build` properties, which a rooted device can
forge — so `false` also gives a real attacker a way to look like an emulator and skip the check
entirely. If all you need is your own development builds unblocked, leave the default alone and
skip the call instead, which gives up nothing in production:

```dart
final flagged = kDebugMode ? false : await detector.isCompromisedOrElse(true);
```

Either way, a simulator or emulator cannot tell you whether detection *works*. Only a real
device can.

## Migrating from 0.5.x

`isRooted()` and `isJailbreaked()` still work — same platform gating, still never throwing —
but they are deprecated and will be removed in 2.0.0. They now return `false` rather than
`null` in the case where the native side answered with nothing.

They only answered on their own platform and returned `false` everywhere else — so a missing
`Platform.isAndroid` guard silently reported every iOS device as safe. They also returned
`false` when the native call failed, which looks identical to a clean device.

```dart
// Before
final detector = RootJailbreakDetector();
bool flagged = false;
try {
  if (Platform.isAndroid) {
    flagged = await detector.isRooted() ?? false;
  } else if (Platform.isIOS) {
    flagged = await detector.isJailbreaked() ?? false;
  }
} on PlatformException {
  flagged = false;
}

// After
const detector = RootJailbreakDetector();
final flagged = await detector.isCompromisedOrElse(true);
```

Other 1.0.0 changes:

- minimum Flutter 3.44, Android `minSdk` 16 → 24, iOS 9 → 13
- Android is built with the Gradle Kotlin DSL and declares a `namespace`, which is required
  by AGP 8+ — 0.5.x fails to build in any recent Flutter project
- iOS supports Swift Package Manager alongside CocoaPods and ships a privacy manifest
- the native side now answers `notImplemented` for unknown methods instead of `false`

## Contributing

Issues and pull requests are welcome at
[github.com/ozanorfa/root_jailbreak_detector](https://github.com/ozanorfa/root_jailbreak_detector).

From the repository root:

```console
$ flutter test                                   # package tests
$ (cd example && flutter test)                   # example widget tests
$ (cd example && flutter test integration_test)  # native code, on a real device
```

The Kotlin unit tests run through Gradle. Build the example app once first — the Gradle
wrapper is generated rather than checked in, so it does not exist in a fresh clone:

```console
$ (cd example && flutter build apk --debug)
$ (cd example/android && ./gradlew :root_jailbreak_detector:testDebugUnitTest)
```

## License

MIT — see [LICENSE](LICENSE).

[RootBeer]: https://github.com/scottyab/rootbeer
[Play Integrity API]: https://developer.android.com/google/play/integrity
[DeviceCheck / App Attest]: https://developer.apple.com/documentation/devicecheck
