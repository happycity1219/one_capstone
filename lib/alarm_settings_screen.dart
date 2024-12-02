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
      appBar: AppBar(
        title: Text('알림 설정'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/user_profile'); // 홈 버튼 눌렀을 때 사용자 프로필로 이동
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('전체 알림'),
            value: isGetOffAlertOn,
            onChanged: (value) {
              setState(() {
                isGetOffAlertOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('하차 알림'),
            value: isGetOnAlertOnoo,
            onChanged: (value) {
              setState(() {
                isGetOnAlertOnoo = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('승차 알림'),
            value: isGetOnAlertOn,
            onChanged: (value) {
              setState(() {
                isGetOnAlertOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('버스 도착 알림'),
            value: isBusArriveAlertOn,
            onChanged: (value) {
              setState(() {
                isBusArriveAlertOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('버스 하차 알림'),
            value: isBusGetOffAlertOn,
            onChanged: (value) {
              setState(() {
                isBusGetOffAlertOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('음성 안내'),
            value: isVoiceGuideOn,
            onChanged: (value) {
              setState(() {
                isVoiceGuideOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('절전 모드 무음'),
            value: isSilentModeOn,
            onChanged: (value) {
              setState(() {
                isSilentModeOn = value;
              });
            },
          ),
          SwitchListTile(
            title: Text('길 안내 알림'),
            value: isRouteAlertOn,
            onChanged: (value) {
              setState(() {
                isRouteAlertOn = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
