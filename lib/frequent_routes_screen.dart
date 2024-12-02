import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // 지도 표시 패키지
import 'dart:async';

void main() {
  runApp(FrequentRoutesScreen());
}

class FrequentRoutesScreen extends StatefulWidget {
  @override
  _FrequentRoutesScreenState createState() => _FrequentRoutesScreenState();
}

class _FrequentRoutesScreenState extends State<FrequentRoutesScreen> {
  Completer<GoogleMapController> _controller = Completer();
  List<LatLng> routeCoordinates = []; // 경로 좌표 리스트

  @override
  void initState() {
    super.initState();
    fetchFrequentRoutes();
  }

  // Tmap API에서 자주 이용한 경로 가져오기
  void fetchFrequentRoutes() async {
    // 여기에 Tmap API 키와 호출 URL 설정
    String apiKey = "VJaCPoAcJH7V67XLbdBZu33MJ5g5wu1N9eV8tPUZ"; // 발급받은 Tmap API 키
    String url =
        "https://apis.openapi.sk.com/tmap/routes/prediction?version=1&format=json&appKey=$apiKey";

    // HTTP 요청을 통해 경로 데이터 가져오기 (예시: HTTP GET 요청)
    // 실제 경로 데이터 예시는 다음과 같이 설정합니다.
    // {"route":[{"lat":37.5665,"lng":126.9780},{"lat":37.5651,"lng":126.9895}]}

    List<LatLng> dummyData = [
      LatLng(37.5665, 126.9780), // 서울시청
      LatLng(37.5651, 126.9895), // 종로구
    ];

    // 요청 성공 시 데이터 업데이트
    setState(() {
      routeCoordinates = dummyData; // 실제 API 결과로 교체
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('자주 이용한 경로'),
        centerTitle: true,
      ),
      body: routeCoordinates.isEmpty
          ? Center(child: CircularProgressIndicator()) // 데이터 로딩 중 표시
          : GoogleMap(
        initialCameraPosition: CameraPosition(
          target: routeCoordinates.first, // 첫 번째 경로 지점을 카메라 초기 위치로 설정
          zoom: 14,
        ),
        markers: routeCoordinates.map((coord) {
          return Marker(
            markerId: MarkerId(coord.toString()),
            position: coord,
          );
        }).toSet(),
        polylines: {
          Polyline(
            polylineId: PolylineId("frequent_routes"),
            points: routeCoordinates,
            color: Colors.blue,
            width: 5,
          )
        },
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
    );
  }
}