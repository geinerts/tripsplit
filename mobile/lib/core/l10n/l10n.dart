import 'package:flutter/widgets.dart';
import 'package:tripsplit/l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  AppLocalizations get l10nEn => lookupAppLocalizations(const Locale('en'));
}
