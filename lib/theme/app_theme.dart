import 'package:flutter/material.dart';

/// Colors taken from masterfabric.co (Tailwind slate/blue palette + Claude accent).
class MfColors {
  static const slate900 = Color(0xFF0F172A);
  static const slate800 = Color(0xFF1E293B); // logo color
  static const slate600 = Color(0xFF475569);
  static const slate500 = Color(0xFF64748B);
  static const slate400 = Color(0xFF94A3B8);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate50 = Color(0xFFF8FAFC);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue600 = Color(0xFF2563EB);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue50 = Color(0xFFEFF6FF);
  static const claude = Color(0xFFD97757);
  static const claudeSoft = Color(0xFFFBF1EC);
  static const claudeInk = Color(0xFF1F1E1D);
  static const terminal = Color(0xFF0B0D17);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MfColors.blue600,
      brightness: Brightness.light,
    ).copyWith(
      primary: MfColors.blue600,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: MfColors.slate900,
      onSurfaceVariant: MfColors.slate600,
      outlineVariant: MfColors.slate100,
      secondary: MfColors.claude,
    );

    final base = ThemeData(useMaterial3: true, colorScheme: scheme);
    final text = base.textTheme.apply(
      bodyColor: MfColors.slate900,
      displayColor: MfColors.slate900,
    );

    return base.copyWith(
      scaffoldBackgroundColor: Colors.white,
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          height: 1.08,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
        ),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyLarge: text.bodyLarge?.copyWith(
          color: MfColors.slate600,
          height: 1.5,
        ),
        bodyMedium: text.bodyMedium?.copyWith(
          color: MfColors.slate600,
          height: 1.45,
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        shadowColor: MfColors.slate100,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: MfColors.blue50,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? MfColors.blue700
                : MfColors.slate500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? MfColors.blue700
                : MfColors.slate500,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MfColors.slate900,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MfColors.slate900,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      dividerTheme: const DividerThemeData(color: MfColors.slate100),
    );
  }
}
