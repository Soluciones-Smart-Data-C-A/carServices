// models/vehicle.dart

class Vehicle {
  final int? id;
  final String make;
  final String model;
  final String plate;
  final int initialMileage;
  final int currentMileage;
  final DateTime lastServiceDate;
  final int lastServiceMileage;
  final String? imageUrl;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.plate,
    required this.initialMileage,
    required this.currentMileage,
    required this.lastServiceDate,
    required this.lastServiceMileage,
    this.imageUrl, // <--- Añadido al constructor
  });

  // Convierte un objeto Vehicle en un mapa para la base de datos.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'plate': plate,
      'initialMileage': initialMileage,
      'currentMileage': currentMileage,
      'lastServiceDate': lastServiceDate.toIso8601String(),
      'lastServiceMileage': lastServiceMileage,
      'imageUrl': imageUrl, // <--- Añadido al mapa
    };
  }

  // Crea un objeto Vehicle a partir de un mapa de la base de datos.
  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as int?,
      make: map['make'] as String,
      model: map['model'] as String,
      plate: map['plate'] ?? '',
      initialMileage: map['initialMileage'] as int,
      currentMileage: map['currentMileage'] as int,
      lastServiceDate: DateTime.parse(map['lastServiceDate'] as String),
      lastServiceMileage: map['lastServiceMileage'] as int,
      imageUrl: map['imageUrl'] as String?, // <--- Extraído del mapa
    );
  }
}
