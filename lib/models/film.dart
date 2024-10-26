// lib/models/film.dart
class Film {
  final String no;
  final String title;
  final String year;
  final String genre;
  final String origin;
  final String director;
  final String star;
  final String imdbLink;

  Film({
    required this.no,
    required this.title,
    required this.year,
    required this.genre,
    required this.origin,
    required this.director,
    required this.star,
    required this.imdbLink,
  });
}
