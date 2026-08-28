import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const deepBlue = Color(0xFF071B3D);
  static const royalBlue = Color(0xFF102F66);
  static const skyBlue = Color(0xFF4F8EFF);
  static const gold = Color(0xFFE4B34F);
  static const softGold = Color(0xFFFFD978);
  static const ivory = Color(0xFFFFFBF4);

  static SystemUiOverlayStyle systemOverlayStyle(Brightness brightness) {
    final iconBrightness = brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: brightness,
      systemNavigationBarIconBrightness: iconBrightness,
    );
  }

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: royalBlue,
      brightness: Brightness.light,
      primary: royalBlue,
      secondary: gold,
      surface: const Color(0xFFF8FAFF),
      onSurface: const Color(0xFF172033),
      onSurfaceVariant: const Color(0xFF5F6B7C),
    );
    return _base(colorScheme, isDark: false);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: softGold,
      brightness: Brightness.dark,
      primary: softGold,
      secondary: gold,
      surface: const Color(0xFF071426),
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
      splashFactory: InkSparkle.splashFactory,
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
        systemOverlayStyle: systemOverlayStyle(colorScheme.brightness),
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
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.84),
        labelStyle: TextStyle(color: mutedTextColor),
        hintStyle: TextStyle(color: mutedTextColor),
        prefixIconColor: iconColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: mutedTextColor.withValues(alpha: 0.45)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF1E293B)
            : const Color(0xFF111827),
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          backgroundColor: isDark ? softGold : royalBlue,
          foregroundColor: isDark ? deepBlue : Colors.white,
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
          disabledForegroundColor: mutedTextColor.withValues(alpha: 0.6),
          disabledBackgroundColor: isDark
              ? const Color(0xFF12243D)
              : const Color(0xFFDDE3EC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: isDark ? softGold : royalBlue,
        foregroundColor: isDark ? deepBlue : Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        elevation: 0,
        backgroundColor: isDark
            ? const Color(0xFF08182C).withValues(alpha: 0.98)
            : Colors.white.withValues(alpha: 0.98),
        indicatorColor: isDark
            ? softGold.withValues(alpha: 0.18)
            : royalBlue.withValues(alpha: 0.10),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? (isDark ? softGold : royalBlue) : mutedTextColor,
            size: selected ? 26 : 23,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            color: selected ? (isDark ? softGold : royalBlue) : mutedTextColor,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: mutedTextColor.withValues(alpha: 0.14),
        thickness: 1,
        space: 1,
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
