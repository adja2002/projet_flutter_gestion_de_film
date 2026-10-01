import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ReviewProvider.dart'; // Importer le provider

class UserReviewsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Critiques des Utilisateurs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Laisser une critique...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.send), // Icône d'envoi
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  // Ajoutons la critique dans ReviewProvider
                  Provider.of<ReviewProvider>(context, listen: false).addReview(value);

                  // Affichons un message de confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Critique ajoutée avec succès!')),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, reviewProvider, child) {
                if (reviewProvider.reviews.isEmpty) {
                  return Center(child: Text('Aucune critique pour le moment.'));
                }
                return ListView.builder(
                  itemCount: reviewProvider.reviews.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      elevation: 3,
                      child: ListTile(
                        title: Text(reviewProvider.reviews[index],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // pour Supprimer la critique
                            Provider.of<ReviewProvider>(context, listen: false).removeReview(index);

                            // Afficher un message de confirmation
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
          ),
        ],
      ),
    );
  }
}
