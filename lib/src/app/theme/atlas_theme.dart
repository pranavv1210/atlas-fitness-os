import 'package:flutter/material.dart';

import 'atlas_colors.dart';

class AtlasTheme {
  const AtlasTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AtlasColors.accent,
      brightness: Brightness.light,
      surface: AtlasColors.surface,
    ).copyWith(
      primary: AtlasColors.accent,
      secondary: AtlasColors.success,
      error: AtlasColors.error,
      surface: AtlasColors.surface,
      onSurface: AtlasColors.ink,
    );

    final baseTextTheme = Typography.blackCupertino;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AtlasColors.background,
      fontFamily: 'Roboto',
      textTheme: baseTextTheme.copyWith(
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: AtlasColors.ink,
          letterSpacing: 0,
          height: 1.02,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: AtlasColors.ink,
          letterSpacing: 0,
          height: 1.05,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: AtlasColors.ink,
          letterSpacing: 0,
          height: 1.12,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AtlasColors.ink,
          letterSpacing: 0,
          height: 1.15,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AtlasColors.ink,
          letterSpacing: 0,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          color: AtlasColors.ink,
          height: 1.35,
          letterSpacing: 0,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          color: AtlasColors.inkMuted,
          height: 1.35,
          letterSpacing: 0,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AtlasColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: AtlasColors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: AtlasColors.hairline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 76,
        backgroundColor: AtlasColors.surface.withValues(alpha: 0.92),
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
          foregroundColor: AtlasColors.ink,
          minimumSize: const Size.fromHeight(58),
          side: const BorderSide(color: AtlasColors.hairline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: AtlasColors.ink,
        contentTextStyle: baseTextTheme.bodyMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AtlasColors.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AtlasColors.surface,
        modalBarrierColor: Color(0x66171614),
        showDragHandle: true,
        dragHandleColor: AtlasColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AtlasColors.surface,
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
