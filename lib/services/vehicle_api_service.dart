import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../models/vehicle.dart';

class VehicleApiService {
  static const String _baseUrl = 'https://wscar.gscloud.us/api/v1/vehicles';
  static final Logger _logger = Logger();

  // Obtener todos los vehículos (Sustituye a DatabaseService.getVehicles)
  static Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      _logger.i("Respuesta del servidor - getVehicles: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> vehicleList = decodedData['data'];

        return vehicleList.map((item) => Vehicle.fromMap(item)).toList();
      } else {
        _logger.e("Error en la petición: ${response.statusCode}");
        throw Exception('Error al cargar vehículos');
      }
    } catch (e) {
      _logger.e("Excepción al consumir el servicio: $e");
      rethrow;
    }
  }

  // Validar si la placa ya existe
  static Future<bool> plateExists(String placa) async {
    final response = await http.get(Uri.parse('$_baseUrl?placa=$placa'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      // Si la API devuelve una lista, verificamos si contiene elementos
      return body.any((v) => v['placa'] == placa);
    }
    return false;
  }
}
