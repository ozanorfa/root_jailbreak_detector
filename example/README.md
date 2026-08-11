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

Simulators and emulators are not a substitute for a real device:

- the **iOS simulator** always reports clean — detection is skipped there entirely, so a green
  result says nothing about whether the checks work
- **Android emulators** are *not* skipped. Images built with test-keys (AOSP and "Google APIs"
  system images) are normally reported as rooted, which is accurate rather than a false
  positive. "Google Play" images usually come back clean.
