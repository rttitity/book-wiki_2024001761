import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 추가
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'models/content.dart';
import 'utils/toast.dart';

class InputScreen extends StatefulWidget {
  const InputScreen({Key? key}) : super(key: key);

  @override
  InputScreenState createState() => InputScreenState();
}

class InputScreenState extends State<InputScreen> {
  final TextEditingController controller = TextEditingController();
  XFile? _image;
  String? downloadUrl;

  Future<void> uploadFile() async {
    if (_image == null) return;
    try {
      final ref = FirebaseStorage.instance.ref().child('images/${DateTime.now().toIso8601String()}');
      await ref.putFile(File(_image!.path));
      downloadUrl = await ref.getDownloadURL();
    } catch (e) {
      showToast('Upload failed');
    }
  }

  Future<void> saveContent() async {
    await uploadFile();
    if (downloadUrl == null) return;

    final content = Content(
      content: controller.text,
      downloadUrl: downloadUrl!,
      date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      email: FirebaseAuth.instance.currentUser?.email ?? 'Anonymous',
    );

    await FirebaseFirestore.instance.collection('contents').add(content.toJson());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: Column(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Content'),
          ),
          ElevatedButton(
            onPressed: () async {
              _image = await ImagePicker().pickImage(source: ImageSource.gallery);
              setState(() {});
            },
            child: const Text('Pick Image'),
          ),
          if (_image != null) Image.file(File(_image!.path), height: 200), // 이미지 미리 보기
          ElevatedButton(onPressed: saveContent, child: const Text('Save')),
        ],
      ),
    );
  }
}
