// Integration tests run the real native code on a device or simulator.
//
// Run them with `flutter test integration_test` from the `example/` directory.

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const detector = RootJailbreakDetector();

  testWidgets('reports the platform as supported', (tester) async {
    expect(detector.isSupported, isTrue);
  });

  testWidgets('reaches the native implementation', (tester) async {
    // Completing at all proves the method channel is wired up end to end. The
    // value itself depends on the device the test runs on, so it is not
    // asserted here.
    expect(await detector.isCompromised(), isA<bool>());
  });
}
