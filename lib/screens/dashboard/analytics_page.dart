import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../core/theme.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({
    super.key,
    required this.onBackToHome,
  });

  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Overview',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                          color:
                              RoomerColors.text,
                        ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: const [
                      Expanded(
                        child: _MiniStat(
                          title: 'Spent',
                          value:
                              'LKR 14,500',
                          icon: Icons
                              .wallet_rounded,
                          color:
                              RoomerColors.primary,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _MiniStat(
                          title:
                              'Transactions',
                          value: '12',
                          icon: Icons
                              .receipt_long_rounded,
                          color:
                              Color(0xFF3B82F6),
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spending Categories',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius:
                            48,
                        sections: [
                          PieChartSectionData(
                            value: 45,
                            color:
                                RoomerColors.primary,
                            radius: 48,
                            title:
                                '45%',
                            titleStyle:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  12,
                            ),
                          ),
                          PieChartSectionData(
                            value: 25,
                            color:
                                const Color(
                                    0xFF3B82F6),
                            radius: 48,
                            title:
                                '25%',
                            titleStyle:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  12,
                            ),
                          ),
                          PieChartSectionData(
                            value: 18,
                            color:
                                const Color(
                                    0xFFF59E0B),
                            radius: 48,
                            title:
                                '18%',
                            titleStyle:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  12,
                            ),
                          ),
                          PieChartSectionData(
                            value: 12,
                            color:
                                const Color(
                                    0xFFEF4444),
                            radius: 48,
                            title:
                                '12%',
                            titleStyle:
                                const TextStyle(
                              color:
                                  Colors.white,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              fontSize:
                                  12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _LegendDot(
                        text: 'Food',
                        color:
                            RoomerColors.primary,
                      ),
                      _LegendDot(
                        text: 'Rent',
                        color:
                            Color(0xFF3B82F6),
                      ),
                      _LegendDot(
                        text: 'Bills',
                        color:
                            Color(0xFFF59E0B),
                      ),
                      _LegendDot(
                        text: 'Other',
                        color:
                            Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // MEMBER STATS
            Row(
              children: const [
                Expanded(
                  child: _InsightCard(
                    title:
                        'Highest Spender',
                    value:
                        'Lakshitha',
                    icon:
                        Icons.trending_up,
                    color:
                        RoomerColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _InsightCard(
                    title:
                        'Most Paid',
                    value:
                        'Laky',
                    icon:
                        Icons.payments_rounded,
                    color:
                        Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // SMART INSIGHTS
            Container(
              padding: const EdgeInsets.all(20),
              decoration: roomerCardDecoration(),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Insights',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),

                  const _TipRow(
                    text:
                        'Lakshitha spent the most this month 💸',
                  ),
                  _divider(),
                  const _TipRow(
                    text:
                        'Food category highest spending 🍔',
                  ),
                  _divider(),
                  const _TipRow(
                    text:
                        '12 transactions recorded this month 📈',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        height: 1,
        color: Color(0xFFF1F5F9),
      ),
    );
  }
}

// BACK BUTTON
class _BackButton extends StatelessWidget {
  const _BackButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder:
            const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            Icons.arrow_back_rounded,
            color:
                Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

// MINI STAT
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
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            const Color(0xFFF8FAFC),
        borderRadius:
            BorderRadius.circular(
                18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20,
              color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color:
                  RoomerColors.mutedText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// LEGEND
class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style:
              const TextStyle(
            fontSize: 12,
            color:
                RoomerColors.text,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// SMALL CARD
class _InsightCard
    extends StatelessWidget {
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
      padding:
          const EdgeInsets.all(18),
      decoration:
          roomerCardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: color,
              size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color:
                  RoomerColors.mutedText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// INSIGHT TEXT
class _TipRow extends StatelessWidget {
  const _TipRow({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.4,
        color: RoomerColors.text,
        fontWeight:
            FontWeight.w500,
      ),
    );
  }
}