# root_jailbreak_detector_example

Demonstrates `root_jailbreak_detector` on a device.

The app runs a check on startup and shows one of four outcomes — clean, compromised, unknown
(the check failed), or unsupported platform — with a button to run it again. See
[`lib/main.dart`](lib/main.dart) for the recommended calling pattern.

```console
$ flutter run                      # on a connected device or simulator
$ flutter test                     # widget tests, with the native side mocked
$ flutter test integration_test    # exercises the real native code
```

On the **iOS simulator** the app always shows "Device appears rooted or jailbroken". That is
the intended answer, not a bug — an emulated environment is not one whose integrity the
package will vouch for.

On an **Android emulator** it depends on the system image: RootBeer flags test-keys images
(AOSP, "Google APIs") but usually passes a "Google Play" image, so either colour is normal.

Either way the result proves nothing about the checks. Run it on a real device to see
detection actually working — a healthy phone should come back clean.

The **"Treat emulators as compromised"** switch at the bottom flips
`RootJailbreakDetector(treatEmulatorAsCompromised: ...)` and re-runs the check, so you can
watch a simulator move between red and green without editing any code.
