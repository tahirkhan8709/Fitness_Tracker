import 'package:material_ui/material_ui.dart';

import 'data/fitness_store.dart';
import 'screens/home_shell.dart';
import 'widgets/fitness_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = FitnessStore();
  await store.load();
  runApp(FitnessApp(store: store));
}

class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key, required this.store});

  final FitnessStore store;

  @override
  Widget build(BuildContext context) {
    const defaultFont = 'Inter';

    final darkColorScheme = const ColorScheme.dark(
      primary: FitnessColors.steps,
      onPrimary: Color(0xFF032617),
      primaryContainer: Color(0xFF0B462C),
      onPrimaryContainer: Color(0xFF86F3B9),
      secondary: FitnessColors.calories,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFF4A2000),
      onSecondaryContainer: Color(0xFFFFB68C),
      tertiary: FitnessColors.activeTime,
      onTertiary: Colors.white,
      surface: FitnessColors.darkSurface1,
      onSurface: FitnessColors.darkTextPrimary,
      surfaceContainerLowest: FitnessColors.darkBackground,
      surfaceContainerLow: FitnessColors.darkSurface1,
      surfaceContainer: FitnessColors.darkSurface1,
      surfaceContainerHigh: FitnessColors.darkSurface2,
      surfaceContainerHighest: FitnessColors.darkSurface3,
      onSurfaceVariant: FitnessColors.darkTextSecondary,
      outline: FitnessColors.darkBorder,
      outlineVariant: FitnessColors.darkBorderSubtle,
      error: FitnessColors.error,
      onError: Colors.white,
    );

    final lightColorScheme = const ColorScheme.light(
      primary: Color(0xFF059669),
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFD1FAE5),
      onPrimaryContainer: Color(0xFF064E3B),
      secondary: FitnessColors.calories,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFEDD5),
      onSecondaryContainer: Color(0xFF7C2D12),
      tertiary: Color(0xFF0284C7),
      onTertiary: Colors.white,
      surface: FitnessColors.lightSurface1,
      onSurface: FitnessColors.lightTextPrimary,
      surfaceContainerLowest: FitnessColors.lightBackground,
      surfaceContainerLow: FitnessColors.lightSurface1,
      surfaceContainer: FitnessColors.lightSurface1,
      surfaceContainerHigh: FitnessColors.lightSurface2,
      surfaceContainerHighest: FitnessColors.lightSurface3,
      onSurfaceVariant: FitnessColors.lightTextSecondary,
      outline: FitnessColors.lightBorder,
      outlineVariant: FitnessColors.lightBorderSubtle,
      error: FitnessColors.error,
      onError: Colors.white,
    );

    TextTheme createTextTheme(Color primaryText, Color secondaryText) {
      return TextTheme(
        displayLarge: TextStyle(
          fontFamily: defaultFont,
          fontSize: 40,
          fontWeight: FontWeight.w700,
          letterSpacing: -1.0,
          color: primaryText,
          fontFeatures: tabularFontFeatures,
        ),
        displayMedium: TextStyle(
          fontFamily: defaultFont,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: primaryText,
          fontFeatures: tabularFontFeatures,
        ),
        headlineLarge: TextStyle(
          fontFamily: defaultFont,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: primaryText,
          fontFeatures: tabularFontFeatures,
        ),
        headlineMedium: TextStyle(
          fontFamily: defaultFont,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: primaryText,
        ),
        headlineSmall: TextStyle(
          fontFamily: defaultFont,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: primaryText,
        ),
        titleLarge: TextStyle(
          fontFamily: defaultFont,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: primaryText,
        ),
        titleMedium: TextStyle(
          fontFamily: defaultFont,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        titleSmall: TextStyle(
          fontFamily: defaultFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        bodyLarge: TextStyle(
          fontFamily: defaultFont,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        bodyMedium: TextStyle(
          fontFamily: defaultFont,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        bodySmall: TextStyle(
          fontFamily: defaultFont,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
        labelLarge: TextStyle(
          fontFamily: defaultFont,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primaryText,
        ),
        labelMedium: TextStyle(
          fontFamily: defaultFont,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: secondaryText,
        ),
        labelSmall: TextStyle(
          fontFamily: defaultFont,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
          color: secondaryText,
          fontFeatures: tabularFontFeatures,
        ),
      );
    }

    return MaterialApp(
      title: 'Fitness Tracker',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark, // Dark-first design
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: defaultFont,
        scaffoldBackgroundColor: FitnessColors.lightBackground,
        colorScheme: lightColorScheme,
        cardColor: FitnessColors.lightSurface1,
        dividerColor: FitnessColors.lightBorder,
        textTheme: createTextTheme(
          FitnessColors.lightTextPrimary,
          FitnessColors.lightTextSecondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: FitnessColors.lightBackground,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: FitnessColors.lightSurface1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: FitnessColors.lightBorder),
          ),
          elevation: 8,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: defaultFont,
        scaffoldBackgroundColor: FitnessColors.darkBackground,
        colorScheme: darkColorScheme,
        cardColor: FitnessColors.darkSurface1,
        dividerColor: FitnessColors.darkBorder,
        textTheme: createTextTheme(
          FitnessColors.darkTextPrimary,
          FitnessColors.darkTextSecondary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: FitnessColors.darkBackground,
          scrolledUnderElevation: 0,
          elevation: 0,
          centerTitle: false,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: FitnessColors.darkSurface1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: const BorderSide(color: FitnessColors.darkBorder),
          ),
          elevation: 12,
        ),
      ),
      home: HomeShell(store: store),
    );
  }
}
