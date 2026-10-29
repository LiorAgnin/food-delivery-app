import '../../domain/catalog/catalog.dart';

/// `4200` → `₪42.00`. No thousands separator: the contract example is `₪42.00`.
String formatAgorot(int agorot) {
  final sign = agorot < 0 ? '-' : '';
  final abs = agorot.abs();
  final shekels = abs ~/ 100;
  final fraction = (abs % 100).toString().padLeft(2, '0');
  return '$sign₪$shekels.$fraction';
}

String dietaryTagLabel(DietaryTag tag) {
  return switch (tag) {
    DietaryTag.vegetarian => 'Vegetarian',
    DietaryTag.vegan => 'Vegan',
    DietaryTag.spicy => 'Spicy',
    DietaryTag.glutenFree => 'Gluten free',
    DietaryTag.dairyFree => 'Dairy free',
    DietaryTag.containsNuts => 'Contains nuts',
  };
}
