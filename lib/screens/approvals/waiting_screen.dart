import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../room_choice/room_choice_screen.dart';

class WaitingScreen extends StatefulWidget {
  const WaitingScreen({super.key});

  @override
  State<WaitingScreen> createState() => _WaitingScreenState();
}

class _WaitingScreenState extends State<WaitingScreen> {
  final DatabaseService _dbService = DatabaseService();
  Timer? _timer;
  String? _roomId;
  String? _memberId;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _startApprovalCheck();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startApprovalCheck() {
    // Check membership status immediately and then periodically
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    try {
      final roomData = await _dbService.getJoinedRoomForUser();
      if (roomData == null) {
        // No room membership found, redirect back to choice
        _timer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RoomChoiceScreen()),
          );
        }
        return;
      }

      final member = roomData['member'];
      _roomId = member.roomId;
      _memberId = member.id;

      if (member.status == 'approved') {
        _timer?.cancel();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        }
      }
    } catch (e) {
      print('Error checking approval status: $e');
    }
  }

  Future<void> _handleCancelRequest() async {
    if (_roomId == null && _memberId == null) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isCancelling = true;
    });

    try {
      _timer?.cancel();
      if (_memberId != null) {
        await _dbService.rejectRoomMember(_memberId!);
      }
      
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const RoomChoiceScreen()),
        (route) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to cancel request: ${e.toString()}')),
        );
      }
      setState(() {
        _isCancelling = false;
      });
      _startApprovalCheck(); // Resume checking if cancel failed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              const Spacer(flex: 2),

              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/waiting-screen-illustration.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.hourglass_empty_rounded,
                          size: 80,
                          color: Color(0xFF4CD080),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const Spacer(flex: 2),

              const Center(
                child: Text(
                  'Pending Request',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Your request has been sent to the Admin. Please wait until they approve your membership to access the room.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: _isCancelling ? null : _handleCancelRequest,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: _isCancelling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        )
                      : const Text(
                          'Cancel Request',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
