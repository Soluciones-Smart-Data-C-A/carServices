// services/locale_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const String _localeKey = 'locale';

  static Future<void> saveLocale(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, languageCode);
  }

  static Future<String?> getLocale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey);
  }
}
