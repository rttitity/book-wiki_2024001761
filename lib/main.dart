import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'User_profile_screen/profile_screen.dart';
import 'built_in_screen/list_screen.dart'; // 독후감 게시판 위젯
import 'login_screen/auth_screen.dart';
import 'firebase_options.dart';
import 'package:book_wiki/login_screen/verification_screen.dart';
import 'search_book/library_system.dart';   // 도서 검색 화면 위젯
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 패키지 추가 => 카카오 API key 때문


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookWiki',
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/auth' : '/list',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/list': (context) => const HomeScreen(),
        '/verification': (context) => const VerificationScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ListScreen(),
    const HttpApp(), // 도서 검색 화면 추가
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '게시판',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
