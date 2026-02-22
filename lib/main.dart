import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const PossibleApp(),
    ),
  );
}

class PossibleApp extends StatelessWidget {
  const PossibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Pengaturan tema
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'POSsible',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      home: const HomeScreen(),
    );
  }
}