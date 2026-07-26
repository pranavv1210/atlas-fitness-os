import 'package:flutter/material.dart';

import 'atlas_colors.dart';

class AtlasTheme {
  const AtlasTheme._();

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scaffold: AtlasColors.background,
    surface: AtlasColors.surface,
    onSurface: AtlasColors.ink,
    muted: AtlasColors.inkMuted,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scaffold: const Color(0xFF08090D),
    surface: const Color(0xFF14161D),
    onSurface: const Color(0xFFF8F8F6),
    muted: const Color(0xFFB8B6AF),
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color scaffold,
    required Color surface,
    required Color onSurface,
    required Color muted,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AtlasColors.accent,
      brightness: brightness,
      surface: surface,
    ).copyWith(
      primary: AtlasColors.accent,
      secondary: AtlasColors.success,
      error: AtlasColors.error,
      surface: surface,
      onSurface: onSurface,
    );

    final baseTextTheme =
        brightness == Brightness.dark
            ? Typography.whiteCupertino
            : Typography.blackCupertino;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffold,
      fontFamily: 'Roboto',
      textTheme: baseTextTheme.copyWith(
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: onSurface,
          letterSpacing: 0,
          height: 1.02,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: onSurface,
          letterSpacing: 0,
          height: 1.05,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: 0,
          height: 1.12,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: onSurface,
          letterSpacing: 0,
          height: 1.15,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: onSurface,
          letterSpacing: 0,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: onSurface,
          height: 1.35,
          letterSpacing: 0,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: muted,
          height: 1.35,
          letterSpacing: 0,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AtlasColors.hairline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: surface.withValues(alpha: 0.92),
        indicatorColor: AtlasColors.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color:
                states.contains(WidgetState.selected)
                    ? AtlasColors.accent
                    : AtlasColors.inkMuted,
            fontSize: 12,
            fontWeight:
                states.contains(WidgetState.selected)
                    ? FontWeight.w700
                    : FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color:
                states.contains(WidgetState.selected)
                    ? AtlasColors.accent
                    : AtlasColors.inkMuted,
            size: 23,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AtlasColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          elevation: 0,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          minimumSize: const Size.fromHeight(58),
          side: const BorderSide(color: AtlasColors.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            brightness == Brightness.dark
                ? const Color(0xFF1B1E27)
                : AtlasColors.surfaceWarm,
        labelStyle: TextStyle(color: muted, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: muted.withValues(alpha: 0.72)),
        suffixStyle: TextStyle(color: muted, fontWeight: FontWeight.w700),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color:
                brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AtlasColors.hairline,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color:
                brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AtlasColors.hairline,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AtlasColors.accent, width: 1.4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor:
            brightness == Brightness.dark ? surface : AtlasColors.ink,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        modalBarrierColor: const Color(0x66171614),
        showDragHandle: true,
        dragHandleColor: AtlasColors.surfaceMuted,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shadowColor: AtlasColors.ink.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
