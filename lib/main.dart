import 'package:flutter/material.dart';
import 'screens/pack_selection_screen.dart';

void main() {
  runApp(const FlamingoCardsApp());
}

class FlamingoCardsApp extends StatelessWidget {
  const FlamingoCardsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flamingo Cards',
      theme: ThemeData(
        primarySwatch: Colors.pink, // Base theme color
        scaffoldBackgroundColor: Colors.grey[100], // Light background
        appBarTheme: const AppBarTheme(
          elevation: 0, // Flat app bar
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Default AppBar text color
          ),
        ),
        cardTheme: CardTheme(
          clipBehavior: Clip.antiAlias, // Prevent content spillover
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PackSelectionScreen(), // Start with the pack selection
      debugShowCheckedModeBanner: false, // Hide debug banner
    );
  }
}
