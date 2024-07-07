import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:classic/utilities/constants.dart'; // Constants'ın doğru yolu kontrol edilmeli.

class RatingPage extends StatefulWidget {
  final String movieName;

  const RatingPage({Key? key, required this.movieName}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  double _currentRating = 0.0;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int starCount = 10;
    double itemSize = screenWidth / (starCount * 1.5);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ConstantsColor.mainColor,
        title: Text("Puan Ver", style: ConstantsStyle.headingBoldBlack),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Bu filme kaç yıldız vermek istersiniz?",
                style: ConstantsStyle.primaryStyle),
            SizedBox(height: 20),
            RatingBar.builder(
              initialRating: _currentRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: starCount,
              itemSize: itemSize,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _currentRating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitRating(context),
              child: Text(
                'Puanı Kaydet',
                style: ConstantsStyle.tinyprimaryStyle,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitRating(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('all_movies')
          .doc(widget.movieName)
          .collection('ratings')
          .doc(user.uid)
          .set({
        'rate': _currentRating,
        'timestamp': FieldValue.serverTimestamp(),
      }).then((value) => Navigator.pop(context));
    }
  }
}
