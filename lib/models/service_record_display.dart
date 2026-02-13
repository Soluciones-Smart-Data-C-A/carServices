class ServiceRecordDisplay {
  final int id;
  final int vehicleId;
  final int serviceId;
  final int mileage;
  final DateTime date;
  final String? notes;
  final String? serviceName;
  final int? serviceIconId;

  ServiceRecordDisplay({
    required this.id,
    required this.vehicleId,
    required this.serviceId,
    required this.mileage,
    required this.date,
    this.notes,
    this.serviceName,
    this.serviceIconId,
  });

  factory ServiceRecordDisplay.fromMap(Map<String, dynamic> map) {
    return ServiceRecordDisplay(
      id: map['id'] as int,
      vehicleId: map['vehicleId'] as int,
      serviceId: map['serviceId'] as int,
      mileage: map['mileage'] as int,
      date: DateTime.parse(map['date'] as String),
      notes: map['notes'] as String?,
      serviceName: map['serviceName'] as String?,
      serviceIconId: map['iconId'] as int?,
    );
  }
}
