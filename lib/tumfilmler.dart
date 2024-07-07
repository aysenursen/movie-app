import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'moviedetails.dart';
import 'models/movie_models.dart';
import 'utilities/constants.dart';
import 'widgets/movie_container.dart';

class TumFilmler extends StatefulWidget {
  @override
  State<TumFilmler> createState() => _TumFilmlerState();
}

class _TumFilmlerState extends State<TumFilmler> {
  List<izlenenFilmler> movies = [];
  List<izlenenFilmler> filteredMovies = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMovies();
    _searchController.addListener(() {
      filterMovies();
    });
  }

  Future<void> fetchMovies() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('all_movies').get();
      List<izlenenFilmler> fetchedMovies = snapshot.docs
          .map((doc) =>
              izlenenFilmler.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      fetchedMovies.sort((a, b) => a.movieName.compareTo(b.movieName));

      setState(() {
        movies = fetchedMovies;
        filteredMovies = fetchedMovies;
      });
    } catch (e) {
      print('Error fetching movies: $e');
    }
  }

  void filterMovies() {
    List<izlenenFilmler> _tempList = [];
    _tempList = movies.where((movie) {
      return movie.movieName
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());
    }).toList();
    setState(() {
      filteredMovies = _tempList;
    });
  }

  void _showAddToCollectionDialog(izlenenFilmler movie) {
    TextEditingController collectionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Koleksiyona Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: collectionController,
                decoration: InputDecoration(hintText: "Yeni Koleksiyon İsmi"),
              ),
              SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('collection')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return Container(
                    width: double.maxFinite,
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var collection = snapshot.data!.docs[index];
                        return ListTile(
                          title: Text(collection.id),
                          onTap: () {
                            _addMovieToCollection(collection.id, movie);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                if (collectionController.text.isNotEmpty) {
                  _addMovieToCollection(collectionController.text, movie);
                  Navigator.of(context).pop();
                }
              },
              child: Text('Ekle'),
            ),
          ],
        );
      },
    );
  }

  void _addMovieToCollection(
      String collectionName, izlenenFilmler movie) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      if (collectionName.isNotEmpty && movie.movieName.isNotEmpty) {
        try {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .collection('collection')
              .doc(collectionName)
              .collection('movies')
              .doc(movie.movieName)
              .set(movie.toJson());
        } catch (e) {
          print('Error adding movie to collection: $e');
        }
      } else {
        print('Collection name or movie name is empty');
      }
    } else {
      print('User not signed in');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Arama yapın",
            border: InputBorder.none,
            icon: Icon(Icons.search),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        backgroundColor: ConstantsColor.mainColor,
        actions: [
          IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              _searchController.clear();
              filterMovies();
            },
          ),
        ],
      ),
      backgroundColor: ConstantsColor.backgroundColor,
      body: SafeArea(
        child: movies.isEmpty
            ? Center(
                child: Text(
                  'Film Listesi Boş',
                  style: ConstantsStyle.primaryOpStyle,
                ),
              )
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1, childAspectRatio: 2),
                itemCount: _searchController.text.isEmpty
                    ? movies.length
                    : filteredMovies.length,
                itemBuilder: (context, index) {
                  var film = _searchController.text.isEmpty
                      ? movies[index]
                      : filteredMovies[index];
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Details(
                              imagepath: film.imagepath,
                              imageUrl: film.imageUrl,
                              movieName: film.movieName,
                              movieGenre: film.movieGenre,
                              director: film.director,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  image: film.imageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(film.imageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : film.imagepath != null
                                          ? DecorationImage(
                                              image: FileImage(
                                                  File(film.imagepath!)),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: Icon(Icons.add),
                                  onPressed: () {
                                    _showAddToCollectionDialog(film);
                                  },
                                  color: Colors.black,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MovieContainer(
                                      index: index,
                                      textMovie: film.movieName,
                                      textTur: film.movieGenre),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
      ),
    );
  }
}
