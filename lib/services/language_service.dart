import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _key = 'selected_language';
  Locale _locale = const Locale('tr');

  Locale get locale => _locale;

  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'nl', 'name': 'Nederlands', 'flag': '🇳🇱'},
  ];

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null) {
      _locale = Locale(saved);
    } else {
      final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
      final supported = supportedLanguages.map((l) => l['code']!).toList();
      if (supported.contains(deviceLocale.languageCode)) {
        _locale = Locale(deviceLocale.languageCode);
      } else {
        _locale = const Locale('en');
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
    notifyListeners();
  }

  String get languageName {
    final lang = supportedLanguages.firstWhere(
      (l) => l['code'] == _locale.languageCode,
      orElse: () => {'name': 'English'},
    );
    return lang['name']!;
  }
}
