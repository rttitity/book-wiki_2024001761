import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetailScreen extends StatefulWidget {
  final Map<String, dynamic> bookData; // 상세 페이지로 넘겨줄 도서 데이터

  const BookDetailScreen({Key? key, required this.bookData}) : super(key: key);

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  bool _isLoading = false; // 로딩 상태를 관리하는 변수
  bool isInCollection = false; // 책이 컬렉션에 저장되어 있는지 확인
  int recommendCount = 0; // 추천 수
  bool isRecommended = false; // 추천 여부 확인

  @override
  void initState() {
    super.initState();
    _fetchBookStats(); // Firestore에서 데이터 로드
  }

  // Firestore에서 추천 수와 컬렉션 상태 가져오기
  Future<void> _fetchBookStats() async {
    final bookId = widget.bookData['isbn'] ?? widget.bookData['title'];
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final docSnapshot =
    await FirebaseFirestore.instance.collection('Books').doc(bookId).get();

    final userBooksRef = FirebaseFirestore.instance
        .collection('UserProfile')
        .doc(user.uid)
        .collection('reading_books')
        .doc(bookId);

    final userRecommendedRef = FirebaseFirestore.instance
        .collection('Books')
        .doc(bookId)
        .collection('recommended_by')
        .doc(user.uid);

    final isBookInCollection = await userBooksRef.get();
    final isUserRecommended = await userRecommendedRef.get();

    if (docSnapshot.exists) {
      setState(() {
        recommendCount = docSnapshot.data()?['recommend_count'] ?? 0;
        isInCollection = isBookInCollection.exists;
        isRecommended = isUserRecommended.exists;
      });
    }
  }

  // 추천 기능: 중복 방지 및 UID 등록
  Future<void> _recommendBook() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다!')),
      );
      return;
    }

    final bookId = widget.bookData['isbn'] ?? widget.bookData['title'];
    final userRecommendedRef = FirebaseFirestore.instance
        .collection('Books')
        .doc(bookId)
        .collection('recommended_by')
        .doc(user.uid);

    if (isRecommended) {
      // 추천 취소
      await userRecommendedRef.delete();
      await FirebaseFirestore.instance.collection('Books').doc(bookId).update({
        'recommend_count': FieldValue.increment(-1),
      });
      setState(() {
        recommendCount -= 1;
        isRecommended = false;
      });
    } else {
      // 추천 등록
      await userRecommendedRef.set({'recommended_at': DateTime.now().toIso8601String()});
      await FirebaseFirestore.instance.collection('Books').doc(bookId).set({
        'title': widget.bookData['title'],
        'thumbnail': widget.bookData['thumbnail'],
        'recommend_count': FieldValue.increment(1),
      }, SetOptions(merge: true));
      setState(() {
        recommendCount += 1;
        isRecommended = true;
      });
    }
  }

  // 책 읽기 기능: 중복 방지 및 UID 등록
  Future<void> _startReadingBook() async {
    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // rootContext를 사용하여 SnackBar 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(Navigator.of(context).overlay!.context).showSnackBar(
          const SnackBar(content: Text('로그인이 필요합니다!')),
        );
      });
      setState(() => _isLoading = false);
      return;
    }

    final uid = user.uid;

    try {
      await FirebaseFirestore.instance
          .collection('UserProfile')
          .doc(uid)
          .collection('reading_books')
          .add({
        'title': widget.bookData['title'],
        'thumbnail': widget.bookData['thumbnail'],
        'added_at': DateTime.now().toIso8601String(),
        'status': 'reading',
      });

      // rootContext를 사용하여 SnackBar 표시
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(Navigator.of(context).overlay!.context).showSnackBar(
          const SnackBar(content: Text('책을 읽는 중으로 설정했습니다!')),
        );
      });
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(Navigator.of(context).overlay!.context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bookData['title']),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  widget.bookData['thumbnail'] ?? '',
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              Text('제목: ${widget.bookData['title']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('추천 수: $recommendCount'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _recommendBook,
                icon: Icon(
                  isRecommended ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                label: Text(isRecommended ? '추천 취소' : '추천'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _startReadingBook,
                icon: const Icon(Icons.menu_book, color: Colors.blue),
                label: const Text('책 읽기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
