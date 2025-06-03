import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'language_code';
  SharedPreferences? _prefs;
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  LanguageProvider() {
    _loadLanguage();
  }

  Locale get currentLocale => _currentLocale;

  Future<void> _loadLanguage() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final String? languageCode = _prefs?.getString(_languageKey);
      if (languageCode != null) {
        _currentLocale = Locale(languageCode);
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading language preferences: $e');
      // Keep default English locale if there's an error
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    _currentLocale = Locale(languageCode);
    try {
      await _prefs?.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language preference: $e');
    }
    notifyListeners();
  }

  bool get isArabic => _currentLocale.languageCode == 'ar';
  bool get isInitialized => _isInitialized;
} 