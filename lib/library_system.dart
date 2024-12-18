import 'package:flutter/material.dart'; // Flutter의 Material 디자인 라이브러리
import 'package:http/http.dart' as http; // HTTP 요청을 위한 라이브러리
import 'dart:convert'; // JSON 변환을 위한 라이브러리

// 앱의 진입점
void main() {
  runApp(MyApp()); // MyApp 위젯 실행
}

// MyApp 클래스는 애플리케이션의 루트를 정의
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp을 사용하여 앱의 구조를 설정
    return const MaterialApp(
      home: HttpApp(), // HttpApp을 홈 화면으로 설정
    );
  }
}

// HttpApp 클래스는 StatefulWidget으로, 상태를 관리
class HttpApp extends StatefulWidget {
  const HttpApp({super.key});

  @override
  State<HttpApp> createState() => _HttpApp(); // 상태 객체 생성
}

// _HttpApp 클래스는 HttpApp의 상태를 정의
class _HttpApp extends State<HttpApp> {
  List<dynamic>? data; // API에서 가져온 데이터를 저장할 리스트
  TextEditingController _editingController = TextEditingController(); // 검색어 입력을 위한 컨트롤러
  ScrollController _scrollController = ScrollController(); // 스크롤 이벤트를 처리하기 위한 컨트롤러
  int page = 1; // 현재 페이지 번호

  @override
  void initState() {
    super.initState();
    data = []; // 데이터 리스트 초기화
    // 스크롤 리스너 추가: 스크롤이 끝에 도달하면 다음 페이지 데이터 요청
    _scrollController.addListener(() {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
          !_scrollController.position.outOfRange) {
        page++; // 페이지 번호 증가
        getJSONData(); // 다음 페이지 데이터 요청
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // AppBar에 검색 입력 필드를 추가
        title: TextField(
          controller: _editingController, // 입력 컨트롤러 설정
          style: const TextStyle(color: Colors.blue), // 텍스트 색상 설정
          decoration: const InputDecoration(hintText: "검색어를 입력하세요."), // 힌트 텍스트
        ), // TextField
      ), // AppBar
      body: Container(
        padding: const EdgeInsets.all(16.0), // 컨테이너에 패딩 추가
        child: Center(
          child: data!.isEmpty // 데이터가 없을 경우
              ? const Text(
            "도서 정보가 없습니다.", // 데이터가 없다는 메시지
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          ) // Text
              : ListView.builder(
            itemCount: data!.length, // 데이터 개수
            itemBuilder: (context, index) {
              // ListView.builder를 사용하여 데이터 리스트 생성
              return Card(
                child: Row(
                  children: <Widget>[
                    // 책의 썸네일 이미지를 표시
                    Image.network(
                      data![index]['thumbnail'],
                      height: 100,
                      width: 100,
                      fit: BoxFit.contain,
                    ), // Image.network
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
                        children: <Widget>[
                          // 책 제목
                          Text(
                            data![index]['title'].toString(),
                            textAlign: TextAlign.center,
                          ), // Text
                          // 저자, 가격, 판매 상태 표시
                          Text('저자: ${data![index]['authors'].toString()}'),
                          Text('가격: ${data![index]['sale_price'].toString()}'),
                          Text('판매중: ${data![index]['status'].toString()}'),
                        ], // <Widget>[]
                      ), // Column
                    ) // Expanded
                  ], // <Widget>[]
                ), // Row
              ); // Card
            },
            controller: _scrollController,  // 스크롤 컨트롤러 설정
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // FAB 클릭 시 페이지 초기화 및 데이터 새로고침
          page = 1;
          data!.clear();
          getJSONData();
        },
        child: const Icon(Icons.search),   // 다운로드 아이콘
      ),
    );
  }

  // JSON 데이터를 가져오는 비동기 함수
  Future<void> getJSONData() async {
    // Kakao API에서 데이터 요청
    var url =
        'https://dapi.kakao.com/v3/search/book?target=title&page=$page&query=${Uri.encodeQueryComponent(_editingController.text)}';
    try {
      // HTTP GET 요청
      var response = await http.get(Uri.parse(url),
          headers: { "Authorization": "KakaoAK 51bf2936de6a07f770d910e1fb2cf177" });

      // 응답 상태가 200일 경우
      if (response.statusCode == 200) {
        setState(() {
          var dataConvertedToJSON = json.decode(response.body); // JSON 변환
          List<dynamic> result = dataConvertedToJSON['documents'];  // 책 데이터
          data!.addAll(result); // 기존 데이터에 추가
        });
      } else {
        throw Exception('Failed to load data'); // 오류 처리
      }
    } catch (e) {
      print('Error: $e'); // 오류 메시지 출력
    }
  }
}

