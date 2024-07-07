import 'package:classic/sayfam.dart';
import 'package:classic/utilities/constants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'arsivim.dart';
import 'ayarlar.dart';
import 'profilDüzenle.dart';

class ProfilSayfasi extends StatefulWidget {
  const ProfilSayfasi({Key? key}) : super(key: key);

  @override
  State<ProfilSayfasi> createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _username = '-';
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getUserInfo();
  }

  void _getUserInfo() async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser?.uid);

    final userData = await userDoc.get();

    if (userData.exists) {
      if (mounted) {
        setState(() {
          _username = userData['username'] ?? '-';
          _profileImageUrl = userData['profileImageUrl'];
        });
      }
    } else {
      await userDoc.set({
        'username': '-',
        'profileImageUrl': null,
      });
      if (mounted) {
        setState(() {
          _username = '-';
          _profileImageUrl = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      appBar: AppBar(
        backgroundColor: ConstantsColor.mainColor,
        title: Text('Profilim', style: ConstantsStyle.headingBoldBlack),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AyarlarSayfasi(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilDuzenle(),
                ),
              ).then((value) {
                _getUserInfo();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(Icons.person, size: 60)
                      : null,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _username,
                      style: ConstantsStyle.headingStyleWhite,
                    ),
                    Text(
                      _auth.currentUser?.email ?? '',
                      style: ConstantsStyle.tinyprimaryOpStyle,
                    )
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(16.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 4.0,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(
                    child: Text(
                      'Koleksiyonlarım',
                      style: ConstantsStyle.tinyprimaryOpStyle,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Tüm Filmlerim',
                      style: ConstantsStyle.tinyprimaryOpStyle,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  Arsivim(),
                  Sayfam(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
