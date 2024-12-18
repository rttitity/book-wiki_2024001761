import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:book_wiki/User_profile_screen/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user.uid)
        .get();
    setState(() {
      _userData = doc.data();
    });
  }

  Stream<QuerySnapshot> _readingBooksStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user?.uid)
        .collection('reading_books')
        .snapshots();
  }

  Stream<QuerySnapshot> _completedBooksStream() {
    final user = FirebaseAuth.instance.currentUser;
    return FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user?.uid)
        .collection('completed_books')
        .snapshots();
  }

  Future<void> _markAsCompleted(String bookId, Map<String, dynamic> bookData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userBooksRef = FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user.uid)
        .collection('reading_books')
        .doc(bookId);

    final completedBooksRef = FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user.uid)
        .collection('completed_books')
        .doc(bookId);

    await userBooksRef.delete();

    await completedBooksRef.set({
      'title': bookData['title'],
      'thumbnail': bookData['thumbnail'],
      'completed_at': DateTime.now().toIso8601String(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('책이 다 읽음 상태로 변경되었습니다!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('프로필'),
          centerTitle: true,
        ),
        body: _userData == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [

            // 사용자 프로필 정보
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _userData!['photoURL'] != null
                      ? NetworkImage(_userData!['photoURL'])
                      : const AssetImage('assets/default_profile.png') as ImageProvider,
                ),
                Column(
                  children: [
                    Text(
                      _userData!['displayName'] ?? 'Anonymous',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user?.email ?? '이메일 정보 없음',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                _userData!['bio'] ?? '자기소개를 추가해주세요.',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updatedData = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                    if (updatedData != null) {
                      setState(() {
                        _userData = updatedData;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                  child: const Text(
                    '프로필 편집',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const TabBar(
              labelColor: Colors.blue,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(icon: Icon(Icons.book), text: "읽고 있는 책"),
                Tab(icon: Icon(Icons.done), text: "다 읽은 책"),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: _readingBooksStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final books = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index].data() as Map<String, dynamic>;
                          final bookId = books[index].id;

                          return ListTile(
                            leading: Image.network(
                              book['thumbnail'] ?? '',
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(book['title'] ?? '제목 없음'),
                            trailing: ElevatedButton(
                              onPressed: () => _markAsCompleted(bookId, book),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                              child: const Text('다 읽음', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _completedBooksStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                      final books = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index].data() as Map<String, dynamic>;

                          return ListTile(
                            leading: Image.network(
                              book['thumbnail'] ?? '',
                              width: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(book['title'] ?? '제목 없음'),
                            subtitle: Text('완료 날짜: ${book['completed_at'] ?? '정보 없음'}'),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
