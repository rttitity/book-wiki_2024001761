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

  // Firestore에 추천 수를 업데이트하는 함수
  Future<void> _recommendBook() async {
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance.collection('recommended_books').doc(widget.bookData['title']).set({
      'title': widget.bookData['title'],
      'thumbnail': widget.bookData['thumbnail'],
      'recommend_count': FieldValue.increment(1), // 추천 수 증가
    }, SetOptions(merge: true));
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('책이 추천되었습니다!')));
  }

  // Firestore에 "읽는 중" 데이터를 추가하는 함수
  Future<void> _addToReadingList() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다!')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final uid = user.uid; // UID 가져오기

    await FirebaseFirestore.instance
        .collection('UserProfile') // 최상위 컬렉션
        .doc(uid) // 사용자 UID 문서
        .collection('reading_books') // 하위 컬렉션
        .add({
      'title': widget.bookData['title'],
      'thumbnail': widget.bookData['thumbnail'],
      'added_at': DateFormat("yyyy-MM-dd HH:mm:ss").format(DateTime.now()), // 읽기 시작 시간
    });

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('책이 읽는 중에 추가되었습니다!')),
    );
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
            mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
            children: [
              Center(
                child: Image.network(
                  widget.bookData['thumbnail'],
                  height: 200,
                ),
              ),
              const SizedBox(height: 20),
              Text('제목: ${widget.bookData['title']}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('저자: ${widget.bookData['authors']}'),
              Text('가격: ${widget.bookData['sale_price']}'),
              Text('출판 상태: ${widget.bookData['status']}'),
              Text('ISBN: ${widget.bookData['isbn']}'),
              const SizedBox(height: 50), // 버튼과 위 텍스트 사이 여백
              if (_isLoading) // 로딩 중일 때 프로그레스 인디케이터 표시
                const Center(child: CircularProgressIndicator())
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center, // 버튼을 중앙 정렬
                  children: [
                    ElevatedButton.icon(
                      onPressed: _recommendBook,
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      label: const Text('추천'),
                    ),
                    const SizedBox(height: 20), // 버튼 간 간격
                    ElevatedButton.icon(
                      onPressed: _addToReadingList,
                      icon: const Icon(Icons.menu_book, color: Colors.blue),
                      label: const Text('책 읽기'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
