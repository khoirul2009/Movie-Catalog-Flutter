import 'package:flutter/material.dart';
import 'package:get_movie/custom_widget/star_rating.dart';
import 'package:get_movie/model/movie_watchlist.dart';
import 'data/database_helper.dart';
import 'detail_screen.dart';

class WatchListScreen extends StatefulWidget {
  const WatchListScreen({super.key});

  @override
  State<WatchListScreen> createState() => _WatchListScreenState();
}

class _WatchListScreenState extends State<WatchListScreen> {
  final dbHelper = DatabaseHelper();

  List<MovieWatchlist> _listMovie = [];

  Future<void> fetchMovie() async {
    final db = await dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query('movie_watchlist');

    final listMovie = List.generate(maps.length, (index) {
      return MovieWatchlist(
        id: maps[index]['id'],
        rating: maps[index]['rating'],
        overview: maps[index]['overview'],
        posterPath: maps[index]['poster'],
        title: maps[index]['title']
      );
    });

    setState(() {
      _listMovie = listMovie;
    });

  }

  @override
  void initState() {
    super.initState();

  }



  @override
  Widget build(BuildContext context) {
    fetchMovie();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watch List'),
      ),
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(16),
          child: Builder(
            builder: (context) {
              if(_listMovie.isNotEmpty) {
                return ListView(
                  children: _listMovie.map((e) {
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) {
                            return DetailScreen(movieId: e.id,);
                          }));
                        },
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8)
                              ),
                              child: Image.network(
                                'https://www.themoviedb.org/t/p/w220_and_h330_face/${e.posterPath}',
                                width: 80,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.title, style:
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600
                                    )
                                    ,),
                                  StarRating(rating: e.rating.toDouble()),
                                  Text(e.overview,
                                    maxLines: 2,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                return Center(
                  child: Text('Empty'),
                );
              }
            }
          ),
        ),
      ),
    );
  }
}
