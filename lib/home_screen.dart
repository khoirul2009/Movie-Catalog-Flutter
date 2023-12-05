import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_movie/custom_widget/star_rating.dart';
import 'package:get_movie/detail_screen.dart';
import 'package:get_movie/model/movie.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get Movie'),
      ),
      body: const SingleChildScrollView(
          child: Column(
            children: [
              ListMovie(heading: 'Popular Movie', urlPath: 'popular'),
              ListMovie(heading: 'Now Playing', urlPath: 'now_playing'),
              ListMovie(heading: 'Top Rated Movie', urlPath: 'top_rated'),
              ListMovie(heading: 'Upcoming Movie', urlPath: 'upcoming'),
            ],
          ),
        ),
    );
  }
}

class ListMovie extends StatelessWidget {
  final String heading;
  final String urlPath;

  const ListMovie({super.key, required this.heading, required this.urlPath});
    
  Future<List<Movie>?> fetchMovie() async {
    try {
      final response = await http.get(
          Uri.parse(
              'https://api.themoviedb.org/3/movie/$urlPath?language=en-US&page=1'),
          headers: {
            'Authorization':
            'Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJkMjQwNWFkZjNmMTI5NGVlMzIyN2Y5NDNkZjBiMDllNCIsInN1YiI6IjY0YmU1Y2VmODVjMGEyMDE0NDA4MTNjOCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.d1BeELibn7oft7nINVTsalRN9QAAKgO1mSEfwKelgPU',
          });
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body)['results'];
        return data.map((json) => Movie.fromJson(json)).toList();
      }
    } catch (error) {
      throw Exception(error);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Text(
            heading,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
          ),
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 360),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: FutureBuilder<List<Movie>?>(
            future: fetchMovie(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Expanded(
                  child: Center(
                    child: Text(snapshot.error.toString()),
                  ),
                );
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (snapshot.data != null && snapshot.data!.isNotEmpty) {
                      final movie = snapshot.data![index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          splashFactory: InkSparkle.splashFactory,
                          onTap: () {
                            Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (context) {
                              return DetailScreen(movieId: movie.id,);
                            }));

                          },
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      width: 180,
                                      height: 270,
                                      'https://www.themoviedb.org/t/p/w220_and_h330_face${movie.posterPath}',
                                    ),
                                  ),
                                  Container(
                                    width: 180,
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      movie.title,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                      padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                      child: StarRating(
                                          rating: movie.voteAverage / 2))
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    else if(snapshot.hasError) {
                      return const Center(
                        child: Text('Someting Error'),
                      );

                    }
                    else {
                      return const Center(
                        child: Text('Empty'),
                      );
                    }
                  },
                  itemCount: snapshot.data?.length,
                );
              }
            },
          ),
        ),
      ],
    );
  }
}


