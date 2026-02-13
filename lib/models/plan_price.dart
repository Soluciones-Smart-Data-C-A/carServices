import 'package:equatable/equatable.dart';

class PlanPrice extends Equatable {
  final int id;
  final int? idPlan;
  final int? idBilingPeriod;
  final double? prince; // Note: SQL uses 'prince'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PlanPrice({
    required this.id,
    this.idPlan,
    this.idBilingPeriod,
    this.prince,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_plan': idPlan,
      'id_biling_period': idBilingPeriod,
      'prince': prince,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PlanPrice.fromMap(Map<String, dynamic> json) {
    return PlanPrice(
      id: json['id'] as int,
      idPlan: json['id_plan'] as int?,
      idBilingPeriod: json['id_biling_period'] as int?,
      prince: (json['prince'] as num?)?.toDouble(),
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
    idPlan,
    idBilingPeriod,
    prince,
    createdAt,
    updatedAt,
  ];
}
