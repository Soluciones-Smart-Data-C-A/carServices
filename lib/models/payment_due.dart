import 'package:equatable/equatable.dart';

class PaymentDue extends Equatable {
  final int id;
  final int? companyByPlanPrice;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PaymentDue({
    required this.id,
    this.companyByPlanPrice,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_by_plan_price': companyByPlanPrice,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PaymentDue.fromMap(Map<String, dynamic> json) {
    return PaymentDue(
      id: json['id'] as int,
      companyByPlanPrice: json['company_by_plan_price'] as int?,
      status: json['status'] as int?,
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
    companyByPlanPrice,
    status,
    createdAt,
    updatedAt,
  ];
}
