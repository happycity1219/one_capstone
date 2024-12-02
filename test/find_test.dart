import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_directions_api/google_directions_api.dart';

class FindTestPage extends StatefulWidget {
  final String startLocation;
  final String endLocation;

  FindTestPage({required this.startLocation, required this.endLocation});

  @override
  _FindTestPageState createState() => _FindTestPageState();
}

class _FindTestPageState extends State<FindTestPage> {
  GoogleMapController? mapController;
  List<LatLng> _polylineCoordinates = [];
  final String googleApiKey = 'AIzaSyAI7IvUjGkoQODBkPdrTspxzzOHfhmiSaw';
  late DirectionsService directionsService;

  @override
  void initState() {
    super.initState();
    DirectionsService.init(googleApiKey); // Directions API 초기화
    directionsService = DirectionsService();
    _fetchDirections();
  }

  Future<void> _fetchDirections() async {
    final request = DirectionsRequest(
      origin: widget.startLocation,
      destination: widget.endLocation,
      travelMode: TravelMode.driving, // 이동 수단: 차량
    );

    directionsService.route(request, (DirectionsResult response, DirectionsStatus? status) {
      if (status == DirectionsStatus.ok) {
        // 경로가 성공적으로 반환된 경우
        final route = response.routes?.first; // Nullable 처리
        if (route != null) {
          final polyline = route.overviewPolyline?.points; // Nullable 처리
          if (polyline != null && polyline.isNotEmpty) {
            setState(() {
              _polylineCoordinates = _decodePolyline(polyline);
            });
            print('경로를 성공적으로 가져왔습니다!');
          } else {
            print('Polyline 데이터가 없습니다.');
          }
        } else {
          print('Route 데이터가 없습니다.');
        }
      } else {
        print('경로를 찾을 수 없습니다: $status');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로를 찾을 수 없습니다. 다시 시도해주세요.')),
        );
      }
    });
  }

  // Polyline 디코딩 (Google Polyline Algorithm)
  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int shift = 0, result = 0;
      int b;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('길찾기 테스트'),
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.5665, 126.9780), // 서울 중심 좌표
              zoom: 14,
            ),
            markers: {
              Marker(
                markerId: MarkerId("start"),
                position: LatLng(37.5665, 126.9780), // 테스트용 출발지 좌표
                infoWindow: InfoWindow(title: "출발지"),
              ),
              Marker(
                markerId: MarkerId("end"),
                position: LatLng(37.5773, 126.9768), // 테스트용 도착지 좌표
                infoWindow: InfoWindow(title: "도착지"),
              ),
            },
            polylines: {
              if (_polylineCoordinates.isNotEmpty)
                Polyline(
                  polylineId: PolylineId("route"),
                  points: _polylineCoordinates,
                  color: Colors.blue,
                  width: 5,
                ),
            },
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),
          // 로딩 표시
          if (_polylineCoordinates.isEmpty)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
