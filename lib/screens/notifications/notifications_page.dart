import 'package:flutter/material.dart';

import '../../core/theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
    required this.onBackToHome,
  });

  final VoidCallback onBackToHome;

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  int _selectedTab = 0;

  final tabs = const [
    'Requests',
    'Transactions',
    'Alerts',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          RoomerColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    RoomerColors.screenPadding,
                children: [
                  // HEADER
                  Padding(
                    padding:
                        const EdgeInsets.only(
                      top: 18,
                      bottom: 20,
                    ),
                    child: Row(
                      children: [
                        _BackButton(
                          onTap: widget
                              .onBackToHome,
                        ),
                        const SizedBox(
                            width: 12),
                        Text(
                          'Notifications',
                          style:
                              RoomerTextStyles
                                  .pageTitle,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Read all',
                          ),
                        ),
                      ],
                    ),
                  ),

                  // TABS
                  Container(
                    padding:
                        const EdgeInsets.all(
                            5),
                    decoration:
                        BoxDecoration(
                      color: const Color(
                          0xFFF1F5F9),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  16),
                    ),
                    child: Row(
                      children:
                          List.generate(
                        tabs.length,
                        (index) =>
                            Expanded(
                          child:
                              GestureDetector(
                            onTap: () {
                              setState(
                                  () {
                                _selectedTab =
                                    index;
                              });
                            },
                            child:
                                AnimatedContainer(
                              duration:
                                  const Duration(
                                      milliseconds:
                                          220),
                              padding:
                                  const EdgeInsets.symmetric(
                                vertical:
                                    10,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: _selectedTab ==
                                        index
                                    ? Colors
                                        .white
                                    : Colors
                                        .transparent,
                                borderRadius:
                                    BorderRadius.circular(
                                        12),
                              ),
                              child:
                                  Text(
                                tabs[index],
                                textAlign:
                                    TextAlign
                                        .center,
                                style:
                                    TextStyle(
                                  fontSize:
                                      12,
                                  fontWeight:
                                      FontWeight
                                          .w700,
                                  color: _selectedTab ==
                                          index
                                      ? RoomerColors
                                          .primary
                                      : RoomerColors
                                          .mutedText,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 18),

                  ..._buildItems(),

                  const SizedBox(
                      height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems() {
    if (_selectedTab == 0) {
      return const [
        _NotificationCard(
          title:
              'Join request from Nimal',
          subtitle:
              'Requested to join Room A102',
          time: '2 min ago',
          icon:
              Icons.person_add_alt_1,
          color:
              RoomerColors.primary,
          unread: true,
        ),
        SizedBox(height: 14),
        _NotificationCard(
          title:
              'Expense needs approval',
          subtitle:
              'Laky added Rs 2,400 groceries',
          time: '15 min ago',
          icon:
              Icons.verified_user,
          color:
              Color(0xFF3B82F6),
          unread: true,
        ),
      ];
    }

    if (_selectedTab == 1) {
      return const [
        _NotificationCard(
          title:
              'Payment received',
          subtitle:
              'Laky paid you Rs 1,500',
          time: '1 hour ago',
          icon:
              Icons.payments_rounded,
          color:
              RoomerColors.primary,
        ),
        SizedBox(height: 14),
        _NotificationCard(
          title:
              'Expense added',
          subtitle:
              'Dinner at Pizza Hut Rs 4,500',
          time: 'Today',
          icon:
              Icons.receipt_long,
          color:
              Color(0xFFF59E0B),
        ),
      ];
    }

    return const [
      _NotificationCard(
        title:
            'Monthly rent due tomorrow',
        subtitle:
            'Don’t forget to settle room rent',
        time: 'Today',
        icon:
            Icons.warning_amber,
        color:
            Color(0xFFEF4444),
        unread: true,
      ),
      SizedBox(height: 14),
      _NotificationCard(
        title:
            'All balances cleared 🎉',
        subtitle:
            'No pending dues remaining',
        time: 'Yesterday',
        icon:
            Icons.celebration,
        color:
            RoomerColors.primary,
      ),
    ];
  }
}

// BACK BUTTON
class _BackButton
    extends StatelessWidget {
  const _BackButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color:
          const Color(0xFFF3F4F6),
      shape:
          const CircleBorder(),
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

// CARD
class _NotificationCard
    extends StatelessWidget {
  const _NotificationCard({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    this.unread = false,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;
  final bool unread;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(
              18),
      decoration:
          roomerCardDecoration(),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration:
                BoxDecoration(
              color: color
                  .withOpacity(
                      .12),
              borderRadius:
                  BorderRadius
                      .circular(
                          16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),

          const SizedBox(
              width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          Text(
                        title,
                        style:
                            const TextStyle(
                          fontSize:
                              14,
                          fontWeight:
                              FontWeight
                                  .w700,
                          color:
                              RoomerColors.text,
                        ),
                      ),
                    ),
                    if (unread)
                      Container(
                        width:
                            8,
                        height:
                            8,
                        decoration:
                            const BoxDecoration(
                          color:
                              RoomerColors.primary,
                          shape: BoxShape
                              .circle,
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                    height: 6),

                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    fontSize:
                        12,
                    height:
                        1.45,
                    color:
                        RoomerColors
                            .mutedText,
                  ),
                ),

                const SizedBox(
                    height: 8),

                Text(
                  time,
                  style:
                      const TextStyle(
                    fontSize:
                        11,
                    fontWeight:
                        FontWeight
                            .w600,
                    color:
                        RoomerColors
                            .mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}