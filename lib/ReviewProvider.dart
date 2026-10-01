import 'package:flutter/material.dart';

class ReviewProvider with ChangeNotifier {
  List<String> _reviews = [];

  // Récupérons la liste des critiques
  List<String> get reviews => _reviews;

  // Ajoutons une critique
  void addReview(String review) {
    _reviews.add(review);
    notifyListeners(); // Notifions les widgets que la liste a changé
  }

  //pour  Supprimer une critique
  void removeReview(int index) {
    _reviews.removeAt(index);
    notifyListeners(); // Notifions les widgets que la liste a changé
  }
}
