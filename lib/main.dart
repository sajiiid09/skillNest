import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pages/splash_screen.dart';
import 'utils/constants.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.background,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseText = GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(
        color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        color: AppColors.textPrimary,
      ),
      bodySmall: GoogleFonts.poppins(
        color: AppColors.textSecondary,
      ),
      titleLarge: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.poppins(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: GoogleFonts.poppins(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );

    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
    );

    return MaterialApp(
      title: 'Smart Job Discovery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.cardBg,
          onPrimary: AppColors.onPrimary,
          onSecondary: AppColors.primary,
          onSurface: AppColors.textPrimary,
          error: AppColors.statusError,
          onError: Colors.white,
        ),
        textTheme: baseText,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        dividerColor: AppColors.border,
        cardColor: AppColors.cardBg,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          centerTitle: false,
          elevation: AppElevation.flat,
          scrolledUnderElevation: AppElevation.flat,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: AppColors.background,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
        cardTheme: const CardTheme(
          color: AppColors.cardBg,
          elevation: AppElevation.card,
          margin: EdgeInsets.zero,
          shape: shape,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.cardBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          hintStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
          labelStyle: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          prefixIconColor: AppColors.textSecondary,
          suffixIconColor: AppColors.textSecondary,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
            borderSide: BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            elevation: AppElevation.flat,
            shadowColor: Colors.transparent,
            textStyle: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          dividerColor: AppColors.border,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: AppElevation.raised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          contentTextStyle: GoogleFonts.poppins(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(AppRadii.md)),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
