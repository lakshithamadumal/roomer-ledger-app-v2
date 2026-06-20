import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room.dart';
import '../models/room_member.dart';
import '../models/transaction_model.dart';

class DatabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // 1. Create a Room
  Future<Room> createRoom(String name, String currency) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Generate a random unique 6-digit code
    String code = '';
    final random = Random();
    bool isUnique = false;
    while (!isUnique) {
      code = (random.nextInt(900000) + 100000).toString();
      final check = await _client.from('rooms').select('id').eq('code', code).maybeSingle();
      if (check == null) {
        isUnique = true;
      }
    }

    // Insert room
    final roomData = await _client.from('rooms').insert({
      'name': name,
      'code': code,
      'currency': currency,
      'created_by': userId,
    }).select().single();

    final room = Room.fromJson(roomData);

    // Insert creator as approved member
    await _client.from('room_members').insert({
      'room_id': room.id,
      'user_id': userId,
      'status': 'approved',
    });

    return room;
  }

  // 2. Join a Room using 6-digit code
  Future<RoomMember> joinRoom(String code) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Find the room
    final roomData = await _client.from('rooms').select().eq('code', code).maybeSingle();
    if (roomData == null) {
      throw Exception('Room not found with the code $code');
    }
    final room = Room.fromJson(roomData);

    // Check if already a member (either pending or approved)
    final existingMember = await _client
        .from('room_members')
        .select()
        .eq('room_id', room.id)
        .eq('user_id', userId)
        .maybeSingle();

    if (existingMember != null) {
      return RoomMember.fromJson(existingMember);
    }

    // Insert room member as pending
    final memberData = await _client.from('room_members').insert({
      'room_id': room.id,
      'user_id': userId,
      'status': 'pending',
    }).select().single();

    return RoomMember.fromJson(memberData);
  }

  // 3. Get Joined Room for current user
  // Returns Room and RoomMember status
  Future<Map<String, dynamic>?> getJoinedRoomForUser() async {
    final userId = currentUserId;
    if (userId == null) return null;

    final memberData = await _client
        .from('room_members')
        .select('*, rooms(*)')
        .eq('user_id', userId)
        .maybeSingle();

    if (memberData == null) return null;

    final member = RoomMember.fromJson(memberData);
    final roomMap = memberData['rooms'] as Map<String, dynamic>;
    final room = Room.fromJson(roomMap);

    return {
      'member': member,
      'room': room,
    };
  }

  // 4. Get all room members
  Future<List<RoomMember>> getRoomMembers(String roomId) async {
    final response = await _client
        .from('room_members')
        .select('*, profiles(*)')
        .eq('room_id', roomId);

    return (response as List)
        .map((data) => RoomMember.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  // 5. Get pending join requests (for admin)
  Future<List<RoomMember>> getPendingRoomJoinRequests(String roomId) async {
    final response = await _client
        .from('room_members')
        .select('*, profiles(*)')
        .eq('room_id', roomId)
        .eq('status', 'pending');

    return (response as List)
        .map((data) => RoomMember.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  // 6. Approve room member
  Future<void> approveRoomMember(String memberId) async {
    await _client
        .from('room_members')
        .update({'status': 'approved'})
        .eq('id', memberId);
  }

  // 7. Reject/Remove room member
  Future<void> rejectRoomMember(String memberId) async {
    await _client.from('room_members').delete().eq('id', memberId);
  }

  // 8. Add Expense
  Future<void> addExpense({
    required String roomId,
    required String description,
    required double amount,
    required List<String> splitUserIds, // IDs of members involved in split
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Insert transaction
    // If the only user in the split is the payer, it is approved immediately.
    final bool autoApprove = splitUserIds.length == 1 && splitUserIds.contains(userId);
    final status = autoApprove ? 'approved' : 'pending';

    final transactionData = await _client.from('transactions').insert({
      'room_id': roomId,
      'type': 'expense',
      'description': description,
      'amount': amount,
      'payer_id': userId,
      'status': status,
    }).select().single();

    final transactionId = transactionData['id'] as String;

    // 2. Insert splits
    final splitAmount = amount / splitUserIds.length;
    final List<Map<String, dynamic>> splitsInsert = splitUserIds.map((uid) {
      return {
        'transaction_id': transactionId,
        'user_id': uid,
        'amount': splitAmount,
      };
    }).toList();
    await _client.from('transaction_splits').insert(splitsInsert);

    // 3. Insert approvals for everyone other than the payer
    final approveUserIds = splitUserIds.where((uid) => uid != userId).toList();
    if (approveUserIds.isNotEmpty) {
      final List<Map<String, dynamic>> approvalsInsert = approveUserIds.map((uid) {
        return {
          'transaction_id': transactionId,
          'user_id': uid,
          'status': 'pending',
        };
      }).toList();
      await _client.from('transaction_approvals').insert(approvalsInsert);
    }
  }

  // 9. Add Settlement
  Future<void> addSettlement({
    required String roomId,
    required String toUserId,
    required double amount,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Insert transaction as pending
    final transactionData = await _client.from('transactions').insert({
      'room_id': roomId,
      'type': 'settlement',
      'description': 'Payment Settlement',
      'amount': amount,
      'from_id': userId,
      'to_id': toUserId,
      'status': 'pending',
    }).select().single();

    final transactionId = transactionData['id'] as String;

    // 2. Insert approval for the receiver
    await _client.from('transaction_approvals').insert({
      'transaction_id': transactionId,
      'user_id': toUserId,
      'status': 'pending',
    });
  }

  // 10. Get Room Transactions (all details)
  Future<List<TransactionModel>> getRoomTransactions(String roomId) async {
    final response = await _client
        .from('transactions')
        .select('*, transaction_splits(*, profiles(*)), transaction_approvals(*, profiles(*)), payer_profile:profiles!transactions_payer_id_fkey(*), from_profile:profiles!transactions_from_id_fkey(*), to_profile:profiles!transactions_to_id_fkey(*)')
        .eq('room_id', roomId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => TransactionModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  // 11. Get Pending Approvals (requests for the user to approve)
  Future<List<TransactionApproval>> getPendingApprovalsForUser() async {
    final userId = currentUserId;
    if (userId == null) return [];

    final response = await _client
        .from('transaction_approvals')
        .select('*, transactions(*, payer_profile:profiles!transactions_payer_id_fkey(*), from_profile:profiles!transactions_from_id_fkey(*), to_profile:profiles!transactions_to_id_fkey(*))')
        .eq('user_id', userId)
        .eq('status', 'pending');

    // For transaction approvals, we want to map them
    return (response as List).map((data) {
      // Inject transaction profile references to avoid nulls when mapping
      return TransactionApproval(
        id: data['id'] as String,
        transactionId: data['transaction_id'] as String,
        userId: data['user_id'] as String,
        status: data['status'] as String,
        updatedAt: DateTime.parse(data['updated_at'] as String),
        // Custom parsing to package the parent transaction with details
        userProfile: null,
      );
    }).toList();
  }

  // 11b. Alternate way to get pending transactions requiring approval
  Future<List<TransactionModel>> getPendingTransactionsForUser() async {
    final userId = currentUserId;
    if (userId == null) return [];

    // Select transactions where there's a pending approval for this user
    final response = await _client
        .from('transactions')
        .select('*, transaction_splits(*, profiles(*)), transaction_approvals!inner(*), payer_profile:profiles!transactions_payer_id_fkey(*), from_profile:profiles!transactions_from_id_fkey(*), to_profile:profiles!transactions_to_id_fkey(*)')
        .eq('transaction_approvals.user_id', userId)
        .eq('transaction_approvals.status', 'pending');

    return (response as List)
        .map((data) => TransactionModel.fromJson(data as Map<String, dynamic>))
        .toList();
  }

  // 12. Approve a transaction (updates approval status and checks if all approved)
  Future<void> approveTransaction(String transactionId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Update user's approval record
    await _client
        .from('transaction_approvals')
        .update({'status': 'approved', 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('transaction_id', transactionId)
        .eq('user_id', userId);

    // 2. Check if all other approvals for this transaction are 'approved'
    final approvals = await _client
        .from('transaction_approvals')
        .select('status')
        .eq('transaction_id', transactionId);

    final allApproved = (approvals as List).every((a) => a['status'] == 'approved');

    if (allApproved) {
      // 3. Mark transaction as approved
      await _client
          .from('transactions')
          .update({'status': 'approved'})
          .eq('id', transactionId);
    }
  }

  // 13. Reject a transaction
  Future<void> rejectTransaction(String transactionId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // 1. Update user's approval record
    await _client
        .from('transaction_approvals')
        .update({'status': 'rejected', 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('transaction_id', transactionId)
        .eq('user_id', userId);

    // 2. Mark transaction as rejected
    await _client
        .from('transactions')
        .update({'status': 'rejected'})
        .eq('id', transactionId);
  }

  // 14. Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    await _client.from('transactions').delete().eq('id', transactionId);
  }

  // 15. Leave Room
  Future<void> leaveRoom(String roomId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _client
        .from('room_members')
        .delete()
        .eq('room_id', roomId)
        .eq('user_id', userId);
  }
}
