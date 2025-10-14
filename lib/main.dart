import 'package:flutter/material.dart';
import 'screens/autenticacao/tela_login.dart';

void main() {
  runApp(const PoliEducaApp());
}

class PoliEducaApp extends StatelessWidget {
  const PoliEducaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PoliEduca',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const TelaLogin(),
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
          MaterialPageRoute(
            builder: (context) => const TelaLogin(),
          ),
          (route) => false,
        );
      },
    );
  }
}
