import 'user_profile.dart';

class TransactionModel {
  final String id;
  final String roomId;
  final String type; // 'expense' or 'settlement'
  final String description;
  final double amount;
  final String? payerId;
  final String? fromId;
  final String? toId;
  final String status; // 'pending' or 'approved'
  final DateTime createdAt;
  
  final List<TransactionSplit> splits;
  final List<TransactionApproval> approvals;

  // Joined profile fields
  final UserProfile? payerProfile;
  final UserProfile? fromProfile;
  final UserProfile? toProfile;

  TransactionModel({
    required this.id,
    required this.roomId,
    required this.type,
    required this.description,
    required this.amount,
    this.payerId,
    this.fromId,
    this.toId,
    required this.status,
    required this.createdAt,
    this.splits = const [],
    this.approvals = const [],
    this.payerProfile,
    this.fromProfile,
    this.toProfile,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    // Parse nested splits if present
    var splitsList = <TransactionSplit>[];
    if (json['transaction_splits'] != null) {
      splitsList = (json['transaction_splits'] as List)
          .map((i) => TransactionSplit.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    // Parse nested approvals if present
    var approvalsList = <TransactionApproval>[];
    if (json['transaction_approvals'] != null) {
      approvalsList = (json['transaction_approvals'] as List)
          .map((i) => TransactionApproval.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return TransactionModel(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      payerId: json['payer_id'] as String?,
      fromId: json['from_id'] as String?,
      toId: json['to_id'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      splits: splitsList,
      approvals: approvalsList,
      payerProfile: json['payer_profile'] != null
          ? UserProfile.fromJson(json['payer_profile'] as Map<String, dynamic>)
          : null,
      fromProfile: json['from_profile'] != null
          ? UserProfile.fromJson(json['from_profile'] as Map<String, dynamic>)
          : null,
      toProfile: json['to_profile'] != null
          ? UserProfile.fromJson(json['to_profile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'room_id': roomId,
      'type': type,
      'description': description,
      'amount': amount,
      'payer_id': payerId,
      'from_id': fromId,
      'to_id': toId,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class TransactionSplit {
  final String id;
  final String transactionId;
  final String userId;
  final double amount;
  final UserProfile? userProfile;

  TransactionSplit({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.amount,
    this.userProfile,
  });

  factory TransactionSplit.fromJson(Map<String, dynamic> json) {
    return TransactionSplit(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      userProfile: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'user_id': userId,
      'amount': amount,
    };
  }
}

class TransactionApproval {
  final String id;
  final String transactionId;
  final String userId;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime updatedAt;
  final UserProfile? userProfile;

  TransactionApproval({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.status,
    required this.updatedAt,
    this.userProfile,
  });

  factory TransactionApproval.fromJson(Map<String, dynamic> json) {
    return TransactionApproval(
      id: json['id'] as String,
      transactionId: json['transaction_id'] as String,
      userId: json['user_id'] as String,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userProfile: json['profiles'] != null
          ? UserProfile.fromJson(json['profiles'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transaction_id': transactionId,
      'user_id': userId,
      'status': status,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
