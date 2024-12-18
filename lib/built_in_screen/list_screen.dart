import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/content.dart';
import 'package:book_wiki/built_in_screen//input_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  // Firestore에서 contents 컬렉션 가져오기 (내침차순 정렬)
  final contentsRef = FirebaseFirestore.instance
      .collection('contents')
      .orderBy('date', descending: true)
      .withConverter<Content>(
    fromFirestore: (snapshots, _) => Content.fromJson(snapshots.data()!),
    toFirestore: (content, _) => content.toJson(),
  );

  // InputScreen으로 이동
  Future<void> _navigateToInputScreen(BuildContext context) async {
    final isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InputScreen()),
    );

    if (isUpdated == true) {
      setState(() {}); // 새로고침
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('도서 게시판'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/auth');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Content>>(
        stream: contentsRef.snapshots(),
        builder: (context, snapshot) {
          // 로딩 중
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          // 게시물이 없을 경우
          if (data.docs.isEmpty) {
            return const Center(
              child: Text(
                '게시물이 없습니다.\n새로운 게시물을 추가해주세요!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            );
          }

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final content = data.docs[index].data();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: content.downloadUrl.isNotEmpty
                      ? Image.network(content.downloadUrl, width: 60, height: 60, fit: BoxFit.cover)
                      : const Icon(Icons.image_not_supported, size: 50),
                  title: Text(
                    content.content,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'By: ${content.email}\n${content.date}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToInputScreen(context),
        child: const Icon(Icons.add),
        tooltip: 'Add a new post',
      ),
    );
  }
}
