import 'package:equatable/equatable.dart';

class ServiceFrequencyRule extends Equatable {
  final int id;
  final int idService;
  final int? idVehicleType;
  final int? idVehicleByUser;
  final int? minDistanceKm;
  final int? maxDistanceKm; // Usaremos esto como frecuencia de reemplazo
  final int? frequencyMonths;
  final bool isCustom;
  final bool isDefault;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceFrequencyRule({
    required this.id,
    required this.idService,
    this.idVehicleType,
    this.idVehicleByUser,
    this.minDistanceKm,
    this.maxDistanceKm,
    this.frequencyMonths,
    this.isCustom = false,
    this.isDefault = false,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_service': idService,
      'id_vehicle_type': idVehicleType,
      'id_vehicle_by_user': idVehicleByUser,
      'min_distance_km': minDistanceKm,
      'max_distance_km': maxDistanceKm,
      'frequency_months': frequencyMonths,
      'is_custom': isCustom ? 1 : 0,
      'is_default': isDefault ? 1 : 0,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ServiceFrequencyRule.fromMap(Map<String, dynamic> json) {
    return ServiceFrequencyRule(
      id: json['id'] as int,
      idService: json['id_service'] as int,
      idVehicleType: json['id_vehicle_type'] as int?,
      idVehicleByUser: json['id_vehicle_by_user'] as int?,
      minDistanceKm: json['min_distance_km'] as int?,
      maxDistanceKm: json['max_distance_km'] as int?,
      frequencyMonths: json['frequency_months'] as int?,
      isCustom: (json['is_custom'] as int) == 1,
      isDefault: (json['is_default'] as int) == 1,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    idService,
    idVehicleType,
    idVehicleByUser,
    minDistanceKm,
    maxDistanceKm,
    frequencyMonths,
    isCustom,
    isDefault,
    notes,
    createdAt,
    updatedAt,
  ];
}
