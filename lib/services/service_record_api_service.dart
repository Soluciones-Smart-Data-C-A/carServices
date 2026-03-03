import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:car_service_app/services/database_service.dart';

class ServiceRecordApiService {
  static const String _serviceRecordsUrl =
      'https://wscar.gscloud.us/api/v1/service-records';
  static final Logger _logger = Logger();

  // Registrar un nuevo servicio para un vehículo
  static Future<bool> saveServiceRecord({
    required int vehicleId,
    required int serviceId,
    required int mileage,
    //required String date,
    String? notes,
  }) async {
    try {
      // Nota para el novato: Aquí construimos el formato JSON (Mapa en Dart)
      // que la API está esperando recibir en el "Cuerpo" o "Body" de la petición.
      final Map<String, dynamic> body = {
        "vehicleId": vehicleId,
        "serviceId": serviceId,
        "mileage": mileage,
        // "date": date,
      };

      // Si el usuario escribió notas adicionales, las agregamos al mapa.
      if (notes != null && notes.isNotEmpty) {
        body["notes"] = notes;
      }

      _logger.i("Enviando petición POST a $_serviceRecordsUrl con body: $body");

      // Hacemos la llamada HTTP tipo POST enviando el body convertido a formato de texto JSON
      final response = await http.post(
        Uri.parse(_serviceRecordsUrl),
        headers: {
          'Content-Type': 'application/json', // Indicamos que mandamos JSON
          'Accept':
              'application/json', // Indicamos que esperamos JSON de vuelta
        },
        body: jsonEncode(body), // Convertimos el Mapa Dart a String JSON
      );

      _logger.i(
        "Respuesta del servidor - saveServiceRecord: ${response.statusCode}",
      );
      _logger.d("Cuerpo de respuesta: ${response.body}");

      // Comprobamos si el servidor nos respondió con un código de "Creado" (201) o de "Éxito" (200)
      if (response.statusCode == 201 || response.statusCode == 200) {
        _logger.i("✅ Servicio registrado exitosamente en la API.");
        return true; // Informamos que todo salió bien
      } else {
        // Si el código es 400, 500, etc., significa que la API rechazó la petición
        _logger.e(
          "❌ Error al registrar en la API. Código: ${response.statusCode}",
        );
        throw Exception(
          'Error al registrar servicio en la API: ${response.body}',
        );
      }
    } catch (e) {
      // Atrapamos problemas de red (ej. sin wifi) o fallos inesperados
      _logger.e(
        "❌ Excepción al comunicarse con la API para registrar servicio: $e",
      );
      rethrow; // Re-lanzamos el error para que la pantalla que llamó esta función lo sepa manejar
    }
  }

  // Obtener el historial de servicios de la API con los detalles anidados
  static Future<List<Map<String, dynamic>>>
  getServiceRecordsWithDetails() async {
    try {
      _logger.i("Obteniendo historial de servicios desde: $_serviceRecordsUrl");
      final response = await http.get(Uri.parse(_serviceRecordsUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        final List<dynamic> recordsList = decodedData['data'];

        // Obtenemos los servicios locales con sus iconos para poder mapear visualmente
        // Nota para el novato: Como la API no nos devuelve el texto del ícono (ej. 'oil_change'),
        // consultamos nuestra base de datos local para saber qué ícono corresponde a cada servicio.
        final servicesWithIcons = await DatabaseService.getServicesWithIcons();

        // Creamos un diccionario: Id del Servicio -> Nombre del Ícono en texto
        final Map<int, String> serviceIconMap = {};
        for (var srv in servicesWithIcons) {
          serviceIconMap[srv['id'] as int] =
              (srv['iconData'] as String?) ?? 'oil_change';
        }

        // Transformamos la lista de la API al formato exacto que espera history.dart
        return recordsList.map((item) {
          final vehicle = item['vehicle'] ?? {};
          final service = item['service'] ?? {};
          final serviceId = item['serviceId'] as int;

          return {
            'id': item['id'],
            'vehicleId': item['vehicleId'],
            'serviceId': serviceId,
            'mileage': item['mileage'],
            'date': item['date'],
            'notes': item['notes'],
            'vehicleMake': vehicle['make'] ?? 'Desconocido',
            'vehicleModel': vehicle['model'] ?? 'Desconocido',
            'serviceName': service['serviceName'] ?? 'Servicio',
            // Buscamos en nuestro diccionario local el ícono basado en el ID del servicio
            'serviceIcon': serviceIconMap[serviceId] ?? 'oil_change',
          };
        }).toList();
      } else {
        _logger.e(
          "❌ Error al cargar el historial desde la API. Código: ${response.statusCode}",
        );
        throw Exception('Error al cargar el historial: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e("❌ Excepción al comunicarse con la API para historial: $e");
      rethrow;
    }
  }
}
