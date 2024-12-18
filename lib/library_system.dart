import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'book_detail_screen.dart'; // 수정된 BookDetailScreen import
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 패키지 추가 => 카카오 API key 때문


class HttpApp extends StatefulWidget {
  const HttpApp({super.key});

  @override
  State<HttpApp> createState() => _HttpApp();
}

class _HttpApp extends State<HttpApp> {
  List<dynamic>? data = [];
  TextEditingController _editingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int page = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        page++;
        getJSONData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          decoration: const InputDecoration(hintText: "검색어를 입력하세요."),
        ),
      ),
      body: data!.isEmpty
          ? const Center(child: Text("도서 정보가 없습니다."))
          : ListView.builder(
        controller: _scrollController,
        itemCount: data!.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(bookData: data![index]),
                ),
              );
            },
            child: Card(
              child: Row(
                children: [
                  Image.network(
                    data![index]['thumbnail'],
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data![index]['title'].toString()),
                        Text('저자: ${data![index]['authors']}'),
                        Text('가격: ${data![index]['sale_price']}'),
                        Text('판매 상태: ${data![index]['status']}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          page = 1;
          data!.clear();
          getJSONData();
        },
        child: const Icon(Icons.search),
      ),
    );
  }

  Future<void> getJSONData() async {
    var url =
        'https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${Uri.encodeQueryComponent(_editingController.text)}';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "KakaoAK ${dotenv.env['KAKAO_API_KEY']}"},
      );

      if (response.statusCode == 200) {
        setState(() {
          var dataConvertedToJSON = json.decode(response.body);
          List<dynamic> result = dataConvertedToJSON['documents'];
          data!.addAll(result);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
