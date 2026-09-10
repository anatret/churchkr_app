import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController();

  static const _key = 'locale_code';
  Locale _locale = const Locale('ru');
  SharedPreferences? _prefs;

  Locale get locale => _locale;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final stored = _prefs?.getString(_key);
    if (stored != null && stored.isNotEmpty) {
      _locale = Locale(stored);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    await _prefs?.setString(_key, locale.languageCode);
    notifyListeners();
  }
}
