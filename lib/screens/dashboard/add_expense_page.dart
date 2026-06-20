import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../services/database_service.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({
    super.key,
    required this.room,
    required this.members,
    required this.onBackToHome,
    required this.onExpenseAdded,
  });

  final Room room;
  final List<RoomMember> members;
  final VoidCallback onBackToHome;
  final VoidCallback onExpenseAdded;

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final DatabaseService _dbService = DatabaseService();

  bool isExpenseMode = true;
  bool _isLoading = false;

  // Controllers
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _settleAmountController = TextEditingController();

  // Selection states
  String? _selectedPayerId;
  String? _selectedFromUserId;
  String? _selectedToUserId;
  final Set<String> _selectedSplitUserIds = {};

  @override
  void initState() {
    super.initState();
    _initializeSelections();
  }

  @override
  void didUpdateWidget(covariant AddExpensePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.members != widget.members) {
      _initializeSelections();
    }
  }

  void _initializeSelections() {
    if (widget.members.isNotEmpty) {
      // Find current user id
      final currentUserId = _dbService.currentUserId;
      
      // Default Payer is current user if in room, else first member
      final hasCurrentUser = widget.members.any((m) => m.userId == currentUserId);
      _selectedPayerId = hasCurrentUser ? currentUserId : widget.members.first.userId;

      // Default From is current user if in room, else first member
      _selectedFromUserId = hasCurrentUser ? currentUserId : widget.members.first.userId;

      // Default To is first member that is NOT current user, else first member
      final otherMembers = widget.members.where((m) => m.userId != currentUserId).toList();
      _selectedToUserId = otherMembers.isNotEmpty 
          ? otherMembers.first.userId 
          : widget.members.first.userId;

      // Default split between is everyone
      _selectedSplitUserIds.clear();
      for (var m in widget.members) {
        _selectedSplitUserIds.add(m.userId);
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _settleAmountController.dispose();
    super.dispose();
  }

  Future<void> _submitExpense() async {
    final desc = _descriptionController.text.trim();
    final amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (desc.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description and valid amount')),
      );
      return;
    }

    if (_selectedSplitUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member to split with')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _dbService.addExpense(
        roomId: widget.room.id,
        description: desc,
        amount: amount,
        splitUserIds: _selectedSplitUserIds.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added! Pending approvals.')),
      );

      widget.onExpenseAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add expense: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitSettlement() async {
    final amountText = _settleAmountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }

    if (_selectedFromUserId == _selectedToUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot settle up with yourself! Please pick a different member.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _dbService.addSettlement(
        roomId: widget.room.id,
        toUserId: _selectedToUserId!,
        amount: amount,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settlement recorded! Pending confirmation by receiver.')),
      );

      widget.onExpenseAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record settlement: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.members.isEmpty) {
      return Scaffold(
        backgroundColor: RoomerColors.background,
        body: Center(
          child: Text('No members found in the room', style: RoomerTextStyles.bodyMedium),
        ),
      );
    }

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
                child: isExpenseMode ? _expenseForm(context) : _settleForm(context),
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
        TextField(
          controller: _descriptionController,
          decoration: _inputDecoration('Groceries...'),
        ),
        const SizedBox(height: 20),
        const _Label('Amount (LKR)'),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration('0.00'),
        ),
        const SizedBox(height: 20),
        const _Label('Who Paid?'),
        const SizedBox(height: 8),
        _buildDropdown(
          value: _selectedPayerId,
          onChanged: (value) => setState(() => _selectedPayerId = value),
        ),
        const SizedBox(height: 20),
        const _Label('Split Between'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.members.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, index) {
            final member = widget.members[index];
            final isChecked = _selectedSplitUserIds.contains(member.userId);

            return InkWell(
              onTap: () {
                setState(() {
                  if (isChecked) {
                    _selectedSplitUserIds.remove(member.userId);
                  } else {
                    _selectedSplitUserIds.add(member.userId);
                  }
                });
              },
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0x144CD080) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isChecked ? RoomerColors.primary : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  member.profile?.username ?? 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isChecked ? RoomerColors.primaryDark : const Color(0xFF374151),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitExpense,
          style: ElevatedButton.styleFrom(
            backgroundColor: RoomerColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            minimumSize: const Size(double.infinity, 60),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Add Expense',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
      ],
    );
  }

  Widget _settleForm(BuildContext context) {
    // We only filter members that are NOT the logged in user to show in "To"
    final otherMembers = widget.members.where((m) => m.userId != _selectedFromUserId).toList();

    return Column(
      key: const ValueKey('settle'),
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
                  _buildDropdown(
                    value: _selectedFromUserId,
                    onChanged: (value) {
                      setState(() {
                        _selectedFromUserId = value;
                        // Reset "To" selection if it matches new "From"
                        if (_selectedFromUserId == _selectedToUserId) {
                          final others = widget.members.where((m) => m.userId != value).toList();
                          _selectedToUserId = others.isNotEmpty ? others.first.userId : widget.members.first.userId;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Icon(Icons.arrow_forward_rounded, color: Colors.grey),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('To'),
                  const SizedBox(height: 8),
                  _buildDropdown(
                    value: _selectedToUserId,
                    itemsList: otherMembers.isNotEmpty ? otherMembers : widget.members,
                    onChanged: (value) => setState(() => _selectedToUserId = value),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const _Label('Amount (LKR)'),
        const SizedBox(height: 8),
        TextField(
          controller: _settleAmountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _inputDecoration('0.00'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitSettlement,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEA580C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
            minimumSize: const Size(double.infinity, 60),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Record Payment',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
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
        borderSide: BorderSide(
          color: isExpenseMode ? RoomerColors.primary : const Color(0xFFEA580C),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    List<RoomMember>? itemsList,
    required ValueChanged<String?> onChanged,
  }) {
    final list = itemsList ?? widget.members;
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
          items: list.map((m) {
            return DropdownMenuItem<String>(
              value: m.userId,
              child: Text(m.profile?.username ?? 'Unknown'),
            );
          }).toList(),
          onChanged: onChanged,
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
          child: Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFF4B5563),
          ),
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
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isActive ? gradient : null,
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontSize: 14,
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
