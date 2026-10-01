import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'movie_model.dart';

class FavoritesProvider with ChangeNotifier {
  List<Movie> _favorites = [];
  List<Movie> _watchLater = [];

  List<Movie> get favorites => _favorites;
  List<Movie> get watchLater => _watchLater;

  Future<void> loadMovies() async {
    var favoritesBox = await Hive.openBox<Movie>('favorites');
    var watchLaterBox = await Hive.openBox<Movie>('watchLater');
    _favorites = favoritesBox.values.toList();
    _watchLater = watchLaterBox.values.toList();
    notifyListeners();
  }

  void addFavorite(Movie movie) async {
    var box = await Hive.openBox<Movie>('favorites');
    if (!_favorites.contains(movie)) {
      box.put(movie.id, movie);
      _favorites.add(movie);
      notifyListeners();
    }
  }

  void removeFavorite(Movie movie) async {
    var box = await Hive.openBox<Movie>('favorites');
    box.delete(movie.id);
    _favorites.remove(movie);
    notifyListeners();
  }

  void addWatchLater(Movie movie) async {
    var box = await Hive.openBox<Movie>('watchLater');
    if (!_watchLater.contains(movie)) {
      box.put(movie.id, movie);
      _watchLater.add(movie);
      notifyListeners();
    }
  }

  void removeWatchLater(Movie movie) async {
    var box = await Hive.openBox<Movie>('watchLater');
    box.delete(movie.id);
    _watchLater.remove(movie);
    notifyListeners();
  }
}
