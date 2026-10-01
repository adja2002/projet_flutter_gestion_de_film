import 'package:hive/hive.dart';

part 'movie_model.g.dart'; // Référence au fichier généré

@HiveType(typeId: 0) // TypeId unique pour cette classe
class Movie {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String posterPath;

  @HiveField(3)
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.releaseDate,
  });
}
