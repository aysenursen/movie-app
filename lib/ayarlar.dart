import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authentication/auth.dart';
import 'utilities/constants.dart';

class AyarlarSayfasi extends StatefulWidget {
  const AyarlarSayfasi({Key? key}) : super(key: key);

  @override
  State<AyarlarSayfasi> createState() => _AyarlarSayfasiState();
}

class _AyarlarSayfasiState extends State<AyarlarSayfasi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ConstantsColor.mainColor,
        title: Text(
          'Ayarlar',
          style: ConstantsStyle.headingBoldBlack,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: _showSignOutConfirmation,
              child: Text(
                'Çıkış Yap',
                style: ConstantsStyle.primaryOpStyle,
              ),
            ),
          ),
          Divider(thickness: 1),
        ],
      ),
    );
  }

  void _showSignOutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Çıkış Yap'),
          content: Text('Çıkış yapmak istediğinize emin misiniz?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('İptal'),
            ),
            TextButton(
              onPressed: () {
                _signOut();
              },
              child: Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  void _signOut() async {
    Navigator.of(context, rootNavigator: true).pop(); // Dialog'u kapatmak için

    await FirebaseAuth.instance.signOut();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Çıkış yapıldı'),
        duration: Duration(seconds: 2),
      ),
    );

    // Gerekirse burada başka bir sayfaya yönlendirme yapabilirsiniz.
    // Örneğin giriş sayfasına geri dönmek:
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (context) => Auth()));
  }
}
