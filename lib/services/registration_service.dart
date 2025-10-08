// registration_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationService {
  static const String _registrationCompletedKey = 'registration_completed';

  // Verificar si el registro está completado
  static Future<bool> isRegistrationCompleted() async {
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getBool(_registrationCompletedKey) ?? false;
    return false;
  }

  // Marcar el registro como completado
  static Future<void> setRegistrationCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_registrationCompletedKey, completed);
  }

  // Reiniciar el estado de registro (para testing/logout)
  static Future<void> resetRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registrationCompletedKey);
  }
}
