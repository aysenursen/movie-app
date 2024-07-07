import 'dart:io';
import 'package:classic/models/rate_private.dart';
import 'package:classic/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ReviewUser extends StatefulWidget {
  final String? imagepath;
  final String? imageUrl;
  final String movieName;
  final String movieGenre;
  final String director;
  double rate;

  ReviewUser({
    this.imagepath,
    this.imageUrl,
    required this.movieName,
    required this.movieGenre,
    required this.director,
    this.rate = 0,
  });

  @override
  State<ReviewUser> createState() => _ReviewUserState();
}

class _ReviewUserState extends State<ReviewUser> {
  TextEditingController _commentController = TextEditingController();
  double _selectedRate = 0.0;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _selectedRate = widget.rate;
    _fetchRating();
    _userId = FirebaseAuth.instance.currentUser?.uid;
  }

  void _fetchRating() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc('movies')
          .collection(widget.movieName)
          .doc(user.uid)
          .get();

      if (snapshot.exists) {
        var data = snapshot.data();
        setState(() {
          _selectedRate = data?['rating'] ?? 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.cabinTextTheme(Theme.of(context).textTheme),
      ),
      home: Scaffold(
        backgroundColor: ConstantsColor.backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: ConstantsColor.mainColor,
          title: Text(widget.movieName, style: ConstantsStyle.headingBoldBlack),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildDirectorText(),
                            _buildGenreText(),
                            _buildRateText(),
                            _buildSizedBox10(),
                            _buildMovieContainer(context),
                            _buildSizedBox10(),
                            _buildCommentTextArea(),
                            _buildCommentSection(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCommentInput(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RatePrivate(
                  movieName: widget.movieName,
                ),
              ),
            );
          },
          child: Icon(Icons.star),
        ),
      ),
    );
  }

  Widget _buildCommentTextArea() {
    return Container(
      height: 50,
      color: ConstantsColor.mainColor,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Yorumum:', style: ConstantsStyle.primaryStyle),
            ],
          ),
        ),
      ),
    );
  }

  Container _buildMovieContainer(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          ConstantsScale.containerWidthPoster,
      height: MediaQuery.of(context).size.height *
          ConstantsScale.containerHeightPoster,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: widget.imageUrl != null
            ? DecorationImage(
                image: NetworkImage(widget.imageUrl!),
                fit: BoxFit.cover,
              )
            : widget.imagepath != null
                ? DecorationImage(
                    image: FileImage(File(widget.imagepath!)),
                    fit: BoxFit.cover,
                  )
                : null,
      ),
    );
  }

  SizedBox _buildSizedBox10() {
    return SizedBox(
      height: 10,
    );
  }

  Widget _buildRateText() {
    return Text(
      '${_selectedRate.toStringAsFixed(1)}/10',
      style: ConstantsStyle.tinyprimaryOpStyle,
    );
  }

  Text _buildGenreText() {
    return Text(widget.movieGenre, style: ConstantsStyle.tinyprimaryOpStyle);
  }

  Text _buildDirectorText() {
    return Text(widget.director, style: ConstantsStyle.tinyprimaryOpStyle);
  }

  Widget _buildCommentInput() {
    return Column(
      children: [
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            labelText: "Yorumunuzu yazın...",
            labelStyle: ConstantsStyle.fadeprimaryOpStyle,
            border: OutlineInputBorder(),
          ),
          minLines: 1,
          style: ConstantsStyle.tinyprimaryOpStyle,
        ),
        Center(
          child: ElevatedButton(
            onPressed: _addComment,
            child: Text(
              'Yorum Ekle',
              style: ConstantsStyle.tinyprimaryStyle,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        )
      ],
    );
  }

  _addComment() {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('collections')
          .doc('movies')
          .collection(widget.movieName)
          .add({
        'comment': _commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) {
        _commentController.clear();
      }).catchError((error) {
        print("Hata oluştu: $error");
      });
    }
  }

  Widget _buildCommentSection() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .collection('collections')
          .doc('movies')
          .collection(widget.movieName)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text(
            'Henüz yorum yapılmamış.',
            style: ConstantsStyle.tinyprimaryOpStyle,
          );
        } else {
          return Column(
            children: snapshot.data!.docs.map((document) {
              Map<String, dynamic>? data =
                  document.data() as Map<String, dynamic>?;
              if (data != null && data.containsKey('comment')) {
                return ListTile(
                  title: Text(
                    data['comment'] ?? '',
                    style: ConstantsStyle.tinyprimaryOpStyle,
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            }).toList(),
          );
        }
      },
    );
  }
}
