class Movie {
  final int id;
  final String title;
  final String overview;
  final num popularity;
  final String posterPath;
  final String releaseDate;
  final num voteAverage;

  Movie(
      {required this.id,
      required this.title,
      required this.overview,
      required this.popularity,
      required this.posterPath,
      required this.releaseDate,
      required this.voteAverage});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
        id: json['id'],
        title: json['title'],
        overview: json['overview'],
        popularity: json['popularity'],
        posterPath: json['poster_path'],
        releaseDate: json['release_date'],
        voteAverage: json['vote_average']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'rating': voteAverage / 2,
      'poster': posterPath
    };
  }
}


