import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('domain does not import Flutter or http', () {
    final violations = <String>[];
    for (final entity in Directory('lib/domain').listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final text = entity.readAsStringSync();
      const banned = [
        'package:flutter/',
        'package:http/',
        'dart:io',
        'dart:ui',
      ];
      if (banned.any(text.contains)) violations.add(entity.path);
    }
    expect(violations, isEmpty);
  });
}
