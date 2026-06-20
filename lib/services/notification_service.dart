import 'database_service.dart';

class NotificationService {
  final DatabaseService _dbService = DatabaseService();

  // Get total count of notifications/approvals requiring user attention
  Future<int> getPendingAlertsCount(String? roomId, bool isAdmin) async {
    int count = 0;
    try {
      // 1. Pending transaction approvals
      final pendingTransactions = await _dbService.getPendingTransactionsForUser();
      count += pendingTransactions.length;

      // 2. If user is admin of the room, fetch pending join requests
      if (roomId != null && isAdmin) {
        final pendingJoins = await _dbService.getPendingRoomJoinRequests(roomId);
        count += pendingJoins.length;
      }
    } catch (e) {
      print('Error getting alerts count: $e');
    }
    return count;
  }
}
