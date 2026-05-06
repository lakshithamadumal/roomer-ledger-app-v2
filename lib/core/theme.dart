import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoomerColors {
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const border = Color(0xFFE5E7EB);
  static const text = Color(0xFF111827);
  static const mutedText = Color(0xFF6B7280);
  static const primary = Color(0xFF4CD080);
  static const primaryDark = Color(0xFF2FB56B);
  static const primarySoft = Color(0xFFE8F7EF);
  static const successSoft = Color(0xFFDCFCE7);
  static const success = Color(0xFF16A34A);
  static const warningSoft = Color(0xFFFEF3C7);
  static const warning = Color(0xFFD97706);
  static const danger = Color(0xFFEF4444);
  static const dangerSoft = Color(0xFFFEE2E2);
  static const orangeSoft = Color(0xFFFFEDD5);
  static const orange = Color(0xFFF97316);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
  );

  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(16, 0, 16, 140);
}

class RoomerShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> nav = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 30,
      offset: const Offset(0, 12),
    ),
  ];

  static List<BoxShadow> header = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}

class RoomerTextStyles {
  static TextStyle get homeBrandTitle => GoogleFonts.inter(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get homeHeroLkr => GoogleFonts.inter(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get homeHeroAmount => GoogleFonts.inter(
    color: Colors.white,
    fontSize: 48,
    height: 1,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get homeActiveDebtChip => GoogleFonts.inter(
    color: const Color(0xFFEA580C),
    fontWeight: FontWeight.w600,
    fontSize: 14,
  );

  static TextStyle get homeBalanceAmount => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
  );

  static TextStyle get homeSettlementAmount => GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1,
    fontFeatures: const [
      FontFeature.liningFigures(),
      FontFeature.tabularFigures(),
    ],
    color: const Color(0xFF111827),
  );

  static TextStyle get pageTitle => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: RoomerColors.text,
  );

  static TextStyle get sectionTitle => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: RoomerColors.text,
  );

  static TextStyle get cardTitle => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: RoomerColors.text,
  );

  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: RoomerColors.mutedText,
  );
}

BoxDecoration roomerCardDecoration({Color? color, BorderRadius? borderRadius}) {
  return BoxDecoration(
    color: color ?? RoomerColors.surface,
    borderRadius: borderRadius ?? BorderRadius.circular(28),
    border: Border.all(color: RoomerColors.border),
    boxShadow: RoomerShadows.card,
  );
}
