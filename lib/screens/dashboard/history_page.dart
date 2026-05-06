import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key, required this.onBackToHome});

  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    final transactions = [
      _TransactionData.expense(
        title: 'Dinner at Pizza Hut',
        date: 'Thursday, Apr 23',
        amount: '4,500.00',
        payer: 'Lakshitha',
        splitBetween: const ['Lakshitha', 'Laky', 'A', 'B'],
      ),
      _TransactionData.settlement(
        title: 'Payment',
        date: 'Wednesday, Apr 22',
        amount: '1,500.00',
        from: 'Laky',
        to: 'Lakshitha',
      ),
    ];

    return Scaffold(
      backgroundColor: RoomerColors.background,
      body: SafeArea(
        child: ListView(
          padding: RoomerColors.screenPadding,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18, bottom: 24),
              child: Row(
                children: [
                  _BackButton(onTap: onBackToHome),
                  const SizedBox(width: 12),
                  Text('History', style: RoomerTextStyles.pageTitle),
                ],
              ),
            ),
            for (final transaction in transactions) ...[
              _TransactionCard(data: transaction),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 12),
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

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.data});

  final _TransactionData data;

  @override
  Widget build(BuildContext context) {
    final isExpense = data.type == _TransactionType.expense;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: roomerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isExpense
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        isExpense
                            ? 'assets/icon/receipt-solid.svg'
                            : 'assets/icon/handshake-solid.svg',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                        colorFilter: ColorFilter.mode(
                          isExpense
                              ? RoomerColors.success
                              : const Color(0xFF16A34A),
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.title, style: RoomerTextStyles.cardTitle),
                      const SizedBox(height: 2),
                      Text(
                        data.date,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: RoomerColors.mutedText,
                          fontSize: 12,
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
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: const Color(0xFF4B5563),
                                  fontSize: 11,
                                ),
                            children: isExpense
                                ? [
                                    const TextSpan(text: 'Paid by '),
                                    TextSpan(
                                      text: data.payer ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ]
                                : [
                                    TextSpan(
                                      text: data.from ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const TextSpan(text: ' → '),
                                    TextSpan(
                                      text: data.to ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isExpense ? '-' : '+'} ${data.amount}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isExpense
                          ? RoomerColors.text
                          : RoomerColors.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Delete',
                    style: TextStyle(
                      color: RoomerColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isExpense && data.splitBetween != null) ...[
            const SizedBox(height: 14),
            const Divider(color: Color(0xFFF3F4F6)),
            const SizedBox(height: 8),
            Text(
              'Split between:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: RoomerColors.mutedText,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: data.splitBetween!
                  .map(
                    (user) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: RoomerColors.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        user,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    );
  }
}

enum _TransactionType { expense, settlement }

class _TransactionData {
  const _TransactionData.expense({
    required this.title,
    required this.date,
    required this.amount,
    required this.payer,
    required this.splitBetween,
  }) : type = _TransactionType.expense,
       from = null,
       to = null;

  const _TransactionData.settlement({
    required this.title,
    required this.date,
    required this.amount,
    required this.from,
    required this.to,
  }) : type = _TransactionType.settlement,
       payer = null,
       splitBetween = null;

  final _TransactionType type;
  final String title;
  final String date;
  final String amount;
  final String? payer;
  final List<String>? splitBetween;
  final String? from;
  final String? to;
}
