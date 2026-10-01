import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'FavoritesProvider.dart';
import 'movie_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'ReviewProvider.dart'; // Importons le provider pour les critiques

class MovieDetailsPage extends StatefulWidget {
  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  String? _trailerUrl; // URL de la bande-annonce
  bool _isLoadingTrailer = true; // État du chargement de la bande-annonce

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final movie = ModalRoute.of(context)!.settings.arguments as Map;
    _loadTrailer(movie['id']);
  }

  Future<void> _loadTrailer(int movieId) async {
    final trailerUrl = await fetchMovieTrailer(movieId);
    setState(() {
      _trailerUrl = trailerUrl;
      _isLoadingTrailer = false;
    });
  }

  Future<String?> fetchMovieTrailer(int movieId) async {
    final response = await http.get(Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId/videos?api_key=ad50e06c93736703a3ffe7f97a0be7a6&language=fr-FR'));

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      var videos = jsonResponse['results'] as List;

      if (videos.isNotEmpty) {
        var trailer = videos.firstWhere((video) => video['site'] == 'YouTube', orElse: () => null);
        if (trailer != null) {
          return 'https://www.youtube.com/watch?v=${trailer['key']}';
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Map;

    final movieModel = Movie(
      id: movie['id'],
      title: movie['title'],
      posterPath: movie['poster_path'],
      releaseDate: movie['release_date'],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(movie['title']),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Détails du film
            Image.network('https://image.tmdb.org/t/p/w500' + movie['poster_path']),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                movie['overview'],
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Date de sortie : ${movie['release_date']}',
                style: TextStyle(fontSize: 16),
              ),
            ),
            
            // Bande-annonce
            if (_isLoadingTrailer)
              CircularProgressIndicator()
            else if (_trailerUrl != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (await canLaunch(_trailerUrl!)) {
                      await launch(_trailerUrl!);
                    }
                  },
                  icon: Icon(Icons.play_circle_fill),
                  label: Text('Regarder la bande-annonce'),
                ),
              )
            else
              Text('Aucune bande-annonce disponible.'),

            // Boutons Favoris et Regarder Plus Tard
            Consumer<FavoritesProvider>(
              builder: (context, provider, child) {
                final isFavorite = provider.favorites.contains(movieModel);
                final isWatchLater = provider.watchLater.contains(movieModel);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isFavorite) {
                          provider.removeFavorite(movieModel);
                        } else {
                          provider.addFavorite(movieModel);
                        }
                      },
                      icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                      label: Text(isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (isWatchLater) {
                          provider.removeWatchLater(movieModel);
                        } else {
                          provider.addWatchLater(movieModel);
                        }
                      },
                      icon: Icon(isWatchLater ? Icons.watch_later : Icons.watch_later_outlined),
                      label: Text(isWatchLater
                          ? 'Retirer de Regarder Plus Tard'
                          : 'Ajouter à Regarder Plus Tard'),
                    ),
                  ],
                );
              },
            ),

            Divider(),

            // Section Critiques des Utilisateurs
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Critiques des utilisateurs',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Champ pour ajouter une critique
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Laisser une critique...',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.send),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    // Ajouteons la critique dans ReviewProvider
                    Provider.of<ReviewProvider>(context, listen: false).addReview(value);

                    // Affichons un message de confirmation
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Critique ajoutée avec succès!')),
                    );
                  }
                },
              ),
            ),

            // Liste des critiques
            Consumer<ReviewProvider>(
              builder: (context, reviewProvider, child) {
                if (reviewProvider.reviews.isEmpty) {
                  return Center(child: Text('Aucune critique pour le moment.'));
                }
                return ListView.builder(
                  shrinkWrap: true, // Permet à ListView d'être utilisé dans un ScrollView
                  physics: NeverScrollableScrollPhysics(), // Désactive le défilement interne
                  itemCount: reviewProvider.reviews.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      elevation: 3,
                      child: ListTile(
                        title: Text(
                          reviewProvider.reviews[index],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // Supprimons la critique
                            Provider.of<ReviewProvider>(context, listen: false).removeReview(index);

                            // Affichons un message de confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Critique supprimée')),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
