import 'package:food_delivery/application/checkout.dart';

final class QueuedIdempotencyKeys implements IdempotencyKeys {
  QueuedIdempotencyKeys(this._keys);

  final List<String> _keys;
  var _index = 0;

  @override
  String next() {
    final key = _keys[_index];
    _index += 1;
    return key;
  }
}
