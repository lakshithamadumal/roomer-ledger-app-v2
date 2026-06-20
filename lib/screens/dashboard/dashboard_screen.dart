import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../room_choice/room_choice_screen.dart';
import '../approvals/waiting_screen.dart';
import 'add_expense_page.dart';
import 'analytics_page.dart';
import 'history_page.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'settings_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  final DatabaseService _dbService = DatabaseService();

  Room? _room;
  List<RoomMember> _members = [];
  List<TransactionModel> _transactions = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final roomData = await _dbService.getJoinedRoomForUser();
      
      if (!mounted) return;

      if (roomData == null) {
        // Not in a room, send to choice screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const RoomChoiceScreen()),
          (route) => false,
        );
        return;
      }

      final myMember = roomData['member'] as RoomMember;
      final room = roomData['room'] as Room;

      if (myMember.status != 'approved') {
        // Join request is still pending
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WaitingScreen()),
          (route) => false,
        );
        return;
      }

      // Fetch room members and transactions
      final membersList = await _dbService.getRoomMembers(room.id);
      final transactionsList = await _dbService.getRoomTransactions(room.id);

      if (!mounted) return;

      setState(() {
        _room = room;
        _members = membersList;
        _transactions = transactionsList;
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

  void _goToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _buildPages() {
    if (_isLoading) {
      return [
        const Center(child: CircularProgressIndicator(color: RoomerColors.primary)),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
      ];
    }

    if (_errorMessage != null) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 60, color: RoomerColors.danger),
                const SizedBox(height: 16),
                Text(
                  'Error loading data:\n$_errorMessage',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: RoomerColors.text),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadData,
                  style: ElevatedButton.styleFrom(backgroundColor: RoomerColors.primary),
                  child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
      ];
    }

    return [
      HomePage(
        room: _room!,
        members: _members,
        transactions: _transactions,
        onAddPressed: () => _goToPage(1),
        onHistoryPressed: () => _goToPage(2),
        onNotificationPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NotificationPage(room: _room!, members: _members),
            ),
          );
          _loadData();
        },
      ),
      AddExpensePage(
        room: _room!,
        members: _members.where((m) => m.status == 'approved').toList(),
        onBackToHome: () => _goToPage(0),
        onExpenseAdded: () {
          _loadData();
          _goToPage(0);
        },
      ),
      HistoryPage(
        room: _room!,
        transactions: _transactions,
        members: _members,
        onBackToHome: () => _goToPage(0),
        onTransactionDeleted: () => _loadData(),
      ),
      SettingsPage(
        room: _room!,
        members: _members,
        onBackToHome: () => _goToPage(0),
        onSettingsChanged: () => _loadData(),
      ),
      AnalyticsPage(
        room: _room!,
        transactions: _transactions.where((t) => t.status == 'approved').toList(),
        members: _members,
        onBackToHome: () => _goToPage(0),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator(color: RoomerColors.primary))
          : IndexedStack(index: _currentIndex, children: _buildPages()),
      bottomNavigationBar: _isLoading 
          ? null 
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  height: 94,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .84),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: RoomerColors.border),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: .06),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        _NavButton(
                                          icon: Icons.home_rounded,
                                          label: 'Home',
                                          isActive: _currentIndex == 0,
                                          onTap: () => _goToPage(0),
                                        ),
                                        _NavButton(
                                          icon: Icons.bar_chart_rounded,
                                          label: 'Stats',
                                          isActive: _currentIndex == 4,
                                          onTap: () => _goToPage(4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 80),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        _NavButton(
                                          icon: Icons.history_rounded,
                                          label: 'History',
                                          isActive: _currentIndex == 2,
                                          onTap: () => _goToPage(2),
                                        ),
                                        _NavButton(
                                          icon: Icons.settings_rounded,
                                          label: 'Settings',
                                          isActive: _currentIndex == 3,
                                          onTap: () => _goToPage(3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        child: Container(
                          height: 58,
                          width: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                RoomerColors.primary,
                                RoomerColors.primary.withValues(alpha: .88),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: RoomerColors.primary.withValues(alpha: .28),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => _goToPage(1),
                              child: const Center(
                                child: Icon(
                                  Icons.add_rounded,
                                  size: 26,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final activeColor = RoomerColors.primary;
    final inactiveColor = RoomerColors.mutedText;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isActive ? activeColor : inactiveColor,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
