import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../models/transaction_model.dart';

class Debt {
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final double amount;

  Debt({
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.amount,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.room,
    required this.members,
    required this.transactions,
    required this.onAddPressed,
    required this.onHistoryPressed,
    required this.onNotificationPressed,
  });

  final Room room;
  final List<RoomMember> members;
  final List<TransactionModel> transactions;

  final VoidCallback onAddPressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onNotificationPressed;

  Map<String, dynamic> _calculateBalances() {
    double totalGroupSpending = 0;
    final Map<String, double> balances = {};
    final Map<String, Map<String, double>> debtMatrix = {};

    // Filter approved members
    final approvedMembers = members.where((m) => m.status == 'approved').toList();

    // Initialize balances and debt matrix
    for (var m1 in approvedMembers) {
      balances[m1.userId] = 0.0;
      debtMatrix[m1.userId] = {};
      for (var m2 in approvedMembers) {
        if (m1.userId != m2.userId) {
          debtMatrix[m1.userId]![m2.userId] = 0.0;
        }
      }
    }

    // Filter approved transactions
    final approvedTransactions = transactions.where((t) => t.status == 'approved').toList();

    for (var t in approvedTransactions) {
      if (t.type == 'expense') {
        // Only include splits that are among currently approved members
        final validSplits = t.splits.where((s) => balances.containsKey(s.userId)).toList();
        if (validSplits.isEmpty) continue;

        totalGroupSpending += t.amount;
        final splitAmount = t.amount / validSplits.length;

        for (var s in validSplits) {
          balances[s.userId] = (balances[s.userId] ?? 0.0) - splitAmount;
          if (t.payerId != null && balances.containsKey(t.payerId)) {
            balances[t.payerId!] = (balances[t.payerId!] ?? 0.0) + splitAmount;
          }

          // Update pairwise debt matrix
          if (t.payerId != null && s.userId != t.payerId && balances.containsKey(t.payerId)) {
            final currentDebt = debtMatrix[s.userId]?[t.payerId] ?? 0.0;
            debtMatrix[s.userId]?[t.payerId!] = currentDebt + splitAmount;
          }
        }
      } else if (t.type == 'settlement') {
        if (t.fromId != null && t.toId != null && balances.containsKey(t.fromId) && balances.containsKey(t.toId)) {
          balances[t.fromId!] = (balances[t.fromId!] ?? 0.0) + t.amount;
          balances[t.toId!] = (balances[t.toId!] ?? 0.0) - t.amount;

          // Update pairwise debt matrix (reduce debt)
          final currentDebt = debtMatrix[t.fromId]?[t.toId] ?? 0.0;
          debtMatrix[t.fromId]?[t.toId!] = currentDebt - t.amount;
        }
      }
    }

    // Resolve net debts pairwise
    final List<Debt> finalDebts = [];
    final Set<String> processedPairs = {};

    for (var m1 in approvedMembers) {
      for (var m2 in approvedMembers) {
        if (m1.userId == m2.userId) continue;
        final pairKey = [m1.userId, m2.userId].toList()..sort();
        final key = pairKey.join('-');
        if (processedPairs.contains(key)) continue;
        processedPairs.add(key);

        final m1OwesM2 = debtMatrix[m1.userId]?[m2.userId] ?? 0.0;
        final m2OwesM1 = debtMatrix[m2.userId]?[m1.userId] ?? 0.0;
        final net = m1OwesM2 - m2OwesM1;

        final m1Name = m1.profile?.username ?? 'Unknown';
        final m2Name = m2.profile?.username ?? 'Unknown';

        if (net > 0.01) {
          finalDebts.add(Debt(
            fromId: m1.userId,
            fromName: m1Name,
            toId: m2.userId,
            toName: m2Name,
            amount: net,
          ));
        } else if (net < -0.01) {
          finalDebts.add(Debt(
            fromId: m2.userId,
            fromName: m2Name,
            toId: m1.userId,
            toName: m1Name,
            amount: net.abs(),
          ));
        }
      }
    }

    return {
      'totalSpending': totalGroupSpending,
      'balances': balances,
      'debts': finalDebts,
    };
  }

  @override
  Widget build(BuildContext context) {
    final calc = _calculateBalances();
    final double totalSpent = calc['totalSpending'] as double;
    final Map<String, double> balances = calc['balances'] as Map<String, double>;
    final List<Debt> debts = calc['debts'] as List<Debt>;

    final approvedMembers = members.where((m) => m.status == 'approved').toList();
    final pendingTransactions = transactions.where((t) => t.status == 'pending').toList();

    final String balanceChipText = debts.isEmpty 
        ? 'All settled' 
        : '${debts.length} active ${debts.length == 1 ? 'debt' : 'debts'}';

    return Scaffold(
      backgroundColor: RoomerColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: RoomerColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 48),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.5),
                                  child: Image.asset(
                                    'assets/roomer-light-logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.group_work, color: Colors.white);
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                room.name,
                                style: RoomerTextStyles.homeBrandTitle,
                              ),
                            ],
                          ),
                          Stack(
                            children: [
                              Material(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: onNotificationPressed,
                                  borderRadius: BorderRadius.circular(12),
                                  child: const SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Icon(
                                      Icons.notifications_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                              if (pendingTransactions.isNotEmpty)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: RoomerColors.danger,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${pendingTransactions.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Total Group Spending',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(room.currency, style: RoomerTextStyles.homeHeroLkr),
                          const SizedBox(width: 8),
                          Text(
                            totalSpent.toStringAsFixed(2),
                            style: RoomerTextStyles.homeHeroAmount,
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _HeaderStat(label: 'Members', value: '${approvedMembers.length}'),
                          _HeaderStat(
                            label: 'Transactions',
                            value: '${transactions.where((t) => t.status == 'approved').length}',
                            alignRight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: RoomerColors.screenPadding.copyWith(
                top: 20,
                bottom: 176,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Status',
                        style: RoomerTextStyles.sectionTitle.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: debts.isEmpty ? RoomerColors.successSoft : RoomerColors.orangeSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          balanceChipText,
                          style: RoomerTextStyles.homeActiveDebtChip.copyWith(
                            color: debts.isEmpty ? RoomerColors.success : const Color(0xFFEA580C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // List balances of each member
                  ...approvedMembers.map((m) {
                    final bal = balances[m.userId] ?? 0.0;
                    final isPlus = bal > 0.01;
                    final isMinus = bal < -0.01;

                    String statusText = 'Settled';
                    IconData icon = Icons.check_rounded;
                    Color iconBg = const Color(0xFFF1F5F9);
                    Color iconColor = const Color(0xFF475569);
                    Color amountColor = const Color(0xFF475569);

                    if (isPlus) {
                      statusText = 'Gets back';
                      icon = Icons.arrow_downward_rounded;
                      iconBg = RoomerColors.successSoft;
                      iconColor = RoomerColors.success;
                      amountColor = RoomerColors.success;
                    } else if (isMinus) {
                      statusText = 'Owes';
                      icon = Icons.arrow_upward_rounded;
                      iconBg = RoomerColors.orangeSoft;
                      iconColor = const Color(0xFFEA580C);
                      amountColor = const Color(0xFFEA580C);
                    }

                    return _BalanceCard(
                      name: m.profile?.username ?? 'Unknown',
                      status: statusText,
                      amount: bal.abs().toStringAsFixed(2),
                      icon: icon,
                      iconBackground: iconBg,
                      iconColor: iconColor,
                      amountColor: amountColor,
                    );
                  }),

                  const SizedBox(height: 30),
                  Text(
                    'Who Owes Who?',
                    style: RoomerTextStyles.sectionTitle.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (debts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: RoomerColors.successSoft,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFDCFCE7)),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 48, color: RoomerColors.success),
                          SizedBox(height: 8),
                          Text(
                            'All settled up!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: RoomerColors.success,
                            ),
                          )
                        ],
                      ),
                    )
                  else
                    ...debts.map((d) => _SettlementCard(
                          from: d.fromName,
                          to: d.toName,
                          amount: d.amount.toStringAsFixed(2),
                          currency: room.currency,
                        )),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.add_rounded,
                          label: 'Add Expense',
                          onTap: onAddPressed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _ActionCard(
                          icon: Icons.history_rounded,
                          label: 'History',
                          onTap: onHistoryPressed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    this.alignRight = false,
  });

  final String label;
  final String value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final stat = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(width: 110, child: stat),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.name,
    required this.status,
    required this.amount,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.amountColor,
  });

  final String name;
  final String status;
  final String amount;
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final Color amountColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: roomerCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: RoomerTextStyles.homeBalanceAmount.copyWith(
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  const _SettlementCard({
    required this.from,
    required this.to,
    required this.amount,
    required this.currency,
  });

  final String from;
  final String to;
  final String amount;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: roomerCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: RoomerColors.orangeSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: Color(0xFFEA580C),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owes',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111827),
                      ),
                      children: [
                        TextSpan(
                          text: from,
                          style: const TextStyle(
                            color: Color(0xFFEA580C),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        TextSpan(
                          text: to,
                          style: const TextStyle(
                            color: RoomerColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: RoomerTextStyles.homeSettlementAmount),
              Text(
                currency,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: RoomerColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF059669), size: 30),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
