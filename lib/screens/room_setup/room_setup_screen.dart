import 'package:flutter/material.dart';

class RoomSetupScreen extends StatelessWidget {
  const RoomSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              // Back Button උඩින් [cite: 2026-04-22]
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              ),
              
              const SizedBox(height: 40),
              // මාතෘකාව [cite: 2026-04-22]
              const Center(
                child: Text(
                  'Setup Your Room',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              
              const Spacer(),
              
              // Room Name Input [cite: 2026-04-22]
              const Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('Room Name', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. The Mora 2026',
                  filled: true,
                  fillColor: Colors.white,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: Color(0xFF4CD080), width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              
              // Create Room Button [cite: 2026-04-22]
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Dashboard (Index) එකට යාම [cite: 2026-04-06]
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CD080),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text('Create Room', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}