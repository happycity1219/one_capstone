import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

void main() {
  runApp(ApiTestApp());
}

class ApiTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ApiTestPage(),
    );
  }
}

class ApiTestPage extends StatefulWidget {
  @override
  _ApiTestPageState createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  String _response = "API 호출 결과가 여기에 표시됩니다.";
  String _busResponse = "버스 정류장 정보가 여기에 표시됩니다.";
  Location location = Location();
  LatLng? _currentLatLng;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // 현재 위치 가져오기
  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      LocationData locationData = await location.getLocation();
      setState(() {
        _currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);
      });
    } catch (e) {
      print("현재 위치를 가져오는 중 오류 발생: $e");
    }
  }

  // Bus Stops API 호출하기
  Future<void> _fetchBusStops() async {
    if (_currentLatLng == null) {
      print("현재 위치를 확인할 수 없습니다.");
      setState(() {
        _busResponse = "현재 위치를 확인할 수 없습니다. 위치 서비스가 활성화되지 않았거나 권한이 부족합니다.";
      });
      return;
    }

    final apiKey = 'AIzaSyCDtwnXGep0Dz_WLt8gn9WDOLKlQQGp5y8'; // 실제 API 키를 입력하세요.
    final location = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    final radius = '1500'; // 반경 1500미터로 변경
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$location&radius=$radius&type=bus_station&language=ko&key=$apiKey';

    try {
      print("버스 정류장 API 호출 시작");
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("버스 정류장 API 호출 성공, 데이터 수신 완료");
        print("API 응답 데이터: $data"); // 전체 응답 데이터를 출력하여 확인

        if (data['results'] != null && data['results'].isNotEmpty) {
          String busStops = "";
          for (var result in data['results']) {
            String name = result['name'] ?? '알 수 없는 정류장';
            String vicinity = result['vicinity'] ?? '주소 없음';
            busStops += "$name - $vicinity\n";
          }
          setState(() {
            _busResponse = busStops;
          });
        } else {
          setState(() {
            _busResponse = "주변에 버스 정류장을 찾을 수 없습니다.";
          });
          print("주변에 버스 정류장을 찾을 수 없습니다.");
        }
      } else {
        print("버스 정류장 API 호출 실패, 상태 코드: ${response.statusCode}");
        setState(() {
          _busResponse = "오류 발생: ${response.statusCode} - ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      print("예외 발생: $e");
      setState(() {
        _busResponse = "예외 발생: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Test Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _fetchBusStops,
              child: Text('Bus Stops API 호출하기'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  _busResponse,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LatLng {
  final double latitude;
  final double longitude;

  LatLng(this.latitude, this.longitude);
}
