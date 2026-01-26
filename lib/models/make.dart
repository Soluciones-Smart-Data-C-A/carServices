import 'package:equatable/equatable.dart';

class Make extends Equatable {
  final int id;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Make({required this.id, this.name, this.createdAt, this.updatedAt});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Make.fromMap(Map<String, dynamic> json) {
    return Make(
      id: json['id'] as int,
      name: json['name'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
