import 'package:flutter/material.dart';
import '../room_choice/room_choice_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // පින්තූරයේ වගේ Off-white green පසුබිම
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 100), // උඩින් ලොකු ඉඩක්
                // මැද තියෙන Sign In Text එක
                const Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 60), // ටෙක්ස්ට් එකට යටින් ඉඩ

                _buildInputLabel('Email Address'),
                _buildTextField(
                  'Enter Your Email Address',
                  Icons.email_outlined,
                ),

                const SizedBox(height: 25),

                _buildInputLabel('Password'),
                _buildTextField(
                  'Password',
                  Icons.lock_outline,
                  isPassword: true,
                ),

                const SizedBox(height: 12),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Main Green Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomChoiceScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CD080),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Or continue with
                _buildSocialDivider(),

                const SizedBox(height: 30),

                // Social Icons
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _SocialIcon(imagePath: 'assets/icon/google.png'),
                    _SocialIcon(imagePath: 'assets/icon/facebook.png'),
                    _SocialIcon(imagePath: 'assets/icon/apple.png'),
                  ],
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      ),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
  );

  Widget _buildTextField(
    String hint,
    IconData icon, {
    bool isPassword = false,
  }) => TextField(
    obscureText: isPassword,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white, // TextField එක සුදු පාටයි [cite: 2026-04-22]
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      // Click කරද්දී Green Stroke එකක් එනවා [cite: 2026-04-22]
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF4CD080), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    ),
  );

  Widget _buildSocialDivider() => Row(
    children: [
      Expanded(child: Divider(color: Colors.grey[300])),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Text(
          'Or continue with',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ),
      Expanded(child: Divider(color: Colors.grey[300])),
    ],
  );
}

class _SocialIcon extends StatelessWidget {
  final String imagePath;
  const _SocialIcon({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Image.asset(imagePath, width: 30, height: 30, fit: BoxFit.contain),
    );
  }
}
