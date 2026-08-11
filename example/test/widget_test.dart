import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:root_jailbreak_detector_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('root_jailbreak_detector');

  /// Stands in for the native side of the plugin.
  void mockNativeSide(Object? Function() answer) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => answer());
  }

  // Widget tests already report `TargetPlatform.android`, so the plugin counts
  // as supported here without overriding anything.

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('warns when the device is compromised', (tester) async {
    mockNativeSide(() => true);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Device appears rooted or jailbroken'), findsOneWidget);
  });

  testWidgets('reports a clean device', (tester) async {
    mockNativeSide(() => false);

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('No signs of root or jailbreak'), findsOneWidget);
  });

  testWidgets('surfaces a failed check instead of reporting a clean device',
      (tester) async {
    mockNativeSide(() => throw PlatformException(code: 'check-failed'));

    await tester.pumpWidget(const ExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Integrity unknown — the check failed'), findsOneWidget);
    expect(find.text('No signs of root or jailbreak'), findsNothing);
  });
}
