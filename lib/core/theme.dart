import 'package:flutter/material.dart';

// Color palette
class AppColors {
  static const primary = Color(0xFF3A5A98);
  static const secondary = Color(0xFF6C8CD5);
  static const background = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const error = Color(0xFFD32F2F);
  static const onPrimary = Colors.white;
  static const onSecondary = Colors.white;
  static const onBackground = Color(0xFF222222);
  static const onSurface = Color(0xFF222222);
  static const onError = Colors.white;

  // Dark mode
  static const darkBackground = Color(0xFF181A20);
  static const darkSurface = Color(0xFF23262F);
  static const darkOnBackground = Color(0xFFF7F8FA);
  static const darkOnSurface = Color(0xFFF7F8FA);
}

// Spacing and radius
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double cardRadius = 20;
  static const double buttonRadius = 16;
}

// Responsive scaling helper
class Scale {
  static double of(BuildContext context, double size) {
    final width = MediaQuery.of(context).size.width;
    // Base scaling on 375pt width (iPhone 11/12/13/14)
    return size * (width / 375.0).clamp(0.85, 1.25);
  }
}

// Text styles
class AppTextStyles {
  static TextStyle headline(BuildContext context) => TextStyle(
    fontSize: Scale.of(context, 28),
    fontWeight: FontWeight.bold,
    color: Theme.of(context).colorScheme.onBackground,
  );
  static TextStyle title(BuildContext context) => TextStyle(
    fontSize: Scale.of(context, 20),
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onBackground,
  );
  static TextStyle body(BuildContext context) => TextStyle(
    fontSize: Scale.of(context, 16),
    color: Theme.of(context).colorScheme.onBackground,
  );
  static TextStyle label(BuildContext context) => TextStyle(
    fontSize: Scale.of(context, 14),
    color: Theme.of(context).colorScheme.onBackground,
  );
  static TextStyle button(BuildContext context) => TextStyle(
    fontSize: Scale.of(context, 18),
    fontWeight: FontWeight.w600,
    color: Theme.of(context).colorScheme.onPrimary,
  );
}

// Centralized ThemeData (light)
ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    background: AppColors.background,
    onBackground: AppColors.onBackground,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    error: AppColors.error,
    onError: AppColors.onError,
  ),
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Roboto',
  useMaterial3: true,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);

// Centralized ThemeData (dark)
ThemeData appDarkTheme = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    background: AppColors.darkBackground,
    onBackground: AppColors.darkOnBackground,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    error: AppColors.error,
    onError: AppColors.onError,
  ),
  scaffoldBackgroundColor: AppColors.darkBackground,
  fontFamily: 'Roboto',
  useMaterial3: true,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.onPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      side: const BorderSide(color: AppColors.primary, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
  ),
);
