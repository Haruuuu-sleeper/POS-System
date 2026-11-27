import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

class PosColors {
  static const abyssBlack = Color(0xFF070B12);
  static const obsidianSurface = Color(0xFF0E1522);
  static const elevatedCard = Color(0xFF141E30);
  static const hoverSurface = Color(0xFF1A2740);
  static const borderSubtle = Color(0xFF23324D);

  static const electricBlue = Color(0xFF3B82F6);
  static const cobaltGlow = Color(0xFF2563EB);
  static const skyPulse = Color(0xFF60A5FA);
  static const deepNavyTint = Color(0xFF132442);

  static const textPrimary = Color(0xFFF3F6FC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted = Color(0xFF64748B);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
}

class PosTypography {
  static TextStyle display(
    BuildContext context, {
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color ?? PosColors.textPrimary,
      letterSpacing: -0.4,
    );
  }

  static TextStyle body(
    BuildContext context, {
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? PosColors.textPrimary,
    );
  }

  static TextStyle mono(
    BuildContext context, {
    double size = 15,
    FontWeight weight = FontWeight.w700,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color ?? PosColors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }
}

ThemeData buildBlueBlackTheme() {
  final baseText = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: PosColors.abyssBlack,
    colorScheme: const ColorScheme.dark(
      primary: PosColors.electricBlue,
      onPrimary: Colors.white,
      primaryContainer: PosColors.deepNavyTint,
      onPrimaryContainer: PosColors.skyPulse,
      secondary: PosColors.skyPulse,
      onSecondary: PosColors.abyssBlack,
      surface: PosColors.obsidianSurface,
      onSurface: PosColors.textPrimary,
      surfaceContainerHighest: PosColors.elevatedCard,
      onSurfaceVariant: PosColors.textSecondary,
      outline: PosColors.borderSubtle,
      error: PosColors.danger,
    ),
    textTheme: baseText.copyWith(
      headlineSmall: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: PosColors.textPrimary,
        letterSpacing: -0.4,
      ),
      titleLarge: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: PosColors.textPrimary,
        letterSpacing: -0.3,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w600,
        color: PosColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(color: PosColors.textPrimary),
      bodySmall: GoogleFonts.inter(color: PosColors.textSecondary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: PosColors.obsidianSurface,
      foregroundColor: PosColors.textPrimary,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: PosColors.textPrimary,
        letterSpacing: -0.3,
      ),
    ),
    cardTheme: CardThemeData(
      color: PosColors.elevatedCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: PosColors.borderSubtle),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: PosColors.borderSubtle,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PosColors.obsidianSurface,
      labelStyle: const TextStyle(color: PosColors.textSecondary),
      hintStyle: const TextStyle(color: PosColors.textMuted),
      prefixIconColor: PosColors.skyPulse,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PosColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PosColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: PosColors.electricBlue, width: 1.8),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: PosColors.electricBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: PosColors.skyPulse,
        side: const BorderSide(color: PosColors.borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: PosColors.elevatedCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: PosColors.borderSubtle),
      ),
    ),
  );
}
