import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/oobe_screen.dart';
import 'providers/store_provider.dart';
import 'providers/product_provider.dart';

void main() {
  // Inisialisasi database untuk linux dan windows
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => StoreProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
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
      home: Consumer<StoreProvider>(
        builder: (context, storeProvider, child) {
          // Jika ada detail toko yang disetting, masuk ke homepage. Jika tidak, masuk ke OOBE.
          if (storeProvider.isConfigured) {
            return const HomeScreen();
          } else {
            return const OobeScreen();
          }
        },
      ),
    );
  }
}