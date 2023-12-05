class MovieWatchlist {
  final int id;
  final String title;
  final String overview;
  final String posterPath;
  final num rating;

  MovieWatchlist(
      {required this.id,
        required this.title,
        required this.overview,
        required this.posterPath,
        required this.rating});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'rating': rating,
      'poster': posterPath
    };
  }
}