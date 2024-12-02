import 'package:flutter/material.dart';
import 'Search_test.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tmap 테스트',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchTestPage(), // 시작 페이지를 검색 테스트로 설정
    );
  }
}
