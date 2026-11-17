import 'package:flutter/material.dart';

/// One built-in expense type within a category, stored as [key].
class ExpenseTypeOption {
  const ExpenseTypeOption(this.key, this.icon);
  final String key;
  final IconData icon;
}

/// Optional types ("Food · Restaurant"). Only some categories have them.
abstract final class ExpenseTypeCatalog {
  static const Map<String, List<ExpenseTypeOption>> _byCategory = {
    'food': [
      ExpenseTypeOption('restaurant', Icons.restaurant_outlined),
      ExpenseTypeOption('cafe', Icons.local_cafe_outlined),
      ExpenseTypeOption('bar', Icons.local_bar_outlined),
      ExpenseTypeOption('fast_food', Icons.fastfood_outlined),
      ExpenseTypeOption('snacks', Icons.cookie_outlined),
    ],
    'transport': [
      ExpenseTypeOption('taxi', Icons.local_taxi_outlined),
      ExpenseTypeOption('flight', Icons.flight_outlined),
      ExpenseTypeOption('train', Icons.train_outlined),
      ExpenseTypeOption('bus', Icons.directions_bus_outlined),
      ExpenseTypeOption('car_rental', Icons.car_rental_outlined),
      ExpenseTypeOption('ferry', Icons.directions_boat_outlined),
      ExpenseTypeOption('public_transport', Icons.tram_outlined),
    ],
    'accommodation': [
      ExpenseTypeOption('hotel', Icons.hotel_outlined),
      ExpenseTypeOption('hostel', Icons.bed_outlined),
      ExpenseTypeOption('apartment', Icons.apartment_outlined),
      ExpenseTypeOption('camping', Icons.cabin_outlined),
    ],
  };

  /// Categories with no built-in types where members can still type their own.
  static const Set<String> _ownOnly = {'activities', 'shopping'};

  static const int maxLength = 40;

  static List<ExpenseTypeOption> forCategory(String category) =>
      _byCategory[category.trim().toLowerCase()] ?? const [];

  /// Whether the "+ Type" button shows for this category.
  static bool hasTypes(String category) =>
      forCategory(category).isNotEmpty ||
      _ownOnly.contains(category.trim().toLowerCase());

  static bool isBuiltIn(String type) => _byCategory.values.any(
    (options) => options.any((option) => option.key == type),
  );

  /// Trims and joins spaces, so "street  food " and "Street food" match.
  static String? clean(String? raw) {
    final value = (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (value.isEmpty) return null;
    return value.length > maxLength ? value.substring(0, maxLength) : value;
  }

  static String matchKey(String type) => type.trim().toLowerCase();
}
