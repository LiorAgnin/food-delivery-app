/// Integer agorot arithmetic. Shekel formatting stays in the presentation
/// layer so the domain never learns a currency symbol.
abstract final class Money {
  static int lineTotal({required int unitPriceAgorot, required int quantity}) =>
      unitPriceAgorot * quantity;

  static int orderTotal({
    required int subtotalAgorot,
    required int deliveryFeeAgorot,
  }) => subtotalAgorot + deliveryFeeAgorot;
}
