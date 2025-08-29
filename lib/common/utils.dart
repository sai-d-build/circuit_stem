import 'dart:math';

/// Generates a random alphanumeric ID of a specified length.
///
/// [length] The desired length of the ID. Defaults to 10.
String generateRandomId({int length = 10}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
}
