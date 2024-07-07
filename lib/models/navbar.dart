// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../anasayfa.dart';
import '../filmekle.dart';
import '../profilSayfasi.dart';
import '../tumfilmler.dart';
import '../utilities/constants.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentindex = 0;
  final pages = <Widget>[
    AnaSayfa(),
    FilmEkle(),
    TumFilmler(),
    ProfilSayfasi(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: pages[_currentindex],
        backgroundColor: ConstantsColor.backgroundColor,
        bottomNavigationBar: CurvedNavigationBar(
            backgroundColor: ConstantsColor.backgroundColor,
            color: ConstantsColor.mainColor,
            animationDuration: Duration(milliseconds: 250),
            height: 55,
            onTap: (index) {
              setState(() {
                _currentindex = index;
              });
            },
            items: [
              Icon(Icons.home),
              Icon(Icons.add),
              Icon(Icons.movie),
              Icon(Icons.person),
            ]),
      ),
    );
  }
}
