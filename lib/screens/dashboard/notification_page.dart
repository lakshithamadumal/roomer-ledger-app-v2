import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    required this.room,
    required this.members,
  });

  final Room room;
  final List<RoomMember> members;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final DatabaseService _dbService = DatabaseService();

  List<RoomMember> _pendingJoins = [];
  List<TransactionModel> _pendingTransactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUserId = _dbService.currentUserId;
      final isAdmin = widget.room.createdBy == currentUserId;

      List<RoomMember> joins = [];
      if (isAdmin) {
        joins = await _dbService.getPendingRoomJoinRequests(widget.room.id);
      }

      final transactions = await _dbService.getPendingTransactionsForUser();

      if (!mounted) return;

      setState(() {
        _pendingJoins = joins;
        _pendingTransactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveJoin(String memberId, String username) async {
    try {
      await _dbService.approveRoomMember(memberId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approved $username to join the room!')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectJoin(String memberId, String username) async {
    try {
      await _dbService.rejectRoomMember(memberId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected request from $username')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject: ${e.toString()}')),
      );
    }
  }

  Future<void> _approveTx(String transactionId, String title) async {
    try {
      await _dbService.approveTransaction(transactionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Approved transaction: $title')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectTx(String transactionId, String title) async {
    try {
      await _dbService.rejectTransaction(transactionId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rejected transaction: $title')),
      );
      _loadNotifications();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject: ${e.toString()}')),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final totalItems = _pendingJoins.length + _pendingTransactions.length;

    return Scaffold(
      backgroundColor: RoomerColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Row(
                children: [
                  Material(
                    color: const Color(0xFFF3F4F6),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Pending Approvals', style: RoomerTextStyles.pageTitle),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: RoomerColors.primary))
                  : _errorMessage != null
                      ? Center(
                          child: Text('Error: $_errorMessage', style: const TextStyle(color: RoomerColors.danger)),
                        )
                      : totalItems == 0
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    size: 64,
                                    color: RoomerColors.mutedText.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'All Caught Up!',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: RoomerColors.mutedText.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'No pending join requests or transaction approvals.',
                                    style: TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                if (_pendingJoins.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                    child: Text(
                                      'ROOM JOIN REQUESTS',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                                    ),
                                  ),
                                  ..._pendingJoins.map((m) => _PendingJoinCard(
                                        member: m,
                                        onApprove: () => _approveJoin(m.id, m.profile?.username ?? 'Unknown'),
                                        onReject: () => _rejectJoin(m.id, m.profile?.username ?? 'Unknown'),
                                      )),
                                  const SizedBox(height: 20),
                                ],
                                if (_pendingTransactions.isNotEmpty) ...[
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                    child: Text(
                                      'TRANSACTIONS REQUIRING YOUR APPROVAL',
                                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13),
                                    ),
                                  ),
                                  ..._pendingTransactions.map((t) => _PendingTxCard(
                                        transaction: t,
                                        currency: widget.room.currency,
                                        onApprove: () => _approveTx(t.id, t.description),
                                        onReject: () => _rejectTx(t.id, t.description),
                                      )),
                                ],
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingJoinCard extends StatelessWidget {
  const _PendingJoinCard({
    required this.member,
    required this.onApprove,
    required this.onReject,
  });

  final RoomMember member;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final username = member.profile?.username ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RoomerColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RoomerColors.border),
        boxShadow: RoomerShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE0F7FA),
                ),
                child: const Icon(Icons.person_add_rounded, color: Color(0xFF00ACC1), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'New Join Request',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RoomerColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$username wants to join your room.',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onReject,
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Refuse', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RoomerColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Accept', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _PendingTxCard extends StatelessWidget {
  const _PendingTxCard({
    required this.transaction,
    required this.currency,
    required this.onApprove,
    required this.onReject,
  });

  final TransactionModel transaction;
  final String currency;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final amountText = '$currency ${transaction.amount.toStringAsFixed(2)}';

    String title = 'Expense Approval Request';
    String description = '';

    if (isExpense) {
      final payerName = transaction.payerProfile?.username ?? 'Unknown';
      description = '$payerName added "${transaction.description}" of amount $amountText.';
    } else {
      final senderName = transaction.fromProfile?.username ?? 'Unknown';
      title = 'Settlement Confirmation';
      description = '$senderName sent a settlement payment of $amountText. Please approve once you receive it.';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: RoomerColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: RoomerColors.border),
        boxShadow: RoomerShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isExpense ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9),
                ),
                child: Icon(
                  isExpense ? Icons.receipt_long_rounded : Icons.handshake_rounded,
                  color: isExpense ? const Color(0xFFFF9800) : const Color(0xFF4CAF50),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: RoomerColors.text),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM d, yyyy h:mm a').format(transaction.createdAt.toLocal()),
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onReject,
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Reject', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onApprove,
                style: ElevatedButton.styleFrom(
                  backgroundColor: RoomerColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Approve', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
