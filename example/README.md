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

A simulator or emulator is never reported as compromised, so expect a clean result there.
