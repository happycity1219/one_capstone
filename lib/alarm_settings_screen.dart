import 'package:flutter/material.dart';

class AlarmSettingsScreen extends StatefulWidget {
  @override
  _AlarmSettingsScreenState createState() => _AlarmSettingsScreenState();
}

class _AlarmSettingsScreenState extends State<AlarmSettingsScreen> {
  bool isGetOffAlertOn = false;
  bool isGetOnAlertOn = false;
  bool isBusArriveAlertOn = false;
  bool isBusGetOffAlertOn = false;
  bool isVoiceGuideOn = false;
  bool isSilentModeOn = false;
  bool isRouteAlertOn = false;
  bool isGetOnAlertOnoo = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // 전체 배경색 설정
      appBar: AppBar(
        title: Text(
          '알림 설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white, // 상단 배경색을 밝게 설정
        elevation: 10,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size : 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home, color: Colors.black, size : 28),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst); // 홈 화면으로 이동
            },
          ),
        ],
        centerTitle: true, // 제목 중앙 정렬
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildSwitchTile('전체 알림', isGetOffAlertOn, (value) {
                    setState(() {
                      isGetOffAlertOn = value;
                    });
                  }),
                  _buildSwitchTile('하차 알림', isGetOnAlertOnoo, (value) {
                    setState(() {
                      isGetOnAlertOnoo = value;
                    });
                  }),
                  _buildSwitchTile('승차 알림', isGetOnAlertOn, (value) {
                    setState(() {
                      isGetOnAlertOn = value;
                    });
                  }),
                  _buildSwitchTile('버스 도착 알림', isBusArriveAlertOn, (value) {
                    setState(() {
                      isBusArriveAlertOn = value;
                    });
                  }),
                  _buildSwitchTile('버스 하차 알림', isBusGetOffAlertOn, (value) {
                    setState(() {
                      isBusGetOffAlertOn = value;
                    });
                  }),
                  _buildSwitchTile('음성 안내', isVoiceGuideOn, (value) {
                    setState(() {
                      isVoiceGuideOn = value;
                    });
                  }),
                  _buildSwitchTile('절전 모드 무음', isSilentModeOn, (value) {
                    setState(() {
                      isSilentModeOn = value;
                    });
                  }),
                  _buildSwitchTile('길 안내 알림', isRouteAlertOn, (value) {
                    setState(() {
                      isRouteAlertOn = value;
                    });
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }
}
