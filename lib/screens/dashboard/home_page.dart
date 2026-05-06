import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.onAddPressed,
    required this.onHistoryPressed,
    required this.onNotificationPressed,
  });

  final VoidCallback onAddPressed;
  final VoidCallback onHistoryPressed;
  final VoidCallback onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    const totalSpent = '4184.00';
    const memberCount = '3';
    const transactionCount = '9';
    const balanceChipText = '1 active debit';

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
                                    'assets/Roomer.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Roomer',
                                style: RoomerTextStyles.homeBrandTitle,
                              ),
                            ],
                          ),
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
                          Text('LKR', style: RoomerTextStyles.homeHeroLkr),
                          const SizedBox(width: 8),
                          Text(
                            totalSpent,
                            style: RoomerTextStyles.homeHeroAmount,
                          ),
                        ],
                      ),
                      const SizedBox(height: 34),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          _HeaderStat(label: 'Members', value: memberCount),
                          _HeaderStat(
                            label: 'Transactions',
                            value: transactionCount,
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
                          color: RoomerColors.orangeSoft,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          balanceChipText,
                          style: RoomerTextStyles.homeActiveDebtChip,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _BalanceCard(
                    name: 'A',
                    status: 'Gets back',
                    amount: '5,200.00',
                    iconAsset: 'assets/icon/arrow-down-solid.svg',
                    iconBackground: RoomerColors.successSoft,
                    iconColor: Color(0xFF16A34A),
                    amountColor: RoomerColors.success,
                    iconSize: 17,
                  ),
                  _BalanceCard(
                    name: 'B',
                    status: 'Owes',
                    amount: '5200.00',
                    iconAsset: 'assets/icon/arrow-up-solid.svg',
                    iconBackground: RoomerColors.orangeSoft,
                    iconColor: Color(0xFFEA580C),
                    amountColor: Color(0xFFEA580C),
                    iconSize: 17,
                  ),
                  _BalanceCard(
                    name: 'C',
                    status: 'Settled',
                    amount: '0.00',
                    iconAsset: 'assets/icon/check-solid.svg',
                    iconBackground: Color(0xFFF1F5F9),
                    iconColor: Color(0xFF475569),
                    amountColor: Color(0xFF475569),
                    iconSize: 15,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Who Owes Who?',
                    style: RoomerTextStyles.sectionTitle.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _SettlementCard(from: 'B', to: 'A', amount: '5200.00'),
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
    required this.iconAsset,
    required this.iconBackground,
    required this.iconColor,
    required this.amountColor,
    this.iconSize = 20,
  });

  final String name;
  final String status;
  final String amount;
  final String iconAsset;
  final Color iconBackground;
  final Color iconColor;
  final Color amountColor;
  final double iconSize;

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
                  child: SvgPicture.asset(
                    iconAsset,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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
  });

  final String from;
  final String to;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Text(
                'LKR',
                style: TextStyle(
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
