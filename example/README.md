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

On a simulator or emulator the app shows **"Device appears rooted or jailbroken"**. That is
the intended answer, not a bug — an emulated environment is not one whose integrity the
package will vouch for. iOS reports the simulator as compromised outright; on Android,
RootBeer flags test-keys images on its own.

So a red result here proves nothing either way. Run it on a real device to see detection
actually working — a healthy phone should come back clean.

This app uses the default. To see the opt-out instead, construct the detector with
`RootJailbreakDetector(treatEmulatorAsCompromised: false)` in [`lib/main.dart`](lib/main.dart).
