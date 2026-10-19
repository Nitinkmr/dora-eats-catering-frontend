import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/catalogue_api.dart';
import 'state/catering_state.dart';
import 'screens/catalogue_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => CateringState(CatalogueApi())..loadCatalogue(),
      child: const DoraCateringApp(),
    ),
  );
}

class DoraCateringApp extends StatelessWidget {
  const DoraCateringApp({super.key});

  @override
  Widget build(BuildContext context) {
    const brand = Color(0xFFC42B2B);
    return MaterialApp(
      title: 'Dora Catering',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: brand, primary: brand),
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAE5DF))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEAE5DF))),
        ),
      ),
      home: const CataloguePage(),
    );
  }
}
