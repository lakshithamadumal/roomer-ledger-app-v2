import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. උඩ කොටසේ පින්තූරය (Image එකේ වගේ ලොකු image එකක්)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.55, // Screen එකෙන් භාගයකට වඩා ටිකක් වැඩි ඉඩක්
            child: Image.asset(
              'assets/welcome-screen-illustration.png', // ඔයා ගාව තියෙන ලොකු image එකේ නම මෙතනට දාන්න
              fit: BoxFit.cover,
            ),
          ),

          // 2. පල්ලෙහා සුදු පාට කොටස (අර image එකයි මේකයි වෙන් වෙන තැන rounded corners තියෙනවා)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.5, // Screen එකෙන් භාගයක්
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF4FAF6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), // Image එකේ වගේ rounded corners
                  topRight: Radius.circular(40),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // මැද තියෙන පොඩි ඉර (Handle)
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'We\'re glad to see you. Pick up where you left off and enjoy a seamless experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 40),

                    // Sign In Button - Green
                    _buildButton('Sign In', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    }, isPrimary: true),

                    const SizedBox(height: 15),

                    // Create Account Button - Outline
                    _buildButton('Create an Account', () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                    }, isPrimary: false),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed, {required bool isPrimary}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? const Color(0xFF4CD080) : Colors.white,
          foregroundColor: isPrimary ? Colors.white : Colors.black,
          elevation: 0,
          side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFFEEEEEE)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}