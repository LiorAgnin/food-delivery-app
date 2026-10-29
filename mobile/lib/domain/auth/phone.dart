/// National significant number, without the trunk prefix.
/// Mobiles (`5xxxxxxxx`) and VoIP (`7xxxxxxxx`) are 9 digits.
/// Geographic numbers (`2`, `3`, `4`, `8`, `9` plus 7 digits) are 8.
final RegExp _israeliNational = RegExp(r'^(?:5\d{8}|7\d{8}|[23489]\d{7})$');

/// Turns an Israeli phone number into E.164 (`+972501234567`).
///
/// Spaces, hyphens, dots, and parentheses are ignored. A leading `0` is the
/// trunk prefix and is replaced with `+972`. Returns null when [input] is
/// not an Israeli number.
String? normalizeIsraeliPhone(String input) {
  final stripped = input.replaceAll(RegExp(r'[\s\-.()]'), '');
  if (stripped.isEmpty) return null;

  var digits = stripped;
  if (digits.startsWith('+')) {
    digits = digits.substring(1);
  } else if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }
  if (!RegExp(r'^\d+$').hasMatch(digits)) return null;

  final String national;
  if (digits.startsWith('972')) {
    national = digits.substring(3);
  } else if (digits.startsWith('0')) {
    national = digits.substring(1);
  } else {
    return null;
  }
  if (!_israeliNational.hasMatch(national)) return null;
  return '+972$national';
}
