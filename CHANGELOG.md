## 1.0.0

First stable release. It is mostly a rebuild: 0.5.x no longer compiled in a current Flutter
project, and the API made it easy to get a wrong answer.

### Breaking

* `isRooted()` and `isJailbreaked()` are deprecated in favour of `isCompromised()` and
  `isCompromisedOrElse()`, which cover both platforms. The old methods keep their
  platform-gated behaviour and still never throw, so existing call sites keep working; they
  will be removed in 2.0.0 — see the README for a migration example.
* Return types are no longer nullable (`Future<bool?>` → `Future<bool>`), so callers are not
  pushed into writing `?? false` and quietly defaulting to "safe".
* `isCompromised()` throws `RootJailbreakDetectorException` when a check cannot run, instead
  of reporting the device as clean.
* `RootJailbreakDetectorPlatform` now exposes a single `isDeviceCompromised()` plus
  `isSupported`. Custom platform implementations need updating.
* Minimum versions raised: Flutter 3.44, Android `minSdk` 24, iOS 13. The Android module
  and `Package.swift` track the Flutter 3.44 plugin template, so that is the floor the
  package is built and tested against.

### Fixed

* **Android builds now work again.** The module declared no `namespace` and still carried
  `package` in its manifest, which AGP 8+ rejects — the plugin failed to build in any recent
  Flutter project. It now uses the Gradle Kotlin DSL, AGP 9, `compileSdk` 36 and Java 17.
* **The iOS sandbox check tested nothing.** `canEditSystemFiles` wrote to a bare file name,
  so the path resolved against the app's working directory rather than the system root —
  and the answer stopped depending on whether the device was jailbroken at all. In practice
  that directory is not writable, so the check almost certainly returned `false` even on
  jailbroken devices; had it been writable it would have fired on every device instead.
  It now writes to an absolute path outside the container and removes the probe afterwards.
* The native side answers `notImplemented` for unknown methods. Previously both platforms
  returned `false`, which Dart could not tell apart from a genuinely clean device — so
  `isJailbreaked()` on Android and `isRooted()` on iOS always said "safe".
* RootBeer no longer runs on the platform thread; it touches the file system and shells out
  looking for `su`.
* A scan still in flight when the Flutter engine detaches no longer tries to answer on a
  channel that is already gone.
* The published archive was 13 MB of build artifacts because the package had no `.gitignore`.

### Added

* `isCompromised()` and `isCompromisedOrElse(fallback)` — one call covering both platforms.
  `isCompromised()` always reports failure as a failed future rather than a synchronous
  throw, so `catchError` callers see it too; `isCompromisedOrElse()` absorbs *any* error, so
  an incomplete custom platform implementation cannot break its never-throws contract.
* `isSupported`, to tell "checked and clean" apart from "never checked".
* Swift Package Manager support alongside CocoaPods, plus a privacy manifest.
* iOS: detection of injected libraries via the dyld image list, which catches runtime hooking
  that leaves no trace on disk.
* iOS: modern package managers and jailbreaks — Sileo, Zebra, Filza, libhooker, TweakInject,
  and rootless staging under `/var/jb`.
* Android and Dart unit tests, plus an integration test that exercises the real native code.

### Changed

* A simulator or emulator is now reported as compromised by default. 0.5.4 had exempted the
  iOS simulator, but that exemption rested on an assumption about what can be run there, and
  it left the two platforms disagreeing — Android emulators were already being flagged.
  `RootJailbreakDetector(treatEmulatorAsCompromised: false)` opts out on both platforms; the
  README explains why gating the call on `kDebugMode` is usually the better trade.
* RootBeer 0.1.0 → 0.1.1.
* The iOS `UIDevice.isJailBroken` extension is gone. It was `public`, so it leaked onto
  `UIDevice` for every app that imported the plugin.
* The podspec carries real metadata instead of the `A new Flutter plugin project` template
  placeholders.
* The example app was rebuilt on the current Flutter template; the old one could not build.
* The analyzer runs with `strict-casts`, `strict-inference` and `strict-raw-types`, and every
  public member is required to carry documentation.

## 0.5.4

* iOS simulator control fix

## 0.5.3

* Small fixes

## 0.5.2

* Documentation is provided.

## 0.5.1

* Desciption is changed.

## 0.5.0

* Root and Jailbreak control enabled, published.
