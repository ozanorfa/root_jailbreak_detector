import 'package:flutter/material.dart';
import 'package:root_jailbreak_detector/root_jailbreak_detector.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Root / Jailbreak Detector',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      home: const DeviceIntegrityPage(),
    );
  }
}

/// The four outcomes a caller has to handle.
enum _Outcome {
  checking('Checking…', Icons.hourglass_empty),
  clean('No signs of root or jailbreak', Icons.verified_user_outlined),
  compromised('Device appears rooted or jailbroken', Icons.gpp_bad_outlined),
  unknown('Integrity unknown — the check failed', Icons.help_outline),
  unsupported('Detection is unavailable here', Icons.devices_other_outlined);

  const _Outcome(this.label, this.icon);

  final String label;
  final IconData icon;
}

class DeviceIntegrityPage extends StatefulWidget {
  const DeviceIntegrityPage({super.key});

  @override
  State<DeviceIntegrityPage> createState() => _DeviceIntegrityPageState();
}

class _DeviceIntegrityPageState extends State<DeviceIntegrityPage> {
  /// Toggled from the UI so you can watch a simulator or emulator change
  /// sides. `true` — the package default — reports emulated environments as
  /// compromised.
  bool _treatEmulatorAsCompromised = true;

  _Outcome _outcome = _Outcome.checking;
  String? _detail;

  // The detector holds no state, so building one per check costs nothing.
  RootJailbreakDetector get _detector => RootJailbreakDetector(
        treatEmulatorAsCompromised: _treatEmulatorAsCompromised,
      );

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() {
      _outcome = _Outcome.checking;
      _detail = null;
    });

    if (!_detector.isSupported) {
      // Web and desktop have no root or jailbreak concept to report on.
      _publish(_Outcome.unsupported, 'Detection only runs on Android and iOS.');
      return;
    }

    try {
      final compromised = await _detector.isCompromised();
      _publish(compromised ? _Outcome.compromised : _Outcome.clean, null);
    } on RootJailbreakDetectorException catch (error) {
      // The check could not run, so device integrity is *unknown*. Treating
      // that as "safe" is how a security control quietly stops working — this
      // example surfaces it instead.
      //
      // To pick a default rather than handle the error, call
      // `_detector.isCompromisedOrElse(true)` to fail closed.
      _publish(_Outcome.unknown, error.message);
    }
  }

  void _publish(_Outcome outcome, String? detail) {
    if (!mounted) return;
    setState(() {
      _outcome = outcome;
      _detail = detail;
    });
  }

  Color _colorFor(ColorScheme scheme) => switch (_outcome) {
        _Outcome.clean => Colors.green.shade700,
        _Outcome.compromised => scheme.error,
        _Outcome.unknown => Colors.orange.shade800,
        _Outcome.checking || _Outcome.unsupported => scheme.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorFor(theme.colorScheme);

    return Scaffold(
      appBar: AppBar(title: const Text('Root / Jailbreak Detector')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_outcome.icon, size: 72, color: color),
              const SizedBox(height: 16),
              Text(
                _outcome.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: color),
              ),
              if (_detail case final detail?) ...[
                const SizedBox(height: 8),
                Text(
                  detail,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              const SizedBox(height: 24),
              FilledButton.tonalIcon(
                onPressed: _outcome == _Outcome.checking ? null : _check,
                icon: const Icon(Icons.refresh),
                label: const Text('Check again'),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: SwitchListTile(
                  value: _treatEmulatorAsCompromised,
                  onChanged: (value) {
                    setState(() => _treatEmulatorAsCompromised = value);
                    _check();
                  },
                  title: const Text('Treat emulators as compromised'),
                  subtitle: Text(
                    _treatEmulatorAsCompromised
                        ? 'Package default. A simulator or emulator counts as '
                            'compromised.'
                        : 'Opted out. A simulator or emulator counts as clean — '
                            'on Android this also lets a rooted device pass by '
                            'forging its Build properties.',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
