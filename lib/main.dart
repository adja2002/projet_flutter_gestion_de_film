import 'package:flutter/material.dart';
import 'package:gestion_film/UserReviewsPage.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'FavoritesProvider.dart'; // Classe pour gérer les favoris
import 'HomePage.dart';       // Page d'accueil
import 'SearchPage.dart';        // Page de recherche
import 'MovieDetailsPage.dart';  // Page des détails d'un film
import 'ReviewProvider.dart';    // Import du ReviewProvider pour les critiques

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation de Hive pour le stockage local (si nécessaire)
  await Hive.initFlutter();
  await Hive.openBox('moviesBox'); // Ouvrir une boîte Hive pour stocker les films
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FavoritesProvider()), // Gestion des favoris
        ChangeNotifierProvider(create: (_) => ReviewProvider()), // Gestion des critiques
      ],
      child: MaterialApp(
        title: 'Gestion de Films',
        theme: ThemeData(
          primarySwatch: Colors.deepPurple, // Définir le thème principal de l'application
        ),
        // Configuration des routes
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),            // Page d'accueil
          '/search': (context) => SearchPage(),     // Page de recherche
          '/details': (context) => MovieDetailsPage(), // Page des détails d'un film
          '/review': (context) => UserReviewsPage(), // Page des critiques des utilisateurs
        },
      ),
    );
  }
}
