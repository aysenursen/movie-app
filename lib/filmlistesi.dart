import 'dart:io';
import 'package:classic/models/movie_models.dart';
import 'package:classic/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'movieReviewUser.dart';
import 'widgets/movie_container.dart';

class FilmList extends StatefulWidget {
  final String kartAdi;
  const FilmList({Key? key, required this.kartAdi}) : super(key: key);

  @override
  State<FilmList> createState() => _FilmListState();
}

class _FilmListState extends State<FilmList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<izlenenFilmler> userMovies = [];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    var user = _auth.currentUser;
    if (user != null) {
      var snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('collection')
          .doc(widget.kartAdi)
          .collection('movies')
          .get();
      setState(() {
        userMovies = snapshot.docs
            .map((doc) =>
                izlenenFilmler.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      });
    }
  }

  void _removeMovie(String movieName) async {
    var user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('collection')
          .doc(widget.kartAdi)
          .collection('movies')
          .doc(movieName)
          .delete();
      _fetchMovies();
    }
  }

  void _showAddToCollectionDialog(izlenenFilmler movie) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Koleksiyona Ekle'),
          content: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_auth.currentUser?.uid)
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addMovieToCollection(
      String collectionName, izlenenFilmler movie) async {
    var currentUser = _auth.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('collection')
          .doc(collectionName)
          .collection('movies')
          .doc(movie.movieName)
          .set(movie.toJson());
      _fetchMovies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xffFFD233),
        title: Text(
          widget.kartAdi,
          style: ConstantsStyle.headingBoldBlack,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      backgroundColor: ConstantsColor.backgroundColor,
      body: SafeArea(
        child: userMovies.isEmpty
            ? Center(
                child: Text(
                  'Film Listesi Boş',
                  style: ConstantsStyle.primaryOpStyle,
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ConstantsScale.gridAxisCount,
                    childAspectRatio: ConstantsScale.gridAspectRatio),
                itemCount: userMovies.length,
                itemBuilder: (context, index) {
                  var film = userMovies[index];
                  return Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReviewUser(
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
                          width: 155,
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
                                        image: FileImage(File(film.imagepath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PopupMenuButton(
                                  icon: Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'delete') {
                                      _removeMovie(film.movieName);
                                    } else if (value == 'addToCollection') {
                                      _showAddToCollectionDialog(film);
                                    }
                                  },
                                  itemBuilder: ((context) => [
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text("Sil"),
                                        ),
                                        PopupMenuItem(
                                          value: 'addToCollection',
                                          child: Text("Koleksiyona Ekle"),
                                        ),
                                      ])),
                              MovieContainer(
                                  index: index,
                                  textMovie: film.movieName,
                                  textTur: film.movieGenre),
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
