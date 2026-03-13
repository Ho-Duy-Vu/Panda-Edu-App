import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: AppColors.matchaMedium,
    scaffoldBackgroundColor: AppColors.backgroundLight,
    fontFamily: 'Poppins',
    
    colorScheme: ColorScheme.light(
      primary: AppColors.matchaMedium,
      secondary: AppColors.accentOrange,
      surface: AppColors.pandaWhite,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.pandaBlack,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.matchaMedium,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.pandaWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.matchaMedium,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.matchaLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.matchaLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.matchaMedium, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.error),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: AppColors.matchaDark,
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    fontFamily: 'Poppins',
    
    colorScheme: ColorScheme.dark(
      primary: AppColors.matchaLight,
      secondary: AppColors.accentOrange,
      surface: const Color(0xFF2C2C2C),
      error: AppColors.error,
      onPrimary: AppColors.pandaBlack,
      onSecondary: Colors.white,
      onSurface: AppColors.pandaWhite,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.matchaDark,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Poppins',
        color: Colors.white,
      ),
    ),

    cardTheme: CardThemeData(
      color: const Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accentOrange,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusXLarge),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.matchaLight,
        foregroundColor: AppColors.pandaBlack,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingLarge,
          vertical: AppSizes.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.matchaDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.matchaDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.matchaLight, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        borderSide: BorderSide(color: AppColors.error),
      ),
    ),
  );
}
