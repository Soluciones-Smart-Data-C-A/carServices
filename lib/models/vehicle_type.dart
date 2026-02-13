import 'package:equatable/equatable.dart';

class VehicleType extends Equatable {
  final int id;
  final String name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VehicleType({
    required this.id,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory VehicleType.fromMap(Map<String, dynamic> json) {
    return VehicleType(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt];
}
