import 'package:flutter/material.dart';

class ExpenseCategoryOption {
  const ExpenseCategoryOption({
    required this.key,
    required this.icon,
    required this.labelEn,
    required this.labelLv,
  });

  final String key;
  final IconData icon;
  final String labelEn;
  final String labelLv;

  String labelForLocale(Locale locale) {
    return locale.languageCode.toLowerCase() == 'lv' ? labelLv : labelEn;
  }
}

class ExpenseCategoryCatalog {
  static const List<ExpenseCategoryOption> builtIn = <ExpenseCategoryOption>[
    ExpenseCategoryOption(
      key: 'food',
      icon: Icons.restaurant_outlined,
      labelEn: 'Food',
      labelLv: 'Ēdiens',
    ),
    ExpenseCategoryOption(
      key: 'groceries',
      icon: Icons.shopping_cart_outlined,
      labelEn: 'Groceries',
      labelLv: 'Pārtika',
    ),
    ExpenseCategoryOption(
      key: 'fuel',
      icon: Icons.local_gas_station_outlined,
      labelEn: 'Fuel',
      labelLv: 'Degviela',
    ),
    ExpenseCategoryOption(
      key: 'transport',
      icon: Icons.directions_bus_outlined,
      labelEn: 'Transport',
      labelLv: 'Transports',
    ),
    ExpenseCategoryOption(
      key: 'accommodation',
      icon: Icons.hotel_outlined,
      labelEn: 'Accommodation',
      labelLv: 'Naktsmītne',
    ),
    ExpenseCategoryOption(
      key: 'activities',
      icon: Icons.hiking_outlined,
      labelEn: 'Activities',
      labelLv: 'Aktivitātes',
    ),
    ExpenseCategoryOption(
      key: 'tickets',
      icon: Icons.confirmation_number_outlined,
      labelEn: 'Tickets',
      labelLv: 'Biļetes',
    ),
    ExpenseCategoryOption(
      key: 'shopping',
      icon: Icons.shopping_bag_outlined,
      labelEn: 'Shopping',
      labelLv: 'Iepirkšanās',
    ),
    ExpenseCategoryOption(
      key: 'party',
      icon: Icons.celebration_outlined,
      labelEn: 'Party',
      labelLv: 'Ballīte',
    ),
    ExpenseCategoryOption(
      key: 'parking',
      icon: Icons.local_parking_outlined,
      labelEn: 'Parking',
      labelLv: 'Stāvvieta',
    ),
    ExpenseCategoryOption(
      key: 'other',
      icon: Icons.more_horiz,
      labelEn: 'Other',
      labelLv: 'Cits',
    ),
  ];

  static final Map<String, ExpenseCategoryOption> _byKey =
      <String, ExpenseCategoryOption>{
        for (final item in builtIn) item.key: item,
      };

  static String normalizeStored(String raw) {
    final compact = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (compact.isEmpty) {
      return 'other';
    }
    final lower = compact.toLowerCase();
    if (lower == 'health') {
      return 'party';
    }
    if (_byKey.containsKey(lower)) {
      return lower;
    }
    return compact;
  }

  static String customToStored(String raw) {
    return normalizeStored(raw);
  }

  static bool isBuiltInKey(String raw) {
    final normalized = normalizeStored(raw).toLowerCase();
    return _byKey.containsKey(normalized);
  }

  static ExpenseCategoryOption? optionFor(String raw) {
    final normalized = normalizeStored(raw).toLowerCase();
    return _byKey[normalized];
  }

  static String labelFor(String raw, Locale locale) {
    final normalized = normalizeStored(raw);
    final option = _byKey[normalized.toLowerCase()];
    if (option != null) {
      return option.labelForLocale(locale);
    }
    return normalized;
  }

  static IconData iconFor(String raw) {
    return optionFor(raw)?.icon ?? Icons.label_outline;
  }

  static String groupingKey(String raw) {
    final normalized = normalizeStored(raw);
    final lower = normalized.toLowerCase();
    if (_byKey.containsKey(lower)) {
      return lower;
    }
    return 'custom:$lower';
  }
}
