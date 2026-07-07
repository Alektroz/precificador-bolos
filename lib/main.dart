import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const PrecificadorBolosApp());
}

class PrecificadorBolosApp extends StatelessWidget {
  const PrecificadorBolosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Precificador de Bolos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.brown,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}