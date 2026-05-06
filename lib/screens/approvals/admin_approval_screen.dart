import 'package:flutter/material.dart';

class AdminApprovalScreen extends StatelessWidget {
  final String requesterName;

  const AdminApprovalScreen({super.key, required this.requesterName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // පිරිසිදු ලා කොළ පාටට හුරු පසුබිම [cite: 2026-04-22]
      backgroundColor: const Color(0xFFF4FAF6), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 1. උඩින් තියෙන Close (X) බටන් එක
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.black54, size: 20),
                  ),
                ),
              ),
              
              const Spacer(flex: 2),

              // 2. Illustration වෙනුවට Icon එකක් (ඇප් එක හිර නොවෙන්න) [cite: 2026-04-22]
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Image.asset(
                    'assets/admin-approval-screen-illustration.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const Spacer(flex: 2),
              
              // 3. මාතෘකාව (Login වල විදිහටම) [cite: 2026-04-22]
              const Text(
                'New Join Request',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              
              const SizedBox(height: 15),
              
              // 4. විස්තරය
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Hey Admin, $requesterName wants to join your room. Accept to give access to the group dashboard.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16, 
                    color: Colors.grey, 
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              
              const Spacer(flex: 4),
              
              // 5. Buttons (එක යට එක Row දෙකක් වගේ)
              
              // Accept Button - Roomer Green
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // මෙතන Firebase Approve logic එක ලියන්න [cite: 2026-04-06]
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CD080),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Accept invitation! (YEY)', 
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Decline Button - Text Style
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text(
                    'Refuse with message :(', 
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