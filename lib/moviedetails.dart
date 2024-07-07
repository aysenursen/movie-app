import 'dart:io';
import 'package:classic/models/rating_bar.dart';
import 'package:classic/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class Details extends StatefulWidget {
  final String? imagepath;
  final String? imageUrl;
  final String movieName;
  final String movieGenre;
  final String director;
  double rate;
  String comment;
  final bool fromAllMovies;

  Details({
    super.key,
    this.imagepath,
    this.imageUrl,
    this.movieName = '',
    this.movieGenre = '',
    this.director = '',
    this.rate = 0,
    this.comment = '',
    this.fromAllMovies = false,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && _commentController.text.isNotEmpty) {
      try {
        await FirebaseFirestore.instance
            .collection('all_movies')
            .doc(widget.movieName)
            .collection('comments')
            .add({
          'comment': _commentController.text,
          'userID': currentUser.uid,
          'userEmail': currentUser.email,
          'profilePictureUrl': (await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser.uid)
                      .get())
                  .data()?['profilePictureUrl'] ??
              '',
          'timestamp': FieldValue.serverTimestamp(),
        });
        _commentController.clear();
      } catch (e) {
        print('Error adding comment: $e');
      }
    } else {
      print('Comment or currentUser is empty');
    }
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
          maxLines: 5,
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

  Widget _buildCommentsSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('all_movies')
          .doc(widget.movieName)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var comments = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            var commentData = comments[index].data() as Map<String, dynamic>;
            var userId = commentData['userID'];
            var commentText = commentData['comment'];
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading photo: ${snapshot.error}');
                } else {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  var photoURL = userData['profileImageUrl'];
                  var username = userData['username'];
                  var userEmail = userData['userEmail'];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(photoURL ?? ''),
                    ),
                    title: Text(
                      username ?? userEmail ?? 'Bilinmeyen Kullanıcı',
                      style: ConstantsStyle.primaryOpStyle,
                    ),
                    subtitle: Text(
                      commentText,
                      style: ConstantsStyle.tinyprimaryOpStyle,
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  void _navigateToRatingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RatingPage(movieName: widget.movieName),
      ),
    );
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
                            _buildRatingInput(),
                            _buildCommentTextArea(),
                            _buildCommentsSection(),
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
      ),
    );
  }

  Widget _buildRatingInput() {
    return Center(
      child: ElevatedButton(
        onPressed: _navigateToRatingPage,
        child: Text(
          'Puan Ver',
          style: ConstantsStyle.tinyprimaryStyle,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  Container _buildCommentTextArea() {
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
              Text('Yorumlar:', style: ConstantsStyle.primaryStyle),
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
      child: widget.imageUrl == null && widget.imagepath == null
          ? Center(
              child: Icon(
              Icons.movie,
              color: Colors.white,
            ))
          : null,
    );
  }

  SizedBox _buildSizedBox10() {
    return SizedBox(
      height: 10,
    );
  }

  Future<void> _updateAverageRate(double averageRate) async {
    try {
      await FirebaseFirestore.instance
          .collection('all_movies')
          .doc(widget.movieName)
          .update({'averageRate': averageRate});
    } catch (e) {
      print('Error updating average rate: $e');
    }
  }

  Widget _buildRateText() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('all_movies')
          .doc(widget.movieName)
          .collection('ratings')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Puan yükleniyor...',
              style: ConstantsStyle.tinyprimaryOpStyle);
        }
        if (snapshot.hasError) {
          return Text('Bir hata oluştu',
              style: ConstantsStyle.tinyprimaryOpStyle);
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('Henüz puan verilmemiş',
              style: ConstantsStyle.tinyprimaryOpStyle);
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
        _updateAverageRate(averageRate);
        return Text('${averageRate.toStringAsFixed(1)}/10',
            style: ConstantsStyle.tinyprimaryOpStyle);
      },
    );
  }

  Text _buildGenreText() {
    return Text(widget.movieGenre, style: ConstantsStyle.tinyprimaryOpStyle);
  }

  Text _buildDirectorText() {
    return Text(widget.director, style: ConstantsStyle.tinyprimaryOpStyle);
  }
}
