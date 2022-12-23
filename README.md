# root_jailbreak_detector

Flutter Root(Android) and Jailbreak(iOS) Detector Plugin.

## *Getting Started*

For Android this plugin uses RootBeer: https://github.com/scottyab/rootbeer <br />
For iOS this plugin runs Native methods

### *Install*
```dart
$ flutter pub add root_jailbreak_detector
```
This will add a line like this to your package's pubspec.yaml:
```dart
dependencies:
  root_jailbreak_detector: ^0.5.3
  ```
  
### *Configuration*
#### Android
No configuration is needed.
#### iOS
Add this code to the Info.plist file under the /ios/Runner/ folder.
```swift
	<key>LSApplicationQueriesSchemes</key>
	<array>
		<string>cydia</string>
	</array>

```

### *Usage*
```dart
final _rootJailbreakDetectorPlugin = RootJailbreakDetector();
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
```


