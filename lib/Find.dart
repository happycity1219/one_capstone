import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as loc;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class FindPage extends StatefulWidget {
  final String startLocation;
  final String endLocation;

  FindPage({required this.startLocation, required this.endLocation});

  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  GoogleMapController? mapController;
  List<Polyline> _allPolylines = [];

  LatLng? startLatLng;
  LatLng? endLatLng;
  LatLng? _currentLatLng;

  final String googleApiKey = 'AIzaSyCDtwnXGep0Dz_WLt8gn9WDOLKlQQGp5y8';
  loc.Location location = loc.Location();

  String? _routeDistance;
  String? _routeDuration;
  List<dynamic>? _routeSteps;
  String _travelMode = 'transit';

  BluetoothDevice? connectedDevice;
  BluetoothCharacteristic? controlCharacteristic;
  bool isConnected = false;
  bool _hasShownDropOffNotification = false;
  bool isBusBoardingConfirmed = false;

  String busRouteData = "";
  StreamSubscription<loc.LocationData>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startAutoScan();

    // 출발지 설정이 없으면 현재 위치 기반
    if (widget.startLocation.isEmpty) {
      _fetchCurrentLocation();
    } else {
      _fetchLatLng();
    }

    _listenToLocationChanges();
  }

  @override
  void dispose() {
    // 위치 변경 구독 해제
    _locationSubscription?.cancel();
    _locationSubscription = null;
    super.dispose();
  }

  /// 권한 요청
  void requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();
  }

  /// BLE 스캔 시작
  void startAutoScan() {
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult result in results) {
        if (result.device.name == 'ESP32_Bus_Beacon' && !isConnected) {
          FlutterBluePlus.stopScan();
          await connectToDevice(result.device);
          return;
        }
      }
    });
  }

  /// BLE 장치 연결
  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      if (!mounted) return;
      setState(() {
        connectedDevice = device;
        isConnected = true;
      });

      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              "87654321-4321-4321-4321-cba987654321") {
            controlCharacteristic = characteristic;
            break;
          }
        }
      }

      _showBoardingNotification();
    } catch (e) {
      print('BLE 장치 연결 실패: $e');
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    }
  }

  /// 버스 탑승 알림 팝업
  void _showBoardingNotification() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('버스 탑승 알림'),
          content: Text('이제 버스에 탑승했습니다!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (!mounted) return;
                setState(() {
                  isBusBoardingConfirmed = true;
                });
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 명령 전송 (STOP 포함)
  Future<void> sendCommand(String command) async {
    if (controlCharacteristic != null) {
      try {
        await controlCharacteristic!.write(command.codeUnits);
        print('명령 전송: $command');

        if (command == "STOP") {
          final response = await controlCharacteristic!.read();
          if (!mounted) return;
          setState(() {
            busRouteData = String.fromCharCodes(response);
          });
          print('응답 수신: $busRouteData');
        }
      } catch (e) {
        print('명령 전송 실패: $e');
      }
    } else {
      print('제어 특성이 설정되지 않았습니다.');
    }
  }

  /// 알림 표시
  void showNotification(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 현재 위치 가져오기
  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) return;
      }

      loc.LocationData locationData = await location.getLocation();
      if (!mounted) return;
      setState(() {
        _currentLatLng = LatLng(locationData.latitude!, locationData.longitude!);
        startLatLng = _currentLatLng;
      });
      _fetchLatLng();
    } catch (e) {
      print("Error fetching current location: $e");
    }
  }

  /// 출발지, 도착지 LatLng 가져오기
  Future<void> _fetchLatLng() async {
    try {
      if (startLatLng == null && widget.startLocation.isNotEmpty) {
        final startCoordinates = await _getLatLng(widget.startLocation);
        if (!mounted) return;
        setState(() {
          startLatLng = startCoordinates;
        });
      }

      final endCoordinates = await _getLatLng(widget.endLocation);
      if (!mounted) return;
      setState(() {
        endLatLng = endCoordinates;
      });

      if (startLatLng != null && endLatLng != null) {
        _fetchRoute();
      }
    } catch (e) {
      print("Error fetching coordinates: $e");
    }
  }

  /// 주소 -> LatLng 변환
  Future<LatLng?> _getLatLng(String address) async {
    final String url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final location = data['results'][0]['geometry']['location'];
        return LatLng(location['lat'], location['lng']);
      }
    }
    return null;
  }

  /// 경로 가져오기 (Google Directions API)
  Future<void> _fetchRoute() async {
    if (startLatLng == null || endLatLng == null) return;

    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${startLatLng!.latitude},${startLatLng!.longitude}&destination=${endLatLng!.latitude},${endLatLng!.longitude}&mode=$_travelMode&alternatives=true&key=$googleApiKey&language=ko';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200 && mounted) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final legs = data['routes'][0]['legs'][0];
        final distance = legs['distance']['text'];
        final duration = legs['duration']['text'];
        final steps = legs['steps'];

        List<Polyline> polylines = [];
        for (var step in steps) {
          String polyline = step['polyline']['points'];
          List<LatLng> polylineCoordinates = _decodePolyline(polyline);
          String travelMode = step['travel_mode'];

          polylines.add(Polyline(
            polylineId: PolylineId(step['start_location'].toString()),
            points: polylineCoordinates,
            color: travelMode == 'WALKING' ? Colors.green : Colors.blue,
            width: travelMode == 'WALKING' ? 3 : 5,
          ));
        }

        if (!mounted) return;
        setState(() {
          _allPolylines = polylines;
          _routeDistance = distance;
          _routeDuration = duration;
          _routeSteps = steps;
        });

        _fitMapToPolyline();
        _checkProximityToBusStop();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("경로를 찾을 수 없습니다. 대중교통 경로가 없는 경우일 수 있습니다."),
            ),
          );
        }
      }
    } else {
      print('Failed to fetch directions: ${response.reasonPhrase}');
    }
  }

  /// 하차 알림 확인 및 경로 삭제
  void _checkProximityToBusStop() {
    if (endLatLng != null && _currentLatLng != null && !_hasShownDropOffNotification) {
      double distance = _calculateDistance(_currentLatLng!, endLatLng!);
      if (distance <= 0.3) {
        showNotification('하차 알림', '이제 곧 하차해야 합니다!');
        _hasShownDropOffNotification = true;
        _clearPassedRoute();
      }
    }
  }

  /// 경로 삭제
  void _clearPassedRoute() {
    if (!mounted) return;
    setState(() {
      _allPolylines.clear();
    });
  }

  /// 두 위치 간 거리 계산
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371;
    double dLat = _degreesToRadians(end.latitude - start.latitude);
    double dLng = _degreesToRadians(end.longitude - start.longitude);
    double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(start.latitude)) *
            cos(_degreesToRadians(end.latitude)) *
            (sin(dLng / 2) * sin(dLng / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// 경로 상세 정보 표시 (UI 개선)
  void _showRouteDetails() {
    if (_routeDistance == null || _routeDuration == null || _routeSteps == null) {
      return;
    }
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 요약 정보 Card
                Card(
                  color: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.blueAccent),
                    title: Text(
                      "총 거리: $_routeDistance\n예상 소요 시간: $_routeDuration",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text("경로 상세", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                ..._routeSteps!.map((step) {
                  String travelMode = step['travel_mode'];
                  if (travelMode == 'TRANSIT') {
                    final transitDetails = step['transit_details'];
                    final vehicle = transitDetails['line']['vehicle']['name'] ?? '대중교통';
                    final busName = transitDetails['line']['short_name'] ?? '정보 없음';
                    final busDeparture = transitDetails['departure_stop']['name'] ?? '정보 없음';
                    final busArrival = transitDetails['arrival_stop']['name'] ?? '정보 없음';

                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.directions_bus, color: Colors.blueAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "$vehicle : $busName",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.arrow_forward, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "출발 정류장: $busDeparture",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.flag, color: Colors.red),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "도착 정류장: $busArrival",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (travelMode == 'WALKING') {
                    final distance = step['distance']['text'];
                    final duration = step['duration']['text'];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      color: Colors.green[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.directions_walk, color: Colors.green),
                        title: Text(
                          "도보 이동",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "거리: $distance, 예상 시간: $duration",
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 지도 경계 맞추기
  void _fitMapToPolyline() {
    if (mapController != null && _allPolylines.isNotEmpty) {
      LatLngBounds bounds = _boundsFromLatLngList(
        _allPolylines.expand((polyline) => polyline.points).toList(),
      );
      mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    }
  }

  /// 위치 변경 감지
  void _listenToLocationChanges() {
    _locationSubscription = location.onLocationChanged.listen((loc.LocationData currentLocation) {
      if (!mounted) return;
      setState(() {
        _currentLatLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        startLatLng = _currentLatLng;
      });
      _fetchRoute();
    });
  }

  /// Polyline 디코딩
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

  /// LatLng 리스트 경계
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double x0 = list.first.latitude;
    double x1 = list.first.latitude;
    double y0 = list.first.longitude;
    double y1 = list.first.longitude;
    for (LatLng latLng in list) {
      if (latLng.latitude > x1) x1 = latLng.latitude;
      if (latLng.latitude < x0) x0 = latLng.latitude;
      if (latLng.longitude > y1) y1 = latLng.longitude;
      if (latLng.longitude < y0) y0 = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(x0, y0),
      northeast: LatLng(x1, y1),
    );
  }

  /// STOP 요청 버튼 클릭 이벤트
  void _onStopButtonPressed() {
    sendCommand("STOP");
    showNotification('하차 알림', '하차벨을 눌렀습니다!');
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        title: Text('길 안내', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          startLatLng == null
              ? Center(child: CircularProgressIndicator())
              : GoogleMap(
            initialCameraPosition: CameraPosition(
              target: startLatLng!,
              zoom: 15,
            ),
            polylines: Set<Polyline>.of(_allPolylines),
            markers: {
              if (_currentLatLng != null)
                Marker(
                  markerId: MarkerId("current"),
                  position: _currentLatLng!,
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueBlue,
                  ),
                  infoWindow: InfoWindow(title: "현재 위치"),
                ),
              if (startLatLng != null)
                Marker(
                  markerId: MarkerId("start"),
                  position: startLatLng!,
                  infoWindow: InfoWindow(title: "출발지"),
                ),
              if (endLatLng != null)
                Marker(
                  markerId: MarkerId("end"),
                  position: endLatLng!,
                  infoWindow: InfoWindow(title: "도착지"),
                ),
            },
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              _fitMapToPolyline();
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            trafficEnabled: true,
          ),

          // 내 위치 버튼(좌측 하단)
          Positioned(
            bottom: 12,
            left: 12,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _fitMapToPolyline,
              child: Icon(Icons.my_location, color: Colors.black),
            ),
          ),

          // STOP 요청 버튼 (버스 탑승 알림 확인 후 나타남)
          if (isBusBoardingConfirmed)
            Positioned(
              bottom: 16,
              left: (screenWidth / 2) - 51,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _onStopButtonPressed,
                child: Text("하차 버튼", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
        ],
      ),

      // 경로 상세 정보 버튼(우측 하단)
      floatingActionButton: FloatingActionButton(
        onPressed: _showRouteDetails,
        child: Icon(Icons.info_outline),
        backgroundColor: Colors.white,
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: '주변',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '저장',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_bus),
            label: '대중교통',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.navigation),
            label: '네비게이션',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '내 정보',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
