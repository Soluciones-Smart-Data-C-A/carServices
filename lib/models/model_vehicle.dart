import 'package:equatable/equatable.dart';

class ModelVehicle extends Equatable {
  final int id;
  final int idMake;
  final String name;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ModelVehicle({
    required this.id,
    required this.idMake,
    required this.name,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  /// Convierte el objeto a un mapa para serialización JSON.
  Map<String, dynamic> toMap() {
    return {'id': id, 'id_make': idMake, 'name': name, 'image_url': imageUrl};
  }

  /// Crea una instancia de ModelVehicle a partir de un mapa JSON (incluyendo las fechas de la DB).
  factory ModelVehicle.fromMap(Map<String, dynamic> json) {
    return ModelVehicle(
      id: json['id'] as int,
      idMake: json['id_make'] as int,
      name: json['name'] as String,
      // Usar 'image_url' para consistencia con toMap, pero aceptamos 'imageUrl' por si acaso
      imageUrl: json['image_url'] ?? json['imageUrl'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Crea una copia del objeto con valores opcionales actualizados.
  ModelVehicle copyWith({
    int? id,
    int? idMake,
    String? name,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ModelVehicle(
      id: id ?? this.id,
      idMake: idMake ?? this.idMake,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, idMake, name, imageUrl, createdAt, updatedAt];
}
