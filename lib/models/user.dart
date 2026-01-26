import 'package:equatable/equatable.dart';

// Constante para la conversión de unidades
const double kmToMile = 0.621371; // Usar camelCase para la constante

class User extends Equatable {
  final int id;
  final int? idCompany;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final bool isPremium;
  final String measurementUnit; // 'km' or 'mi'
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    this.idCompany,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.isPremium = false,
    this.measurementUnit = 'km',
    this.createdAt,
    this.updatedAt,
  });

  /// Convierte el objeto a un mapa para serialización JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'id_company': idCompany,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'is_premium': isPremium ? 1 : 0,
      'measurement_unit': measurementUnit,
    };
  }

  /// Crea una instancia de User a partir de un mapa JSON (incluyendo las fechas de la DB).
  factory User.fromMap(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      idCompany: json['id_company'] as int?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isPremium: (json['is_premium'] as int?) == 1,
      measurementUnit: json['measurement_unit'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// Método de ayuda para la conversión de unidades.
  double convertKmToUserUnit(double km) {
    return measurementUnit == 'mi' ? km * kmToMile : km;
  }

  /// Crea una copia del objeto con valores opcionales actualizados.
  User copyWith({
    int? id,
    int? idCompany,
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    bool? isPremium,
    String? measurementUnit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      idCompany: idCompany ?? this.idCompany,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      measurementUnit: measurementUnit ?? this.measurementUnit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    idCompany,
    firstName,
    lastName,
    phone,
    email,
    isPremium,
    measurementUnit,
    createdAt,
    updatedAt,
  ];
}
