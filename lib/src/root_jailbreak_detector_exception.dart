/// Thrown when a root / jailbreak check could not be completed.
///
/// Receiving this exception means the integrity of the device is **unknown**.
/// It does *not* mean the device is safe. Decide deliberately whether your app
/// should fail open (continue) or fail closed (block) in that situation — see
/// [RootJailbreakDetector.isCompromisedOrElse].
class RootJailbreakDetectorException implements Exception {
  /// Creates an exception describing why a check could not be completed.
  const RootJailbreakDetectorException(this.message, {this.code, this.cause});

  /// Human readable explanation of what went wrong.
  final String message;

  /// Machine readable error code, when the platform supplied one.
  final String? code;

  /// The underlying error, when this exception wraps another one.
  final Object? cause;

  @override
  String toString() {
    final label = code == null ? '' : ' ($code)';
    return 'RootJailbreakDetectorException$label: $message';
  }
}
