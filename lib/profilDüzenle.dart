import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilDuzenle extends StatefulWidget {
  @override
  _ProfilDuzenleState createState() => _ProfilDuzenleState();
}

class _ProfilDuzenleState extends State<ProfilDuzenle> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _usernameController = TextEditingController();
  String? _profileImageUrl;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_auth.currentUser?.uid}.jpg');
      await storageRef.putFile(File(pickedFile.path));
      final downloadUrl = await storageRef.getDownloadURL();
      if (mounted) {
        setState(() {
          _profileImageUrl = downloadUrl;
        });
      }
    }
  }

  Future<void> _updateProfile(
      String newUsername, String? newProfileImageUrl) async {
    try {
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser?.uid);
      await userDoc.update({
        'username': newUsername,
        if (newProfileImageUrl != null) 'profileImageUrl': newProfileImageUrl,
      });
    } catch (e) {
      print('Profil güncelleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Düzenle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(Icons.camera_alt, size: 60)
                      : null,
                ),
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir kullanıcı adı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _updateProfile(
                        _usernameController.text, _profileImageUrl);
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
