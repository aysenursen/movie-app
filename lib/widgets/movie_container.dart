// ignore_for_file: prefer_const_constructors

import 'package:classic/utilities/constants.dart';
import 'package:flutter/material.dart';

//import '../utilities/constants.dart';

//import '../movie_models.dart';

class MovieContainer extends StatelessWidget {
  const MovieContainer(
      {super.key,
      required this.index,
      required this.textMovie,
      required this.textTur});
  final int index;
  final String textMovie;
  final String textTur;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textMovie,
              style: ConstantsStyle.primaryStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 50,
              child: Divider(
                height: 8,
                color: Colors.black,
              ),
            ),
            Text(
              textTur,
              style: ConstantsStyle.tinyprimaryStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
