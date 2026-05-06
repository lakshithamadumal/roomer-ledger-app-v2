import 'package:flutter/material.dart';

import '../../core/theme.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key, required this.onBackToHome});

  final VoidCallback onBackToHome;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  bool isExpenseMode = true;
  final List<String> members = const ['Lakshitha', 'Laky', 'A', 'B'];
  final List<String> selectedMembers = ['Lakshitha', 'Laky', 'A', 'B'];
  String payer = 'Lakshitha';
  String from = 'Lakshitha';
  String to = 'Laky';

  @override
  Widget build(BuildContext context) {
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
                  _BackButton(onTap: widget.onBackToHome),
                  const SizedBox(width: 12),
                  Text('New Transaction', style: RoomerTextStyles.pageTitle),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  _ModeButton(
                    title: 'Expense',
                    isActive: isExpenseMode,
                    gradient: RoomerColors.primaryGradient,
                    onTap: () => setState(() => isExpenseMode = true),
                  ),
                  _ModeButton(
                    title: 'Settle Up',
                    isActive: !isExpenseMode,
                    gradient: RoomerColors.orangeGradient,
                    onTap: () => setState(() => isExpenseMode = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: roomerCardDecoration(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: isExpenseMode
                    ? _expenseForm(context)
                    : _settleForm(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseForm(BuildContext context) {
    return Column(
      key: const ValueKey('expense'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Description'),
        const SizedBox(height: 8),
        const _TextField(hint: 'Groceries...'),
        const SizedBox(height: 20),
        const _Label('Amount (LKR)'),
        const SizedBox(height: 8),
        const _TextField(hint: '0.00', isNumber: true),
        const SizedBox(height: 20),
        const _Label('Who Paid?'),
        const SizedBox(height: 8),
        _DropdownField(
          value: payer,
          items: members,
          onChanged: (value) => setState(() => payer = value),
        ),
        const SizedBox(height: 20),
        const _Label('Split Between'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.9,
          ),
          itemBuilder: (context, index) {
            final member = members[index];
            final isSelected = selectedMembers.contains(member);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    selectedMembers.remove(member);
                  } else {
                    selectedMembers.add(member);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? RoomerColors.primarySoft
                      : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? RoomerColors.primary
                        : RoomerColors.border,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  member,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? RoomerColors.primaryDark
                        : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        const _GradientButton(
          text: 'Add Expense',
          gradient: RoomerColors.primaryGradient,
        ),
      ],
    );
  }

  Widget _settleForm(BuildContext context) {
    return Column(
      key: const ValueKey('settlement'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('From'),
                  const SizedBox(height: 8),
                  _DropdownField(
                    value: from,
                    items: members,
                    onChanged: (value) => setState(() => from = value),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 24, left: 10, right: 10),
              child: Icon(
                Icons.arrow_right_alt_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('To'),
                  const SizedBox(height: 8),
                  _DropdownField(
                    value: to,
                    items: members,
                    onChanged: (value) => setState(() => to = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _Label('Amount (LKR)'),
        const SizedBox(height: 8),
        const _TextField(
          hint: '0.00',
          isNumber: true,
          accent: RoomerColors.orange,
        ),
        const SizedBox(height: 24),
        const _GradientButton(
          text: 'Record Payment',
          gradient: RoomerColors.orangeGradient,
        ),
      ],
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

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.title,
    required this.isActive,
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final bool isActive;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Ink(
            height: 56,
            decoration: BoxDecoration(
              gradient: isActive ? gradient : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isActive ? Colors.white : RoomerColors.mutedText,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF374151),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.hint,
    this.isNumber = false,
    this.accent = RoomerColors.primary,
  });

  final String hint;
  final bool isNumber;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accent, width: 2),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF9CA3AF),
          ),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({required this.text, required this.gradient});

  final String text;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: RoomerShadows.card,
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }
}
