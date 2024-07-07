// ignore_for_file: unused_local_variable

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final firebaseAuth = FirebaseAuth.instance;

  Future forgotPassword(String email) async {
    try {
      final result = await firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {}
  }

  Future<String?> signIn(String email, String password) async {
    String? res;
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      res = "success";
    } on FirebaseAuthException catch (e) {
      print("Exception code: ${e.code}");
      if (e.code == "user-not-found") {
        res = "Kullanıcı Bulunamadı";
      } else if (e.code == "wrong-password") {
        res = "Şifre Yanlış";
      } else if (e.code == "user-disabled") {
        res = "Kullanıcı Pasif";
      } else {
        res = "Bir hata oluştu";
      }
    }
    return res;
  }
}
