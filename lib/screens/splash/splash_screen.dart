import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../auth/welcome_screen.dart';
import '../room_choice/room_choice_screen.dart';
import '../approvals/waiting_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _checkStatusAndNavigate();
  }

  Future<void> _checkStatusAndNavigate() async {
    // Wait for 2.5 seconds to show splash animation
    await Future.delayed(const Duration(milliseconds: 2500));

    if (!mounted) return;

    final user = _authService.currentUser;
    if (user == null) {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else {
      // User is logged in, check room status
      try {
        final roomData = await _dbService.getJoinedRoomForUser();
        if (roomData == null) {
          // No room
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const RoomChoiceScreen()),
          );
        } else {
          final member = roomData['member'];
          if (member.status == 'approved') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WaitingScreen()),
            );
          }
        }
      } catch (e) {
        print('Error in splash screen navigation check: $e');
        // fallback to welcome screen on database error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4CD080), Color(0xFF2FB56B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Image.asset('assets/roomer-light-logo.png'),
              ),
            ),

            const Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Text(
                'Split expenses smartly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            Positioned(
              bottom: 120,
              left: 0,
              right: 0,
              child: Center(
                child: SizedBox(
                  width: 25,
                  height: 25,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
