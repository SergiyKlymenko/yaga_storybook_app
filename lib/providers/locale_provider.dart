import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('uk');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!L10n.all.contains(locale)) return;
    _locale = locale;
    notifyListeners();
  }

  void clearLocale() {
    _locale = const Locale('uk');
    notifyListeners();
  }
}

class L10n {
  static final all = [
    const Locale('uk'),
    const Locale('en'),
    const Locale('pl'),
    const Locale('az'),
  ];
}
