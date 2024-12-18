import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isLoading = false; // 로딩 상태

  Future<void> uploadFile() async {
    if (_image == null) return;
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().toIso8601String()}');
      await ref.putFile(File(_image!.path));
      downloadUrl = await ref.getDownloadURL();
    } catch (e) {
      showUploadToast('이미지 업로드 실패');
    }
  }

  Future<void> saveContent() async {
    setState(() {
      _isLoading = true; // 로딩 시작
    });

    await uploadFile();
    if (downloadUrl == null) {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
      return;
    }

    final content = Content(
      content: controller.text,
      downloadUrl: downloadUrl!,
      date: DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()),
      email: FirebaseAuth.instance.currentUser?.email ?? 'Anonymous',
    );

    try {
      await FirebaseFirestore.instance.collection('contents').add(content.toJson());
      showUploadToast('게시물 업로드 성공!', bgColor: Colors.green);
      Navigator.pop(context, true); // true를 반환해 게시판 화면 갱신
    } catch (e) {
      showUploadToast('게시물 업로드 실패');
    } finally {
      setState(() {
        _isLoading = false; // 로딩 종료
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                _image = await ImagePicker().pickImage(source: ImageSource.gallery);
                setState(() {}); // 이미지 선택 후 화면 갱신
              },
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            if (_image != null)
              Image.file(File(_image!.path), height: 200), // 이미지 미리 보기
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // 로딩 표시
                : ElevatedButton(
              onPressed: saveContent,
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
