/// `jsonDecode` yields a `Map<String, dynamic>` for objects. Anything else
/// is a shape error the caller maps to a malformed response.
Map<String, dynamic> asJsonMap(Object? json) {
  if (json is Map<String, dynamic>) return json;
  throw const FormatException('Expected a JSON object');
}
