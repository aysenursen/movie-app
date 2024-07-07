import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:classic/utilities/constants.dart';
import 'models/movie_models.dart';
import 'filmlistesi.dart';

class Arsivim extends StatefulWidget {
  const Arsivim({super.key});

  @override
  State<Arsivim> createState() => _ArsivimState();
}

class _ArsivimState extends State<Arsivim> {
  final TextEditingController _cardController = TextEditingController();
  List<kartlar> kartListesi = [];

  @override
  void initState() {
    super.initState();
    _fetchCollections();
  }

  Stream<QuerySnapshot> _collectionStream() {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('collection')
          .snapshots();
    } else {
      return Stream.empty();
    }
  }

  void _fetchCollections() {
    _collectionStream().listen((QuerySnapshot snapshot) {
      List<kartlar> collections =
          snapshot.docs.map((doc) => kartlar(kartAdi: doc.id)).toList();
      setState(() {
        kartListesi = collections;
      });
    });
  }

  void _addCollection(String collectionName) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('collection')
          .doc(collectionName)
          .set({});
      _fetchCollections();
    }
  }

  Future<void> _removeCollection(String collectionName) async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .collection('collection')
          .doc(collectionName)
          .delete();
      _fetchCollections();
    }
  }

  void _showAddCollectionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Koleksiyon Ekle'),
          content: TextField(
            controller: _cardController,
            decoration: InputDecoration(hintText: "Koleksiyon ismini giriniz"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('İptal'),
              onPressed: () {
                Navigator.of(context).pop();
                _cardController.clear();
              },
            ),
            TextButton(
              child: Text('Ekle'),
              onPressed: () {
                if (_cardController.text.isNotEmpty) {
                  _addCollection(_cardController.text);
                }
                Navigator.of(context).pop();
                _cardController.clear();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String collectionName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text(
              '$collectionName koleksiyonunu silmek istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text('Evet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      body: ListView.builder(
        itemCount: kartListesi.length,
        itemBuilder: (context, index) {
          final item = kartListesi[index];
          return Dismissible(
            key: Key(item.kartAdi),
            confirmDismiss: (direction) async {
              final bool? result =
                  await _showConfirmationDialog(context, item.kartAdi);
              if (result == true) {
                try {
                  await _removeCollection(item.kartAdi);
                  setState(() {
                    if (index < kartListesi.length) {
                      kartListesi.removeAt(index);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.kartAdi} silindi')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bir hata oluştu: $e')),
                  );
                }
              }
              return result;
            },
            background: Container(color: Colors.red),
            child: Card(
              margin: EdgeInsets.all(10),
              child: ListTile(
                title: Text(item.kartAdi, style: ConstantsStyle.primaryStyle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilmList(
                        kartAdi: item.kartAdi,
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        onPressed: _showAddCollectionDialog,
        tooltip: 'Koleksiyon Ekle',
        child: Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
