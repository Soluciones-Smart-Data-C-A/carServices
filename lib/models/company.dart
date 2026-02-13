import 'package:equatable/equatable.dart';

class Company extends Equatable {
  final int id;
  final String name;
  final String? address;
  final String? contactPhone;
  final String? contactEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Company({
    required this.id,
    required this.name,
    this.address,
    this.contactPhone,
    this.contactEmail,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Company.fromMap(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
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
    name,
    address,
    contactPhone,
    contactEmail,
    createdAt,
    updatedAt,
  ];
}
