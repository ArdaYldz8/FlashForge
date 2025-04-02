import 'package:flutter/material.dart';
import 'app_localizations.dart';

/// Delegate for app localizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  /// Constructor
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'tr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
