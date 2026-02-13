import 'package:equatable/equatable.dart';

class ServiceByVehicle extends Equatable {
  final int id;
  final int? idService;
  final int? idVehicleByUser;
  final String? details;
  final int? initialDistance;
  final int? finalDistance;
  final int rubbers;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ServiceByVehicle({
    required this.id,
    required this.idService,
    this.idVehicleByUser,
    this.details,
    this.initialDistance,
    this.finalDistance,
    this.rubbers = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_service': idService,
      'id_vehicle_by_user': idVehicleByUser,
      'details': details,
      'initial_distance': initialDistance,
      'final_distance': finalDistance,
      'rubbers': rubbers,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ServiceByVehicle.fromMap(Map<String, dynamic> json) {
    return ServiceByVehicle(
      id: json['id'] as int,
      idService: json['id_service'] as int?,
      idVehicleByUser: json['id_vehicle_by_user'] as int?,
      details: json['details'] as String?,
      initialDistance: json['initial_distance'] as int?,
      finalDistance: json['final_distance'] as int?,
      rubbers: json['rubbers'] as int,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    idService,
    idVehicleByUser,
    details,
    initialDistance,
    finalDistance,
    rubbers,
    createdAt,
    updatedAt,
  ];
}
