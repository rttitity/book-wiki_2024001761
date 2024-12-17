import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/content.dart';
import 'input_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final contentsRef = FirebaseFirestore.instance.collection('contents').withConverter<Content>(
      fromFirestore: (snapshots, _) => Content.fromJson(snapshots.data()!),
      toFirestore: (content, _) => content.toJson(),
    );

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
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InputScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }
}
