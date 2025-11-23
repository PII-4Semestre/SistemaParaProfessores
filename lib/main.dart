import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        // Cores do tema claro - tons salmão/pêssego
        final lightSalmon = const Color(0xFFF6E2CD); // Salmão claro de fundo
        final lightPeach = const Color(0xFFFFB88C); // Pêssego para acentos
        final lightCoral = const Color(0xFFFF9B71); // Coral para primary
        
        // Cores do tema escuro - gradiente atual
        final darkCyan = const Color(0xFF1CB3C2);
        final darkPurple = const Color(0xFF9C27B0);

        final lightScheme = ColorScheme.light(
          primary: lightCoral,
          secondary: lightPeach,
          surface: lightSalmon,
          background: const Color(0xFFFFF5EB), // Tom ainda mais claro para background
          onPrimary: Colors.white,
          onSecondary: const Color(0xFF5D4037),
          onSurface: const Color(0xFF5D4037), // Marrom escuro para texto
          onBackground: const Color(0xFF5D4037),
        );

        final darkScheme = ColorScheme.dark(
          primary: darkCyan,
          secondary: darkPurple,
          surface: const Color(0xFF1A1A2E),
          background: const Color(0xFF0F0C29),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'PoliEduca',
          themeMode: themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
            Locale('en', 'US'),
          ],
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: const Color(0xFFFFF5EB),
            cardTheme: CardThemeData(
              elevation: 0,
              color: lightSalmon,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: lightCoral,
                foregroundColor: Colors.white,
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
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lightPeach.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lightPeach.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: lightCoral, width: 2),
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
            scaffoldBackgroundColor: const Color(0xFF0F0C29),
            cardTheme: CardThemeData(
              elevation: 0,
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: darkCyan,
                foregroundColor: Colors.white,
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
              fillColor: const Color(0xFF1A1A2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: darkCyan, width: 2),
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
