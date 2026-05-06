import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'screens/splash/splash_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';


void main() {
  runApp(const RoomerApp());
}

class RoomerApp extends StatelessWidget {
  const RoomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roomer',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: GoogleFonts.inter().fontFamily,
        textTheme: GoogleFonts.interTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4CD080),
          brightness: Brightness.light,
        ),
      ),
      home: const DashboardScreen(), // මෙතනට ඔයාගේ screen එක දාන්න
    );
  }
}
