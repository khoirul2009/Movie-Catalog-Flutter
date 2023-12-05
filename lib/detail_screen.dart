import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_movie/custom_widget/star_rating.dart';
import 'package:get_movie/data/database_helper.dart';
import 'package:get_movie/model/movie_watchlist.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'model/credit.dart';
import 'model/movie_detail.dart';

class DetailScreen extends StatefulWidget {
  final int movieId;

  const DetailScreen({Key? key, required this.movieId}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState(movieId);
}

class _DetailScreenState extends State<DetailScreen> {
  final int movieId;

  _DetailScreenState(this.movieId);

  bool _isWatchlisted = false;

  @override
  initState() {
    super.initState();
    checkWatchlisted();
  }

  final dbHelper = DatabaseHelper();

  Future<void> insertMovie(MovieWatchlist movie) async {
    try {
      final db = await dbHelper.database;
      await db.insert('movie_watchlist', movie.toMap());
      checkWatchlisted();
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Movie added to watchlist',
                style: TextStyle(fontSize: 20.0),
              ),
            );
          },
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> deleteWatchlist() async {
    try {
      final db = await dbHelper.database;
      await db.delete('movie_watchlist', where: 'id = $movieId');
      checkWatchlisted();
      if (context.mounted) {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Movie deleted from Watchlist',
                style: TextStyle(fontSize: 20.0),
              ),
            );
          },
        );
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<void> checkWatchlisted() async {
    try {
      final db = await dbHelper.database;
      final List<dynamic> data =
          await db.query('movie_watchlist', where: 'id = $movieId');
      if (data.isNotEmpty) {
        setState(() {
          _isWatchlisted = true;
        });
      } else {
        setState(() {
          _isWatchlisted = false;
        });
      }
    } catch (error) {
      throw Exception(error);
    }
  }

  Future<MovieDetail?> fetchMovie() async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://api.themoviedb.org/3/movie/${widget.movieId}?language=en-US&page=1'),
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMjQwNWFkZjNmMTI5NGVlMzIyN2Y5NDNkZjBiMDllNCIsInN1YiI6IjY0YmU1Y2VmODVjMGEyMDE0NDA4MTNjOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.d1BeELibn7oft7nINVTsalRN9QAAKgO1mSEfwKelgPU',
          });
      if (response.statusCode == 200) {
        final MovieDetail data =
            MovieDetail.fromJson(json.decode(response.body));
        return data;
      }
    } catch (error) {
      throw Exception(error);
    }
    return null;
  }

  Future<List<Credit>?> fetchCredit() async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://api.themoviedb.org/3/movie/72710/${widget.movieId}?language=en-US'),
          headers: {
            'Authorization':
                'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMjQwNWFkZjNmMTI5NGVlMzIyN2Y5NDNkZjBiMDllNCIsInN1YiI6IjY0YmU1Y2VmODVjMGEyMDE0NDA4MTNjOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.d1BeELibn7oft7nINVTsalRN9QAAKgO1mSEfwKelgPU',
          });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['cast'];
        return data.map((e) => Credit.fromJson(e)).toList();
      }
    } catch (error) {
      throw Exception(error);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat.currency(locale: "en_US", symbol: "\$");

    return Scaffold(
      body: FutureBuilder(
        future: fetchMovie(),
        builder: (context, snapshoot) {
          if (snapshoot.hasData && snapshoot.data != null) {
            final MovieDetail movie = snapshoot.data!;
            return Stack(
              children: [
                Image.network(
                  'https://www.themoviedb.org/t/p/original/${movie.backdropPath}',
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.indigo.withOpacity(0.6),
                ),
                SingleChildScrollView(
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.share,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  'https://www.themoviedb.org/t/p/w220_and_h330_face/${movie.posterPath}',
                                  height: 255,
                                  width: 170,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.45,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie.title,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20),
                                    ),
                                    SizedBox(
                                      width: 150,
                                      child: Wrap(
                                        children: movie.genres
                                            .map(
                                              (e) => Text(
                                                '${e.name}, ',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    StarRating(rating: 4.5),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.indigo,
                                          child: IconButton(
                                            onPressed: () {
                                              if (_isWatchlisted) {
                                                deleteWatchlist();
                                              } else {
                                                insertMovie(MovieWatchlist(
                                                    title: movie.title,
                                                    posterPath:
                                                        movie.posterPath,
                                                    id: movie.id,
                                                    overview: movie.overview,
                                                    rating:
                                                        movie.voteAverage / 2));
                                              }
                                            },
                                            icon: Icon(
                                              _isWatchlisted
                                                  ? Icons.bookmark
                                                  : Icons.bookmark_outline,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.indigo,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        CircleAvatar(
                                          backgroundColor: Colors.indigo,
                                          child: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                              Icons.list,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 20),
                              color: Colors.white,
                              constraints: BoxConstraints(
                                  minHeight:
                                      MediaQuery.of(context).size.height * 0.6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Tagline',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    movie.tagline,
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic),
                                  ),
                                  const Text(
                                    'Overview',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  Text(movie.overview),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          const Text(
                                            'Staus',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(movie.status)
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text('Original Language',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              )),
                                          Text(movie.originalLanguage)
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          const Text('Budget',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                              )),
                                          Text(formatter
                                              .format(movie.budget)
                                              .toString())
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    constraints: BoxConstraints(maxHeight: 200),
                                    padding: EdgeInsets.all(8),
                                    child: FutureBuilder(
                                      future: fetchCredit(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Center(
                                              child:
                                                  const CircularProgressIndicator());
                                        } else if (snapshot.hasError) {
                                          return Center(
                                            child: Text('Someting Error!'),
                                          );
                                        } else if(snapshot.data != null && snapshot.data!.isEmpty) {
                                          return Center(
                                            child: Text('Empty'),
                                          );
                                        } else {
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                if (snapshot.data != null &&
                                                    snapshot.data!.isNotEmpty) {
                                                  final credit =
                                                      snapshot.data![index];

                                                  return Card(
                                                    child: Column(
                                                      mainAxisSize: MainAxisSize.max,
                                                      children: [
                                                        Image.network(
                                                          'https://image.tmdb.org/t/p/w138_and_h175_face/${credit.profilePath}',
                                                          height: 150,
                                                        ),
                                                        Text(credit.name),
                                                      ],
                                                    ),
                                                  );
                                                }
                                              });
                                        }
                                      },
                                    ),
                                  )
                                ],
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else if (snapshoot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Center(
              child: Text(snapshoot.error.toString()),
            );
          }
        },
      ),
    );
  }
}
