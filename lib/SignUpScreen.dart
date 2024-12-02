import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isAllChecked = false;
  bool isTermsChecked = false;
  bool isPrivacyChecked = false;
  bool isPromoChecked = false;

  void updateAllCheckboxes(bool? value) {
    setState(() {
      isAllChecked = value ?? false;
      isTermsChecked = isAllChecked;
      isPrivacyChecked = isAllChecked;
      isPromoChecked = isAllChecked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('회원 가입'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이메일 입력
              TextField(
                decoration: InputDecoration(
                  labelText: '이메일',
                  suffix: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent, // 버튼 색상 설정
                      padding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    child: Text(
                      '이메일 인증',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 인증 번호 입력
              TextField(
                decoration: InputDecoration(
                  labelText: '인증 번호',
                ),
              ),
              SizedBox(height: 16),
              // 비밀번호 입력
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  helperText: '*영문 대소문자, 특수문자, 숫자 포함 8자 이상',
                ),
              ),
              SizedBox(height: 16),
              // 비밀번호 확인
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                ),
              ),
              SizedBox(height: 16),
              // 전체 동의 및 개별 동의 체크박스
              CheckboxListTile(
                value: isAllChecked,
                onChanged: updateAllCheckboxes,
                title: Text('전체 동의'),
              ),
              CheckboxListTile(
                value: isTermsChecked,
                onChanged: (value) {
                  setState(() {
                    isTermsChecked = value ?? false;
                    isAllChecked = isTermsChecked && isPrivacyChecked && isPromoChecked;
                  });
                },
                title: Text('이용약관 (필수)'),
              ),
              CheckboxListTile(
                value: isPrivacyChecked,
                onChanged: (value) {
                  setState(() {
                    isPrivacyChecked = value ?? false;
                    isAllChecked = isTermsChecked && isPrivacyChecked && isPromoChecked;
                  });
                },
                title: Text('개인정보 제공 동의 (필수)'),
              ),
              CheckboxListTile(
                value: isPromoChecked,
                onChanged: (value) {
                  setState(() {
                    isPromoChecked = value ?? false;
                    isAllChecked = isTermsChecked && isPrivacyChecked && isPromoChecked;
                  });
                },
                title: Text('프로모션 알림 동의 (선택)'),
              ),
              SizedBox(height: 16),
              // 가입하기 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: Text(
                    '가입하기',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
