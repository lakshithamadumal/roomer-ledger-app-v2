import 'package:flutter/material.dart';
import '../approvals/waiting_screen.dart';
import '../room_setup/room_setup_screen.dart';

class RoomChoiceScreen extends StatelessWidget {
  const RoomChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF4FAF6,
      ), // Off-white green [cite: 2026-04-22]
      body: SafeArea(
        child: SingleChildScrollView(
          // Keyboard එක එද්දී scroll වෙන්න [cite: 2026-04-06]
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                const SizedBox(height: 80),
                const Center(
                  child: Text(
                    'Join a Room',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 100), // මැදට ගන්න ඉඩ [cite: 2026-04-22]

                const Text(
                  'Enter 6-Digit Room ID',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),

                // ඇත්තටම පේන TextField එක [cite: 2026-04-22]
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    autofocus:
                        true, // Screen එකට ආපු ගමන් keyboard එක එනවා [cite: 2026-04-06]
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12, // අංක අතර ඉඩ [cite: 2026-04-22]
                      color: Color(0xFF2FB56B),
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "000000",
                      hintStyle: TextStyle(
                        color: Colors.grey[300],
                        letterSpacing: 12,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 20),
                      // Click වුණාම කොළ පාට border එක [cite: 2026-04-22]
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF4CD080),
                          width: 2.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                _buildPrimaryButton('Join Room', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WaitingScreen(),
                    ),
                  );
                }),

                const SizedBox(height: 60),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Want to host? ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoomSetupScreen(),
                        ),
                      ),
                      child: const Text(
                        "Create Room",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CD080),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
