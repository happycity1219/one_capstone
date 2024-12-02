import 'package:flutter/material.dart';

class MyPageModify extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // 배경색을 동일하게 설정
      appBar: AppBar(
        backgroundColor: Colors.grey[800], // 상단 배경색
        elevation: 0, // 그림자 제거
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // 뒤로 가기 버튼
          onPressed: () {
            Navigator.pop(context); // 이전 화면으로 이동
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.white), // 홈 버튼
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst); // 홈 화면으로 이동
            },
          ),
        ],
        title: Text(
          '내 정보 수정', // 제목을 `내 정보 수정`으로 설정
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true, // 제목 중앙 정렬
      ),
      body: Container(
        color: Colors.grey[300], // 전체 배경색
        child: Column(
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[400],
              child: Icon(Icons.image, size: 50, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(
              "닉네임",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30), // 닉네임과 첫 번째 버튼 간 간격 추가
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 닉네임 변경 기능
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("닉네임 변경"),
                  ),
                  SizedBox(height: 20), // 버튼과 이메일 필드 간 간격 추가
                  TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: "이메일 변경불가",
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: TextEditingController(
                      text: "helloworld@happy.com",
                    ),
                  ),
                  SizedBox(height: 20), // 이메일 필드와 다음 버튼 간 간격 추가
                  ElevatedButton(
                    onPressed: () {
                      // 비밀번호 변경 기능
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text("비밀번호 변경"),
                  ),
                ],
              ),
            ),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 20, bottom: 20),
              child: Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    // 로그아웃 기능 추가
                  },
                  child: Text(
                    "LOG OUT",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
