import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:classic/utilities/constants.dart';
import 'models/movie_models.dart';

class FilmEkle extends StatefulWidget {
  const FilmEkle({super.key});

  @override
  State<FilmEkle> createState() => _FilmEkleState();
}

class _FilmEkleState extends State<FilmEkle> {
  String? _imageUrl;
  ImagePicker picker = ImagePicker();
  TextEditingController filmAdiCtrl = TextEditingController();
  TextEditingController yonetmenCtrl = TextEditingController();
  String _selectedCollection = '';
  String _selectedGenre = '';

  final List<String> _genres = [
    'Aksiyon',
    'Komedi',
    'Dram',
    'Korku',
    'Bilim Kurgu',
    'Romantik',
    'Animasyon',
    'Fantastik',
    'Gerilim',
    'Macera',
    'Suç',
    'Belgesel',
    'Müzikal',
    'Savaş',
    'Western',
    'Biyografi',
    'Tarih'
  ];

  @override
  void initState() {
    super.initState();
    filmAdiCtrl.addListener(_fillFormIfMovieExists);
  }

  @override
  void dispose() {
    filmAdiCtrl.removeListener(_fillFormIfMovieExists);
    filmAdiCtrl.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String movieName = filmAdiCtrl.text.trim();

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('movie_images')
          .child('$movieName${DateTime.now().millisecondsSinceEpoch}.jpg');

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  Future<void> addMovieToCommonPool(izlenenFilmler movie) async {
    try {
      await FirebaseFirestore.instance
          .collection('all_movies')
          .add(movie.toJson());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Film genel havuza eklenirken bir hata oluştu: $e')),
      );
    }
  }

  void _fillFormIfMovieExists() async {
    String movieName = filmAdiCtrl.text.trim();
    if (movieName.isNotEmpty) {
      var moviesCollection =
          FirebaseFirestore.instance.collection('all_movies');
      var querySnapshot = await moviesCollection
          .where('movieName', isEqualTo: movieName)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var movieData = querySnapshot.docs.first.data();
        setState(() {
          _selectedGenre = movieData['movieGenre'] ?? '';
        });
        yonetmenCtrl.text = movieData['director'] ?? '';
        String? imagePath = movieData['imageUrl'];
        if (imagePath != null && imagePath.isNotEmpty) {
          setState(() {
            _imageUrl = imagePath;
          });
        }
      }
    }
  }

  Future<void> _addMovieToCollection(
      String collectionName, izlenenFilmler movie) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Film koleksiyona eklenirken bir hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> addMovieToAllCollections(izlenenFilmler movie) async {
    try {
      var usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userDoc.id)
            .collection('collection')
            .doc('default')
            .collection('movies')
            .doc(movie.movieName)
            .set(movie.toJson());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Film genel havuza eklenirken bir hata oluştu: $e'),
        ),
      );
    }
  }

  void _handleAddMovie() async {
    izlenenFilmler newMovie = izlenenFilmler(
      imageUrl: _imageUrl,
      movieName: filmAdiCtrl.text,
      movieGenre: _selectedGenre,
      director: yonetmenCtrl.text,
      averageRating: 0,
    );

    await addMovieToCommonPool(newMovie);
    await addMovieToAllCollections(newMovie);

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await showCollectionDialog(newMovie, currentUser.uid);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Film eklendi!')),
    );

    _clearTextFields();
  }

  Future<List<String>> fetchUserCollections(String userId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('collection')
          .get();

      List<String> collections =
          querySnapshot.docs.map((doc) => doc.id).toList();
      return collections;
    } catch (e) {
      print('Kullanıcı koleksiyonları alınırken hata oluştu: $e');
      return [];
    }
  }

  Future<void> showCollectionDialog(izlenenFilmler movie, String userId) async {
    List<String> collections = await fetchUserCollections(userId);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Koleksiyon Seçin'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return DropdownButton<String>(
                value:
                    _selectedCollection.isNotEmpty ? _selectedCollection : null,
                hint: Text('Koleksiyon seçin'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCollection = newValue!;
                  });
                },
                items:
                    collections.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: ConstantsStyle.primaryStyle,
                    ),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Tamam'),
              onPressed: () async {
                if (_selectedCollection.isNotEmpty) {
                  _addMovieToCollection(_selectedCollection, movie);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen bir koleksiyon seçin.')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _clearTextFields() {
    filmAdiCtrl.clear();
    yonetmenCtrl.clear();

    setState(() {
      _imageUrl = null;
      _selectedCollection = '';
      _selectedGenre = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ConstantsColor.mainColor,
        title: Text(
          'Film Ekle',
          style: ConstantsStyle.headingBoldBlack,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(75),
                    image: _imageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(_imageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageUrl == null
                      ? Icon(
                          Icons.camera_alt,
                          size: 50,
                          color: Colors.grey[700],
                        )
                      : null,
                ),
              ),
              sizedBox15(),
              Center(
                child: ElevatedButton(
                  onPressed: getImage,
                  child: Text(
                    'Resim Ekle',
                    style: ConstantsStyle.primaryStyle,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantsColor.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
              sizedBox15(),
              text18('Film Adı:'),
              textFieldMovie(filmAdiCtrl),
              text18('Tür:'),
              DropdownButtonFormField<String>(
                value: _selectedGenre.isNotEmpty ? _selectedGenre : null,
                hint: Text('Tür seçin'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGenre = newValue!;
                  });
                },
                items: _genres.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: ConstantsStyle.primaryStyle,
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              text18('Yönetmen:'),
              textFieldMovie(yonetmenCtrl),
              sizedBox15(),
              Center(
                child: ElevatedButton(
                  onPressed: _handleAddMovie,
                  child: Text(
                    'EKLE',
                    style: ConstantsStyle.primaryStyle,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConstantsColor.mainColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextField textFieldMovie(TextEditingController _controller) {
    return TextField(
      controller: _controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Text text18(String txt) {
    return Text(
      txt,
      style: ConstantsStyle.primaryOpStyle,
    );
  }

  SizedBox sizedBox15() {
    return SizedBox(
      height: 15,
    );
  }
}
