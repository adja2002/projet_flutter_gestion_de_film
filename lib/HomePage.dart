import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestion de Films'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Ajout d'une section pour les films populaires
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Films Populaires',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
          // FutureBuilder pour charger les films
          Expanded(
            child: FutureBuilder(
              future: fetchPopularMovies(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur de chargement en ligne. Mode hors ligne activé.'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('Aucun film disponible.'));
                } else {
                  var movies = snapshot.data as List<dynamic>;

                  if (movies.isEmpty) {
                    return Center(child: Text('Aucun film trouvé.'));
                  }

                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, '/details', arguments: movies[index]);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: CachedNetworkImage(
                                  imageUrl: movies[index]['poster_path'] != null
                                      ? 'https://image.tmdb.org/t/p/w500' + movies[index]['poster_path']
                                      : '', // Image par défaut
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  movies[index]['title'] ?? 'Titre indisponible',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'Sortie: ' + (movies[index]['release_date'] ?? 'Date inconnue'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> fetchPopularMovies() async {
    var box = await Hive.openBox('moviesBox');

    try {
      final response = await http.get(Uri.parse(
          'https://api.themoviedb.org/3/movie/popular?api_key=ad50e06c93736703a3ffe7f97a0be7a6&language=fr-FR'));

      if (response.statusCode == 200) {
        var movies = json.decode(response.body)['results'];

        await box.put('popularMovies', movies);

        return movies;
      } else {
        throw Exception('Erreur de chargement des films');
      }
    } catch (e) {
      var offlineMovies = box.get('popularMovies');
      if (offlineMovies != null) {
        return offlineMovies;
      } else {
        throw Exception('Aucun film disponible hors ligne');
      }
    }
  }
}
