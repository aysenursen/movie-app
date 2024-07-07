import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConstantsStyle {
  static final TextStyle headingBoldBlack = GoogleFonts.cabin(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static final TextStyle headingBoldWhite = GoogleFonts.cabin(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  static final TextStyle headingStyleWhite = GoogleFonts.cabin(
    fontSize: 24,
    color: Colors.white,
  );
  static final TextStyle paleStyleGrey = GoogleFonts.cabin(
    fontSize: 18,
    color: Colors.white70,
  );
  static final TextStyle primaryStyle = GoogleFonts.cabin(
    fontSize: 18,
    color: Colors.black,
  );
  static final TextStyle primaryOpStyle = GoogleFonts.cabin(
    fontSize: 18,
    color: Colors.white,
  );
  static final TextStyle tinyprimaryOpStyle = GoogleFonts.cabin(
    fontSize: 15,
    color: Colors.white,
  );
  static final TextStyle fadeprimaryOpStyle = GoogleFonts.cabin(
    fontSize: 15,
    color: Colors.white70,
  );
  static final TextStyle tinyprimaryStyle = GoogleFonts.cabin(
    fontSize: 14,
    color: Colors.black,
  );
  static final TextStyle posterStyle = GoogleFonts.leagueGothic(
    fontSize: 30,
    color: Colors.black,
  );
  static final TextStyle tinyposterStyle = GoogleFonts.leagueGothic(
    fontSize: 20,
    color: Colors.black,
  );
}

class ConstantsColor {
  static final Color mainColor = Color(0xffFFD233);
  static final Color backgroundColor = Color(0xff31373D);
}

class ConstantsScale {
  static const double containerHeight = 0.2;
  static const double containerWidth = 0.3;
  static const double containerHeightPoster = 0.26;
  static const double containerWidthPoster = 0.36;
  static const double maincontainerHeightPoster = 0.36;
  static const double maincontainerWidthPoster = 0.5;
  static const int gridAxisCount = 2;
  static const double gridAspectRatio = 0.85;
  static const EdgeInsets paddingFirst = EdgeInsets.all(15.0);
  static const EdgeInsets padding20 = EdgeInsets.all(20.0);
}
