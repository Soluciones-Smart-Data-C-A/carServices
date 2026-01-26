import 'package:equatable/equatable.dart';
import 'package:car_service_app/models/index.dart';

class VehicleByUser extends Equatable {
  final int id;
  final int idUser;
  final int idModelVehicle;
  final User user;
  final ModelVehicle modelVehicle;
  final int? yearModelVehicle;
  final String? image;
  final int currentDistance;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleByUser({
    required this.id,
    required this.user,
    required this.modelVehicle,
    required this.idUser,
    required this.idModelVehicle,
    this.yearModelVehicle,
    this.image,
    this.currentDistance = 0,
    this.createdAt,
    this.updatedAt,
  });

  /// Convierte el objeto a un mapa para serialización JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_user': idUser,
      'id_model_vehicle': idModelVehicle,
      'year_model_vehicle': yearModelVehicle,
      'image': image,
      'current_distance': currentDistance,
    };
  }

  /// Crea una instancia de VehicleByUser a partir de un mapa JSON (incluyendo las fechas de la DB).
  factory VehicleByUser.fromMap(Map<String, dynamic> json) {
    final userMap = json['user'] as Map<String, dynamic>;
    final modelVehicleMap = json['model_vehicle'] as Map<String, dynamic>;
    final userObj = User.fromMap(userMap);
    final modelVehicleObj = ModelVehicle.fromMap(modelVehicleMap);

    return VehicleByUser(
      id: json['id'] as int,
      user: userObj,
      modelVehicle: modelVehicleObj,
      idUser: json['id_user'] as int? ?? userObj.id,
      idModelVehicle: json['id_model_vehicle'] as int? ?? modelVehicleObj.id,
      yearModelVehicle: json['year_model_vehicle'] as int?,
      image: json['image'] as String?,
      currentDistance: json['current_distance'] as int,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Crea una copia del objeto con valores opcionales actualizados.
  VehicleByUser copyWith({
    int? id,
    User? user,
    ModelVehicle? modelVehicle,
    int? yearModelVehicle,
    String? image,
    int? currentDistance,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? idUser,
    int? idModelVehicle,
  }) {
    final newUser = user ?? this.user;
    final newModelVehicle = modelVehicle ?? this.modelVehicle;

    return VehicleByUser(
      id: id ?? this.id,
      user: newUser,
      modelVehicle: newModelVehicle,
      idUser: idUser ?? newUser.id,
      idModelVehicle: idModelVehicle ?? newModelVehicle.id,
      yearModelVehicle: yearModelVehicle ?? this.yearModelVehicle,
      image: image ?? this.image,
      currentDistance: currentDistance ?? this.currentDistance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    user,
    modelVehicle,
    idUser,
    idModelVehicle,
    yearModelVehicle,
    image,
    currentDistance,
    createdAt,
    updatedAt,
  ];
}
