import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';
import '../../models/room.dart';
import '../../models/room_member.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../auth/welcome_screen.dart';
import '../room_choice/room_choice_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.room,
    required this.members,
    required this.onBackToHome,
    required this.onSettingsChanged,
  });

  final Room room;
  final List<RoomMember> members;
  final VoidCallback onBackToHome;
  final VoidCallback onSettingsChanged;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DatabaseService _dbService = DatabaseService();
  final AuthService _authService = AuthService();

  bool _isLeaving = false;
  bool _isLoggingOut = false;

  void _copyRoomCode() {
    Clipboard.setData(ClipboardData(text: widget.room.code));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room ID copied to clipboard!')),
    );
  }

  Future<void> _handleLeaveRoom() async {
    // Show confirmation dialog first
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Leave Room?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to leave this room? Your transaction logs will remain, but you will lose dashboard access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: RoomerColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Leave', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLeaving = true;
    });

    try {
      await _dbService.leaveRoom(widget.room.id);
      
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoomChoiceScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to leave room: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLeaving = false;
        });
      }
    }
  }

  Future<void> _handleLogOut() async {
    setState(() {
      _isLoggingOut = true;
    });

    try {
      await _authService.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Log out failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  Future<void> _handleRemoveMember(RoomMember member) async {
    final username = member.profile?.username ?? 'Unknown';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Remove $username?', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to remove $username from this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: RoomerColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Remove', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _dbService.rejectRoomMember(member.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed $username from room')),
        );
      }
      widget.onSettingsChanged();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove member: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = _dbService.currentUserId;
    final isAdmin = widget.room.createdBy == currentUserId;
    final approvedMembers = widget.members.where((m) => m.status == 'approved').toList();

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
                  Text('Settings', style: RoomerTextStyles.pageTitle),
                ],
              ),
            ),
            
            // Invite Section
            _SectionCard(
              title: 'Add Roommates',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share this 6-digit Room ID with your friends to let them request to join:',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.room.code,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 8,
                              color: RoomerColors.primaryDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _PrimaryActionButton(
                        label: 'Copy',
                        onTap: _copyRoomCode,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Manage Members Section
            _SectionCard(
              title: 'Manage Roommates',
              child: Column(
                children: approvedMembers.map((m) {
                  final isMe = m.userId == currentUserId;
                  final bool canRemove = isAdmin && !isMe;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF3F4F6)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFFDBEAFE),
                                child: Text(
                                  (m.profile?.username ?? 'U').isNotEmpty 
                                      ? (m.profile?.username ?? 'U')[0].toUpperCase() 
                                      : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${m.profile?.username ?? 'Unknown'}${isMe ? ' (You)' : ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                          if (canRemove)
                            GestureDetector(
                              onTap: () => _handleRemoveMember(m),
                              child: const Text(
                                'Remove',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (isMe && isAdmin)
                            const Text(
                              'Room Owner',
                              style: TextStyle(
                                color: RoomerColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            const Text(
                              'Roommate',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Danger Zone Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: RoomerColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: RoomerColors.dangerSoft),
                boxShadow: RoomerShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: RoomerColors.danger,
                        ),
                  ),
                  const SizedBox(height: 18),
                  
                  // Leave Room Button
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _isLeaving ? null : _handleLeaveRoom,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLeaving
                                ? const CircularProgressIndicator(color: RoomerColors.danger)
                                : const Text(
                                    'Leave Current Room',
                                    style: TextStyle(
                                      color: RoomerColors.danger,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Log Out Button
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: RoomerColors.danger,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: _isLoggingOut ? null : _handleLogOut,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: _isLoggingOut
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Sign Out',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    'Roomer v2.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Developed by The Zenon Studio',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFD1D5DB),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: roomerCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: RoomerColors.text,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: RoomerColors.primaryGradient,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
