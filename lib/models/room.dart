class Room {
  final String id;
  final String code;
  final String name;
  final String currency;
  final String createdBy;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.code,
    required this.name,
    required this.currency,
    required this.createdBy,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'currency': currency,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
