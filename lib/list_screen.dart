import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/content.dart';
import 'input_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final contentsRef = FirebaseFirestore.instance
      .collection('contents')
      .orderBy('date', descending: false) // 날짜 오름차순 정렬
      .withConverter<Content>(
    fromFirestore: (snapshots, _) => Content.fromJson(snapshots.data()!),
    toFirestore: (content, _) => content.toJson(),
  );

  Future<void> _navigateToInputScreen(BuildContext context) async {
    final isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InputScreen()),
    );

    if (isUpdated == true) {
      setState(() {}); // 화면 새로고침
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
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
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.requireData;

          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final content = data.docs[index].data();
              return ListTile(
                title: Text(content.content),
                subtitle: Text('By: ${content.email} on ${content.date}'),
                leading: Image.network(content.downloadUrl),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToInputScreen(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
