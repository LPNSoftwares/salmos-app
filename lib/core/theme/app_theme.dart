import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const deepBlue = Color(0xFF071B3D);
  static const royalBlue = Color(0xFF102F66);
  static const gold = Color(0xFFD9AA48);
  static const softGold = Color(0xFFF1D48A);
  static const ivory = Color(0xFFFFF8EA);

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: royalBlue,
      brightness: Brightness.light,
      primary: royalBlue,
      secondary: gold,
      surface: ivory,
      onSurface: const Color(0xFF121826),
      onSurfaceVariant: const Color(0xFF354053),
    );
    return _base(colorScheme, isDark: false);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: softGold,
      brightness: Brightness.dark,
      primary: softGold,
      secondary: gold,
      surface: const Color(0xFF0B1830),
      onSurface: const Color(0xFFF8FAFC),
      onSurfaceVariant: const Color(0xFFD7DEE9),
    );
    return _base(colorScheme, isDark: true);
  }

  static ThemeData _base(ColorScheme colorScheme, {required bool isDark}) {
    final textColor = colorScheme.onSurface;
    final mutedTextColor = colorScheme.onSurfaceVariant;
    final iconColor = isDark ? softGold : royalBlue;
    final baseTextTheme = GoogleFonts.cormorantGaramondTextTheme();
    final textTheme =
        _forceTextColor(
          baseTextTheme.copyWith(
            bodyMedium: GoogleFonts.inter(),
            bodyLarge: GoogleFonts.inter(),
            labelLarge: GoogleFonts.inter(fontWeight: FontWeight.w700),
            titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
          textColor,
        ).copyWith(
          bodySmall: GoogleFonts.inter(color: mutedTextColor),
          labelSmall: GoogleFonts.inter(color: mutedTextColor),
          labelMedium: GoogleFonts.inter(
            color: mutedTextColor,
            fontWeight: FontWeight.w700,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      iconTheme: IconThemeData(color: iconColor),
      primaryIconTheme: IconThemeData(color: iconColor),
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        foregroundColor: textColor,
        backgroundColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: iconColor),
        actionsIconTheme: IconThemeData(color: iconColor),
      ),
      listTileTheme: ListTileThemeData(
        textColor: textColor,
        iconColor: iconColor,
        titleTextStyle: GoogleFonts.inter(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        subtitleTextStyle: GoogleFonts.inter(
          color: mutedTextColor,
          fontSize: 13,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: mutedTextColor),
        hintStyle: TextStyle(color: mutedTextColor),
        prefixIconColor: iconColor,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: mutedTextColor.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colorScheme.secondary, width: 1.4),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: textColor),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? const Color(0xFF182642)
            : const Color(0xFFF0F3F8),
        selectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: textColor, fontWeight: FontWeight.w700),
        secondaryLabelStyle: TextStyle(color: textColor),
        iconTheme: IconThemeData(color: iconColor, size: 18),
        side: BorderSide(color: mutedTextColor.withValues(alpha: 0.22)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFF111827),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          backgroundColor: isDark
              ? const Color(0xFF18375F)
              : const Color(0xFFE9EDF5),
          foregroundColor: isDark ? Colors.white : textColor,
          disabledForegroundColor: mutedTextColor.withValues(alpha: 0.6),
          disabledBackgroundColor: isDark
              ? const Color(0xFF12243D)
              : const Color(0xFFDDE3EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(48),
          foregroundColor: iconColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  static TextTheme _forceTextColor(TextTheme theme, Color color) {
    return theme.copyWith(
      displayLarge: theme.displayLarge?.copyWith(color: color),
      displayMedium: theme.displayMedium?.copyWith(color: color),
      displaySmall: theme.displaySmall?.copyWith(color: color),
      headlineLarge: theme.headlineLarge?.copyWith(color: color),
      headlineMedium: theme.headlineMedium?.copyWith(color: color),
      headlineSmall: theme.headlineSmall?.copyWith(color: color),
      titleLarge: theme.titleLarge?.copyWith(color: color),
      titleMedium: theme.titleMedium?.copyWith(color: color),
      titleSmall: theme.titleSmall?.copyWith(color: color),
      bodyLarge: theme.bodyLarge?.copyWith(color: color),
      bodyMedium: theme.bodyMedium?.copyWith(color: color),
      bodySmall: theme.bodySmall?.copyWith(color: color),
      labelLarge: theme.labelLarge?.copyWith(color: color),
      labelMedium: theme.labelMedium?.copyWith(color: color),
      labelSmall: theme.labelSmall?.copyWith(color: color),
    );
  }
}
