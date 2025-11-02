import 'package:flutter/material.dart';
import 'screens/autenticacao/tela_login.dart';
import 'services/api_service.dart';
import 'services/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService().init();
  runApp(const PoliEducaApp());
}

class PoliEducaApp extends StatelessWidget {
  const PoliEducaApp({super.key});

  @override
  Widget build(BuildContext context) {
    // React to theme changes across the app.
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance.themeMode,
      builder: (context, themeMode, _) {
        final lightPrimary = const Color(0xFFF28C1B);
        final darkPrimary = const Color(0xFF1CB3C2);

        final lightScheme =
            ColorScheme.fromSeed(
              seedColor: lightPrimary,
              brightness: Brightness.light,
            ).copyWith(
              primary: lightPrimary,
              surface: Colors.white,
            );

        final darkScheme =
            ColorScheme.fromSeed(
              seedColor: darkPrimary,
              brightness: Brightness.dark,
            ).copyWith(
              primary: darkPrimary,
              surface: const Color.fromARGB(255, 46, 46, 46),
            );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PoliEduca',
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: Colors.white,
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lightPrimary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              headlineLarge: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              headlineMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              headlineSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            scaffoldBackgroundColor: const Color.fromARGB(255, 22, 22, 22),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.grey.shade900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade700),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: darkPrimary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            textTheme: const TextTheme(
              displayLarge: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              displayMedium: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              displaySmall: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              headlineLarge: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              headlineMedium: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              headlineSmall: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              bodyMedium: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          home: const TelaLogin(),
        );
      },
    );
  }
}

class SomeWidget extends StatelessWidget {
  const SomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TelaLogin()),
          (route) => false,
        );
      },
    );
  }
}
