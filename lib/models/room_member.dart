import 'user_profile.dart';

class RoomMember {
  final String id;
  final String roomId;
  final String userId;
  final String status; // 'pending', 'approved'
  final DateTime createdAt;
  final UserProfile? profile; // Nested profile information

  RoomMember({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.status,
    required this.createdAt,
    this.profile,
  });

  factory RoomMember.fromJson(Map<String, dynamic> json) {
    return RoomMember(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      profile: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'user_id': userId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
