import 'package:flutter/material.dart';
import 'package:flutter_c2copine/src/statemng/account.dart';
import 'package:flutter_c2copine/src/utils/mcolor.dart'; 


class SettingsController with ChangeNotifier {
  SettingsController(); 

  late ThemeMode _themeMode;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async { 
    _themeMode = Account().darkMode ? ThemeMode.dark : ThemeMode.light;
    _appLanguage = Account().languageCode.isEmpty ? "en" : Account().languageCode;
    _aiEngine = Account().aiEngine.isEmpty ? "openai" : Account().aiEngine;
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;
    _themeMode = newThemeMode;
    notifyListeners(); 
    await Account().updateDarkMode(newThemeMode == ThemeMode.dark);
  }

  late String _appLanguage;
  String get appLanguage => _appLanguage;
  Future<void> changeAppLanguage(String newValue) async {
    if (newValue == _appLanguage) return;
    _appLanguage = newValue;
    notifyListeners(); 
    await Account().updateLanguageCode(newValue);
  }


  late String _aiEngine;
  String get aiEngine => _aiEngine;
  Future<void> changeAIEngine(String newValue) async {
    if (newValue == _aiEngine) return;
    _aiEngine = newValue;
    notifyListeners(); 
    await Account().updateAIEngine(newValue);
  }


  

  BaseColor get mColor {
    return Account().darkMode ? NightColor() : DayColor();
  }

}
