import 'package:flutter/material.dart';
import 'SignUpScreen.dart'; // SignUpScreen 페이지 임포트
import 'id_password_page.dart'; // id_password_page 페이지 임포트
import 'MainScreen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  bool _isRememberIdChecked = false; // 체크박스 상태를 저장하는 변수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              // 로고 이미지
              Image.asset(
                'assets/logo.png',
                width: 200,
                height: 150,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 10),
              // 회원 가입하기 버튼
              TextButton(
                onPressed: () {
                  // 회원가입 페이지 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  );
                },
                child: Text(
                  '회원 가입하기',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: 20),
              // 아이디 또는 이메일 입력
              TextField(
                decoration: InputDecoration(
                  labelText: '아이디 또는 이메일',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // 비밀번호 입력
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // 아이디/비밀번호 찾기, 아이디 저장 체크박스
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => id_password_page()),
                      );
                    },
                    child: Text('아이디/비밀번호 찾기'),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isRememberIdChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isRememberIdChecked = value ?? false;
                          });
                        },
                      ),
                      Text('아이디 저장'),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 16),
              // 로그인 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // 로그인 버튼 눌렀을 때 메인 페이지로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => MainScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 로그인 버튼 색상
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '로그인',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 30),
              // 소셜 로그인 (Google, Kakao)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/google_logo.png', // 로컬 이미지 파일 경로
                      width: 40,
                      height: 40,
                    ),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/kakao_logo.png', // 로컬 이미지 파일 경로
                      width: 40,
                      height: 40,
                    ),
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

void main() {
  runApp(MaterialApp(
    home: LoginScreen(),
  ));
}
