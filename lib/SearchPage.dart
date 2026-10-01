import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String query = '';
  List<dynamic> results = [];

  void searchMovies(String query) async {
    final response = await http.get(Uri.parse(
        'https://api.themoviedb.org/3/search/movie?api_key=ad50e06c93736703a3ffe7f97a0be7a6&language=fr-FR&query=$query'));
    
    if (response.statusCode == 200) {
      setState(() {
        results = json.decode(response.body)['results'];
      });
    } else {
      // Gérer le cas d'une réponse non 200
      setState(() {
        results = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de Films'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher un film...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  query = value;
                });
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  searchMovies(value);
                }
              },
            ),
          ),
          Expanded(
            child: results.isNotEmpty
                ? ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(results[index]['title'] ?? 'Titre non disponible'),
                        leading: results[index]['poster_path'] != null
                            ? Image.network(
                                'https://image.tmdb.org/t/p/w500' + results[index]['poster_path'])
                            : SizedBox.shrink(), // Si aucune image n'est disponible
                        onTap: () {
                          Navigator.pushNamed(context, '/details', arguments: results[index]);
                        },
                      );
                    },
                  )
                : Center(
                    child: Text('Aucun film trouvé. Veuillez entrer un mot-clé.'),
                  ),
          ),
        ],
      ),
    );
  }
}
