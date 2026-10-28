import 'package:flutter/material.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

class ExpenseCategoryOption {
  const ExpenseCategoryOption({required this.key, required this.icon});

  final String key;
  final IconData icon;

  String labelForLocale(Locale locale) {
    return ExpenseCategoryCatalog.labelFor(key, locale);
  }
}

class ExpenseCategoryCatalog {
  static const List<ExpenseCategoryOption> builtIn = <ExpenseCategoryOption>[
    ExpenseCategoryOption(key: 'food', icon: Icons.restaurant_outlined),
    ExpenseCategoryOption(key: 'groceries', icon: Icons.shopping_cart_outlined),
    ExpenseCategoryOption(key: 'fuel', icon: Icons.local_gas_station_outlined),
    ExpenseCategoryOption(
      key: 'transport',
      icon: Icons.directions_bus_outlined,
    ),
    ExpenseCategoryOption(key: 'accommodation', icon: Icons.hotel_outlined),
    ExpenseCategoryOption(key: 'activities', icon: Icons.hiking_outlined),
    ExpenseCategoryOption(
      key: 'tickets',
      icon: Icons.confirmation_number_outlined,
    ),
    ExpenseCategoryOption(key: 'shopping', icon: Icons.shopping_bag_outlined),
    ExpenseCategoryOption(key: 'party', icon: Icons.celebration_outlined),
    ExpenseCategoryOption(key: 'parking', icon: Icons.local_parking_outlined),
    ExpenseCategoryOption(key: 'other', icon: Icons.more_horiz),
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
      final l10n = lookupAppLocalizations(locale);
      return _labelForBuiltInKey(option.key, l10n);
    }
    return normalized;
  }

  static IconData iconFor(String raw) {
    return optionFor(raw)?.icon ?? Icons.label_outline;
  }

  /// Category identity stays the same across charts, filters and locales.
  static Color colorFor(String raw) {
    final key = normalizeStored(raw).toLowerCase();
    final builtInColor = switch (key) {
      'food' => const Color(0xFF00836B),
      'groceries' => const Color(0xFF6BA83C),
      'fuel' => const Color(0xFFE77A35),
      'transport' => const Color(0xFF28BCE0),
      'accommodation' || 'stays' || 'lodging' => const Color(0xFFD92192),
      'activities' => const Color(0xFF8571C8),
      'tickets' => const Color(0xFFE5AC2B),
      'shopping' => const Color(0xFF4D75D9),
      'party' => const Color(0xFFE45F83),
      'parking' => const Color(0xFFA78657),
      'other' => const Color(0xFF63869B),
      _ => null,
    };
    if (builtInColor != null) return builtInColor;

    // Custom names receive a repeatable colour instead of sharing Other's grey.
    // Do not use String.hashCode, whose result can vary between platforms/runs.
    var hash = 0;
    for (final rune in key.runes) {
      hash = (hash * 31 + rune) & 0x7fffffff;
    }
    return HSLColor.fromAHSL(1, (hash % 3600) / 10, .58, .52).toColor();
  }

  static String groupingKey(String raw) {
    final normalized = normalizeStored(raw);
    final lower = normalized.toLowerCase();
    if (_byKey.containsKey(lower)) {
      return lower;
    }
    return 'custom:$lower';
  }

  static String _labelForBuiltInKey(String key, AppLocalizations l10n) {
    switch (key) {
      case 'food':
        return l10n.expenseCategoryFood;
      case 'groceries':
        return l10n.expenseCategoryGroceries;
      case 'fuel':
        return l10n.expenseCategoryFuel;
      case 'transport':
        return l10n.expenseCategoryTransport;
      case 'accommodation':
        return l10n.expenseCategoryAccommodation;
      case 'activities':
        return l10n.expenseCategoryActivities;
      case 'tickets':
        return l10n.expenseCategoryTickets;
      case 'shopping':
        return l10n.expenseCategoryShopping;
      case 'party':
        return l10n.expenseCategoryParty;
      case 'parking':
        return l10n.expenseCategoryParking;
      case 'other':
        return l10n.expenseCategoryOther;
      default:
        return key;
    }
  }
}
