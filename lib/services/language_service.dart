import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _key = 'app_language';
  Locale _currentLocale = const Locale('id');

  Locale get currentLocale => _currentLocale;

  // Load language from storage
  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    String? code = prefs.getString(_key);

    if (code != null) {
      _currentLocale = Locale(code);
      notifyListeners();
    }
  }

  // Change language + save to local storage
  Future<void> changeLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code);

    _currentLocale = Locale(code);
    notifyListeners();
  }
}
