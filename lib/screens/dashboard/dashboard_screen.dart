import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme.dart';
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

  void _goToPage(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _buildPages() {
    return [
      HomePage(
        onAddPressed: () => _goToPage(1),
        onHistoryPressed: () => _goToPage(2),
        onNotificationPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationPage()),
          );
        },
      ),
      AddExpensePage(onBackToHome: () => _goToPage(0)),
      HistoryPage(onBackToHome: () => _goToPage(0)),
      SettingsPage(onBackToHome: () => _goToPage(0)),
      AnalyticsPage(onBackToHome: () => _goToPage(0)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _buildPages()),
      bottomNavigationBar: SafeArea(
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
