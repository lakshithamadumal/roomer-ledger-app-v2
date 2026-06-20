import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../models/transaction_model.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({
    super.key,
    required this.room,
    required this.transactions,
    required this.members,
    required this.onBackToHome,
  });

  final Room room;
  final List<TransactionModel> transactions;
  final List<RoomMember> members;
  final VoidCallback onBackToHome;

  Map<String, dynamic> _calculateInsights() {
    double totalSpent = 0;
    int txCount = 0;
    
    // Map member userId to amount paid (contribution)
    final Map<String, double> contributions = {};
    // Map member userId to amount consumed (splits)
    final Map<String, double> consumption = {};

    final approvedMembers = members.where((m) => m.status == 'approved').toList();

    for (var m in approvedMembers) {
      contributions[m.userId] = 0.0;
      consumption[m.userId] = 0.0;
    }

    final approvedExpenses = transactions.where((t) => t.type == 'expense' && t.status == 'approved').toList();
    txCount = approvedExpenses.length;

    for (var t in approvedExpenses) {
      totalSpent += t.amount;
      if (t.payerId != null && contributions.containsKey(t.payerId)) {
        contributions[t.payerId!] = (contributions[t.payerId!] ?? 0.0) + t.amount;
      }

      final validSplits = t.splits.where((s) => consumption.containsKey(s.userId)).toList();
      if (validSplits.isNotEmpty) {
        final splitAmount = t.amount / validSplits.length;
        for (var s in validSplits) {
          consumption[s.userId] = (consumption[s.userId] ?? 0.0) + splitAmount;
        }
      }
    }

    // Find highest spender
    String highestSpenderName = 'No data';
    double maxSpent = 0;
    contributions.forEach((uid, val) {
      if (val > maxSpent) {
        maxSpent = val;
        final member = approvedMembers.firstWhere((m) => m.userId == uid);
        highestSpenderName = member.profile?.username ?? 'Unknown';
      }
    });

    // Find highest consumer
    String highestConsumerName = 'No data';
    double maxConsumed = 0;
    consumption.forEach((uid, val) {
      if (val > maxConsumed) {
        maxConsumed = val;
        final member = approvedMembers.firstWhere((m) => m.userId == uid);
        highestConsumerName = member.profile?.username ?? 'Unknown';
      }
    });

    // Generate pie chart sections based on contributions
    final List<PieChartSectionData> sections = [];
    final List<Map<String, dynamic>> legendItems = [];
    
    final List<Color> colors = [
      RoomerColors.primary,
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
    ];

    int colorIndex = 0;
    contributions.forEach((uid, val) {
      if (totalSpent > 0 && val > 0) {
        final percentage = (val / totalSpent) * 100;
        final color = colors[colorIndex % colors.length];
        final member = approvedMembers.firstWhere((m) => m.userId == uid);
        final name = member.profile?.username ?? 'Unknown';

        sections.add(PieChartSectionData(
          value: val,
          color: color,
          radius: 50,
          title: '${percentage.toStringAsFixed(0)}%',
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ));

        legendItems.add({
          'name': name,
          'amount': val,
          'color': color,
        });

        colorIndex++;
      }
    });

    // If no one contributed anything yet, show dummy section
    if (sections.isEmpty) {
      sections.add(PieChartSectionData(
        value: 1,
        color: Colors.grey[300]!,
        radius: 50,
        title: '0%',
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ));
    }

    return {
      'totalSpent': totalSpent,
      'txCount': txCount,
      'highestSpender': highestSpenderName,
      'highestConsumer': highestConsumerName,
      'sections': sections,
      'legend': legendItems,
    };
  }

  @override
  Widget build(BuildContext context) {
    final insights = _calculateInsights();
    final double totalSpent = insights['totalSpent'] as double;
    final int txCount = insights['txCount'] as int;
    final String highestSpender = insights['highestSpender'] as String;
    final String highestConsumer = insights['highestConsumer'] as String;
    final List<PieChartSectionData> sections = insights['sections'] as List<PieChartSectionData>;
    final List<Map<String, dynamic>> legend = insights['legend'] as List<Map<String, dynamic>>;

    return Scaffold(
      backgroundColor: RoomerColors.background,
      body: SafeArea(
        child: ListView(
          padding: RoomerColors.screenPadding,
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 22),
              child: Row(
                children: [
                  _BackButton(onTap: onBackToHome),
                  const SizedBox(width: 12),
                  Text(
                    'Analytics',
                    style: RoomerTextStyles.pageTitle,
                  ),
                ],
              ),
            ),

            // OVERVIEW CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: roomerCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: RoomerColors.text,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStat(
                          title: 'Total Spent',
                          value: '${room.currency} ${totalSpent.toStringAsFixed(0)}',
                          icon: Icons.wallet_rounded,
                          color: RoomerColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStat(
                          title: 'Transactions',
                          value: '$txCount',
                          icon: Icons.receipt_long_rounded,
                          color: const Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PIE CHART CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: roomerCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Contributions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 18),
                  
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 48,
                        sections: sections,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  if (legend.isEmpty)
                    const Center(
                      child: Text(
                        'No spending data recorded yet',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: legend.map((item) {
                        final double amt = item['amount'] as double;
                        return _LegendDot(
                          text: '${item['name']}: ${room.currency} ${amt.toStringAsFixed(0)}',
                          color: item['color'] as Color,
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // MEMBER STATS INSIGHTS
            Row(
              children: [
                Expanded(
                  child: _InsightCard(
                    title: 'Highest Spender',
                    value: highestSpender,
                    icon: Icons.trending_up,
                    color: RoomerColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InsightCard(
                    title: 'Highest Consumer',
                    value: highestConsumer,
                    icon: Icons.shopping_bag_rounded,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // SMART INSIGHTS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: roomerCardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Insights',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  
                  _TipRow(
                    text: totalSpent > 0 
                        ? '$highestSpender paid the most this month 💸'
                        : 'No transactions recorded yet 💸',
                  ),
                  _divider(),
                  _TipRow(
                    text: totalSpent > 0 
                        ? '$highestConsumer consumed the most this month 🍽️'
                        : 'No expenses split yet 🍽️',
                  ),
                  _divider(),
                  _TipRow(
                    text: '$txCount approved expense transactions recorded 📈',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(color: Color(0xFFF3F4F6), height: 24);
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

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Color(0xFF4B5563),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: roomerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  const _TipRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.lightbulb_outline_rounded,
          color: Color(0xFFF59E0B),
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }
}