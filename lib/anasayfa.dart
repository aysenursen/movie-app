import 'dart:io';
import 'package:classic/moviedetails.dart';
import 'package:classic/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'models/movie_models.dart';

class AnaSayfa extends StatefulWidget {
  const AnaSayfa({super.key});

  @override
  State<AnaSayfa> createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  List<izlenenFilmler> _movies = [];
  Color _containerColor = Color(0xffd9d9d9);
  final PageController _pageController = PageController();
  final List<Color> _pastelColors = [
    Color(0xFFB3E5FC),
    Color(0xFFFFCDD2),
    Color(0xFFC8E6C9),
    Color(0xFFFFF9C4),
    Color(0xFFD1C4E9),
    Color(0xFFFFF3E0),
    Color(0xFFE1BEE7),
  ];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('all_movies')
          .orderBy('averageRating', descending: true)
          .get();
      List<izlenenFilmler> fetchedMovies = snapshot.docs
          .map((doc) =>
              izlenenFilmler.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      setState(() {
        _movies = fetchedMovies;
      });
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_movies.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: ConstantsColor.mainColor,
          title: Text('Yüksek Puanlı Filmler',
              style: ConstantsStyle.headingBoldBlack),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ConstantsColor.mainColor,
        title: Text('Yüksek Puanlı Filmler',
            style: ConstantsStyle.headingBoldBlack),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView.builder(
          controller: _pageController,
          itemCount: _movies.length + 2,
          onPageChanged: (index) {
            if (index == _movies.length + 1) {
              Future.delayed(Duration(milliseconds: 300), () {
                _pageController.jumpToPage(1);
                setState(() {
                  _containerColor = _pastelColors[0 % _pastelColors.length];
                });
              });
            } else if (index == 0) {
              Future.delayed(Duration(milliseconds: 300), () {
                _pageController.jumpToPage(_movies.length);
                setState(() {
                  _containerColor = _pastelColors[
                      (_movies.length - 1) % _pastelColors.length];
                });
              });
            } else {
              setState(() {
                _containerColor =
                    _pastelColors[(index - 1) % _pastelColors.length];
              });
            }
          },
          itemBuilder: (context, index) {
            int movieIndex = (index - 1) % _movies.length;
            if (index == 0) {
              movieIndex = _movies.length - 1;
            } else if (index == _movies.length + 1) {
              movieIndex = 0;
            }
            var movie = _movies[movieIndex];
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = _pageController.page! - index;
                  value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                }
                return Transform.scale(
                  scale: Curves.easeOut.transform(value),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Details(
                        imagepath: movie.imagepath,
                        imageUrl: movie.imageUrl,
                        movieName: movie.movieName,
                        movieGenre: movie.movieGenre,
                        director: movie.director,
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: _containerColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width *
                              ConstantsScale.maincontainerWidthPoster,
                          height: MediaQuery.of(context).size.height *
                              ConstantsScale.maincontainerHeightPoster,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            image: movie.imageUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(movie.imageUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : movie.imagepath != null
                                    ? DecorationImage(
                                        image:
                                            FileImage(File(movie.imagepath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                        ),
                        SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.movieName.toUpperCase(),
                              style: ConstantsStyle.posterStyle,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Yönetmen: ${movie.director}',
                              style: ConstantsStyle.tinyposterStyle,
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Tür: ${movie.movieGenre}',
                              style: ConstantsStyle.tinyposterStyle,
                            ),
                            SizedBox(height: 5),
                            StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('all_movies')
                                  .doc(movie.movieName)
                                  .collection('ratings')
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text('Puan yükleniyor...',
                                      style: ConstantsStyle.tinyposterStyle);
                                }
                                if (snapshot.hasError) {
                                  return Text('Bir hata oluştu',
                                      style: ConstantsStyle.tinyposterStyle);
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Text('Henüz puan verilmemiş',
                                      style: ConstantsStyle.tinyposterStyle);
                                }

                                var docs = snapshot.data!.docs;
                                double totalRate = 0.0;
                                int count = 0;

                                for (var doc in docs) {
                                  var rate = doc['rate'] ?? 0;
                                  totalRate += rate;
                                  if (rate != 0) {
                                    count++;
                                  }
                                }

                                if (count == 0) {
                                  return Text('Henüz puan verilmemiş',
                                      style: ConstantsStyle.tinyprimaryOpStyle);
                                }
                                double averageRate = totalRate / count;
                                return Text(
                                  'Puan: ${averageRate.toStringAsFixed(1)}',
                                  style: ConstantsStyle.tinyposterStyle,
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
