// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';

import '../utilities/constants.dart';

class Kayit extends StatefulWidget {
  const Kayit({super.key});

  @override
  State<Kayit> createState() => _KayitState();
}

class _KayitState extends State<Kayit> {
  late String email, password;
  final formkey = GlobalKey<FormState>();
  final firebaseAuth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstantsColor.backgroundColor,
      body: appBody(),
    );
  }

  SingleChildScrollView appBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  text18("E-Mail:"),
                  emailTextField(),
                  text18("Şifre:"),
                  sifreTextField(),
                  sizedBox(),
                  Center(
                    child: signUpButton(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextFormField sifreTextField() {
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

  TextField isimTextField() {
    return TextField(
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

  TextFormField emailTextField() {
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

  Widget signUpButton() {
    return ElevatedButton(
      onPressed: () async {
        if (formkey.currentState!.validate()) {
          formkey.currentState!.save();
          try {
            var userResult = await firebaseAuth.createUserWithEmailAndPassword(
                email: email, password: password);
            formkey.currentState!.reset();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Kayıt oluşturuldu, giriş yapabilirsiniz!")));
          } catch (e) {
            print(e.toString());
          }
        } else {}
      },
      child: Text(
        'Üye Ol',
        style: ConstantsStyle.primaryStyle,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: ConstantsColor.mainColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
    );
  }
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
