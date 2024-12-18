import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  File? _selectedImage;
  bool _isLoading = false; // 로딩 상태

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true; // 로딩 시작
    });

    String? photoURL;

    // Firebase Storage에 이미지 업로드
    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance.ref().child('profile_images/${user.uid}.jpg');
      await storageRef.putFile(_selectedImage!);
      photoURL = await storageRef.getDownloadURL();
    }

    // Firestore에 데이터 저장
    final userProfileData = {
      'email': user.email,
      'displayName': _displayNameController.text.isEmpty ? user.displayName : _displayNameController.text,
      'photoURL': photoURL ?? user.photoURL,
      'bio': _bioController.text,
    };

    await FirebaseFirestore.instance.collection('UserProfile').doc(user.uid).set(userProfileData);

    setState(() {
      _isLoading = false; // 로딩 종료
    });

    // 데이터 업데이트 후 프로필 페이지 리빌드
    Navigator.pop(context, userProfileData); // 프로필 페이지로 데이터 전달
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 편집'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : const AssetImage('assets/default_profile.png') as ImageProvider,
                child: const Icon(Icons.camera_alt, size: 30, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _displayNameController,
              decoration: const InputDecoration(
                labelText: '닉네임',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: '자기소개 코멘트',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // 로딩 표시
                : ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
