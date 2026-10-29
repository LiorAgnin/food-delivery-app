import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery/domain/auth/phone.dart';

void main() {
  test('local and international forms become the same E.164 number', () {
    expect(normalizeIsraeliPhone('050-123-4567'), '+972501234567');
    expect(normalizeIsraeliPhone('+972501234567'), '+972501234567');
    expect(normalizeIsraeliPhone('0501234567'), '+972501234567');
    expect(normalizeIsraeliPhone('+972 50 123 4567'), '+972501234567');
    expect(normalizeIsraeliPhone('(050) 123-4567'), '+972501234567');
    expect(normalizeIsraeliPhone('972501234567'), '+972501234567');
    expect(normalizeIsraeliPhone('00972501234567'), '+972501234567');
  });

  test('a Tel Aviv landline keeps its area code', () {
    expect(normalizeIsraeliPhone('03-123-4567'), '+97231234567');
  });

  test('rejects numbers that are not Israeli', () {
    expect(normalizeIsraeliPhone(''), isNull);
    expect(normalizeIsraeliPhone('   '), isNull);
    expect(normalizeIsraeliPhone('12345'), isNull);
    expect(normalizeIsraeliPhone('050-123-456'), isNull);
    expect(normalizeIsraeliPhone('050-123-45678'), isNull);
    expect(normalizeIsraeliPhone('+14155552671'), isNull);
    expect(normalizeIsraeliPhone('050-ABC-4567'), isNull);
    expect(normalizeIsraeliPhone('+9720501234567'), isNull);
  });
}
