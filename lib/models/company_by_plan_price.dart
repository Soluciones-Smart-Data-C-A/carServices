import 'package:equatable/equatable.dart';

class CompanyByPlanPrice extends Equatable {
  final int id;
  final int? idCompany;
  final int? idPlanPrice;
  final DateTime? planExpirationDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompanyByPlanPrice({
    required this.id,
    this.idCompany,
    this.idPlanPrice,
    this.planExpirationDate,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_company': idCompany,
      'id_plan_price': idPlanPrice,
      'plan_expiration_date': planExpirationDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory CompanyByPlanPrice.fromMap(Map<String, dynamic> json) {
    return CompanyByPlanPrice(
      id: json['id'] as int,
      idCompany: json['id_company'] as int?,
      idPlanPrice: json['id_plan_price'] as int?,
      planExpirationDate: json['plan_expiration_date'] != null
          ? DateTime.parse(json['plan_expiration_date'])
          : null,
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
    idCompany,
    idPlanPrice,
    planExpirationDate,
    createdAt,
    updatedAt,
  ];
}
