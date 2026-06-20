import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({
    super.key,
    required this.room,
    required this.transactions,
    required this.members,
    required this.onBackToHome,
    required this.onTransactionDeleted,
  });

  final Room room;
  final List<TransactionModel> transactions;
  final List<RoomMember> members;
  final VoidCallback onBackToHome;
  final VoidCallback onTransactionDeleted;

  final DatabaseService _dbService = DatabaseService();

  String _formatDate(DateTime dt) {
    return DateFormat('EEEE, MMM d, yyyy').format(dt.toLocal());
  }

  void _showDeleteConfirmation(BuildContext context, String transactionId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete Transaction?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // close dialog
              try {
                await _dbService.deleteTransaction(transactionId);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
                onTransactionDeleted();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete: ${e.toString()}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RoomerColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, TransactionModel t) {
    final splitAmount = t.amount / (t.splits.isNotEmpty ? t.splits.length : 1);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  gradient: RoomerColors.primaryGradient,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(t.createdAt),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    )
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (t.type == 'expense') ...[
                        // Paid by info
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFDBEAFE)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person_outline, color: Colors.blue),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Paid by',
                                        style: TextStyle(color: Color(0xFF4B5563), fontSize: 12),
                                      ),
                                      Text(
                                        t.payerProfile?.username ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Text(
                                '${room.currency} ${t.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF1D4ED8),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Split Breakdown',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: RoomerColors.text),
                        ),
                        const SizedBox(height: 10),
                        ...t.splits.map((s) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9FAFB),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: const Color(0xFFF3F4F6)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: const Color(0xFFE5E7EB),
                                        child: Text(
                                          (s.userProfile?.username ?? 'U').substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFF4B5563),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        s.userProfile?.username ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '- ${splitAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFEA580C),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ] else if (t.type == 'settlement') ...[
                        // Settlement Transfer UI
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: RoomerColors.successSoft,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFDCFCE7)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Money Transfer',
                                style: TextStyle(
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: RoomerColors.orangeSoft,
                                        child: Text(
                                          (t.fromProfile?.username ?? 'F').substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: Color(0xFFEA580C),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.fromProfile?.username ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Text('From', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.arrow_forward_rounded, color: RoomerColors.success),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${room.currency} ${t.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: RoomerColors.success,
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: RoomerColors.successSoft,
                                        child: Text(
                                          (t.toProfile?.username ?? 'T').substring(0, 1).toUpperCase(),
                                          style: const TextStyle(
                                            color: RoomerColors.success,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        t.toProfile?.username ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Text('To', style: TextStyle(fontSize: 11, color: Colors.grey)),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Overall Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Approval Status', style: TextStyle(fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: t.status == 'approved' 
                                  ? RoomerColors.successSoft 
                                  : t.status == 'rejected' 
                                      ? RoomerColors.dangerSoft 
                                      : RoomerColors.orangeSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              t.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: t.status == 'approved' 
                                    ? RoomerColors.success 
                                    : t.status == 'rejected' 
                                        ? RoomerColors.danger 
                                        : const Color(0xFFEA580C),
                              ),
                            ),
                          )
                        ],
                      ),
                      if (t.approvals.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 10),
                        const Text(
                          'Approvals status by roommates:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ...t.approvals.map((app) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(app.userProfile?.username ?? 'Unknown', style: const TextStyle(fontSize: 13)),
                                  Icon(
                                    app.status == 'approved'
                                        ? Icons.check_circle_rounded
                                        : app.status == 'rejected'
                                            ? Icons.cancel_rounded
                                            : Icons.hourglass_top_rounded,
                                    size: 16,
                                    color: app.status == 'approved'
                                        ? RoomerColors.success
                                        : app.status == 'rejected'
                                            ? RoomerColors.danger
                                            : Colors.orange,
                                  ),
                                ],
                              ),
                            ))
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _dbService.currentUserId;

    return Scaffold(
      backgroundColor: RoomerColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Row(
                children: [
                  _BackButton(onTap: onBackToHome),
                  const SizedBox(width: 12),
                  Text('History', style: RoomerTextStyles.pageTitle),
                ],
              ),
            ),
            Expanded(
              child: transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 64,
                            color: RoomerColors.mutedText.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: RoomerColors.mutedText.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        final isExpense = t.type == 'expense';

                        // Check if current user has permission to delete:
                        // Payer can delete expense, Sender can delete settlement, or Admin (room creator) can delete.
                        final bool canDelete = t.payerId == currentUserId ||
                            t.fromId == currentUserId ||
                            room.createdBy == currentUserId;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: roomerCardDecoration(),
                          child: InkWell(
                            onTap: () => _showTransactionDetails(context, t),
                            borderRadius: BorderRadius.circular(28),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: isExpense 
                                                    ? const Color(0xFFECFDF5) 
                                                    : const Color(0xFFEFF6FF),
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  isExpense 
                                                      ? Icons.receipt_long_rounded 
                                                      : Icons.handshake_rounded,
                                                  color: isExpense 
                                                      ? RoomerColors.success 
                                                      : const Color(0xFF1D4ED8),
                                                  size: 22,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(t.description, style: RoomerTextStyles.cardTitle),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _formatDate(t.createdAt),
                                                    style: const TextStyle(
                                                      color: RoomerColors.mutedText,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFF3F4F6),
                                                      borderRadius: BorderRadius.circular(999),
                                                    ),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        style: const TextStyle(
                                                          color: Color(0xFF4B5563),
                                                          fontSize: 11,
                                                        ),
                                                        children: isExpense
                                                            ? [
                                                                const TextSpan(text: 'Paid by '),
                                                                TextSpan(
                                                                  text: t.payerProfile?.username ?? 'Unknown',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ]
                                                            : [
                                                                TextSpan(
                                                                  text: t.fromProfile?.username ?? 'Unknown',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                const TextSpan(text: ' → '),
                                                                TextSpan(
                                                                  text: t.toProfile?.username ?? 'Unknown',
                                                                  style: const TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            '${isExpense ? '-' : '+'} ${t.amount.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: isExpense 
                                                  ? RoomerColors.text 
                                                  : RoomerColors.success,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          if (canDelete)
                                            GestureDetector(
                                              onTap: () => _showDeleteConfirmation(context, t.id),
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                  color: RoomerColors.danger,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  if (isExpense && t.splits.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    const Divider(color: Color(0xFFF3F4F6)),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Split between:',
                                      style: TextStyle(
                                        color: RoomerColors.mutedText,
                                        fontSize: 11,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: t.splits
                                          .map(
                                            (s) => Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: RoomerColors.primarySoft,
                                                borderRadius: BorderRadius.circular(999),
                                              ),
                                              child: Text(
                                                s.userProfile?.username ?? 'Unknown',
                                                style: const TextStyle(
                                                  color: RoomerColors.primaryDark,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF4B5563)),
        ),
      ),
    );
  }
}
