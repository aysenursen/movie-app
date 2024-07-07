// ignore_for_file: unused_local_variable

import 'package:classic/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/navbar.dart';
import '../utilities/constants.dart';

class Giris extends StatefulWidget {
  const Giris({super.key});

  @override
  State<Giris> createState() => _GirisState();
}

class _GirisState extends State<Giris> {
  late String email, password;
  final formkey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;
  AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Form(
            key: formkey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                text18("E-Mail:"),
                mailtextField(),
                text18("Şifre:"),
                sifretextField(),
                //forgotButton(),
                sizedBox(),
                loginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn() async {
    if (formkey.currentState!.validate()) {
      formkey.currentState!.save();
      final result = await authService.signIn(email, password);
      if (result == "success") {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => NavBar()),
            (route) => false);
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text("Hata"),
                  content: Text(result!),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Geri Dön"))
                  ]);
            });
      }
    }
  }

  Center loginButton() {
    return Center(
      child: ElevatedButton(
        onPressed:
            signIn /*() async {
          if (formkey.currentState!.validate()) {
            formkey.currentState!.save();
            try {
              final userResult = await firebaseAuth.signInWithEmailAndPassword(
                  email: email, password: password);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => NavBar()));
              print(userResult.user!.email);
            } catch (e) {
              print(e.toString());
            }
          } else {}
        }*/
        ,
        child: Text(
          'Giriş Yap',
          style: ConstantsStyle.primaryStyle,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ConstantsColor.mainColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
        ),
      ),
    );
  }

  Center forgotButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          final result = authService.forgotPassword(email);
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: Text("Şifrenizi mi unuttunuz?"),
                    content: Text("Mail kutunuzu kontrol ediniz."),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Tamam"))
                    ]);
              });
        },
        child: Text(
          'Şifremi Unuttum',
          style: ConstantsStyle.fadeprimaryOpStyle,
        ),
      ),
    );
  }

  TextFormField mailtextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
        return null;
      },
      onSaved: (value) {
        email = value!;
      },
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

  TextFormField sifretextField() {
    return TextFormField(
      validator: (value) {
        if (value!.isEmpty) {
          return "Bilgileri Eksiksiz Doldurunuz";
        } else {}
        return null;
      },
      onSaved: (value) {
        password = value!;
      },
      obscureText: true,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Text text18(txt) {
    return Text(
      txt,
      style: ConstantsStyle.primaryOpStyle,
    );
  }

  SizedBox sizedBox() {
    return SizedBox(
      height: 40,
    );
  }
}
