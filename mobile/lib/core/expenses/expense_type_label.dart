import 'package:flutter/widgets.dart';

import '../l10n/l10n.dart';

/// The shown name of an expense type: built-in keys are translated, members'
/// own types stay as written.
String expenseTypeLabel(BuildContext context, String type) {
  final t = context.l10n;
  return switch (type) {
    'restaurant' => t.expenseTypeRestaurant,
    'cafe' => t.expenseTypeCafe,
    'bar' => t.expenseTypeBar,
    'fast_food' => t.expenseTypeFastFood,
    'snacks' => t.expenseTypeSnacks,
    'taxi' => t.expenseTypeTaxi,
    'flight' => t.expenseTypeFlight,
    'train' => t.expenseTypeTrain,
    'bus' => t.expenseTypeBus,
    'car_rental' => t.expenseTypeCarRental,
    'ferry' => t.expenseTypeFerry,
    'public_transport' => t.expenseTypePublicTransport,
    'hotel' => t.expenseTypeHotel,
    'hostel' => t.expenseTypeHostel,
    'apartment' => t.expenseTypeApartment,
    'camping' => t.expenseTypeCamping,
    _ => type,
  };
}
