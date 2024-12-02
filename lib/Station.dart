import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StationSearchScreen(),
    );
  }
}

class StationSearchScreen extends StatefulWidget {
  @override
  _StationSearchScreenState createState() => _StationSearchScreenState();
}

class _StationSearchScreenState extends State<StationSearchScreen> {
  final String apiKey = 'FjpqKmjQJYwJJphhBGmxCP4mPkoN/i6OPGk5nxlg6LQ'; // Replace with your API key
  final TextEditingController stationNameController = TextEditingController();
  List<dynamic> stations = [];
  String? errorMessage;

  Future<void> fetchStations(String stationName) async {
    final url =
        'https://api.odsay.com/v1/api/searchStation?stationName=$stationName&apiKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['result'] != null && data['result']['station'] != null) {
          setState(() {
            stations = data['result']['station'];
            errorMessage = null;
          });
        } else {
          setState(() {
            stations = [];
            errorMessage = "검색 결과가 없습니다.";
          });
        }
      } else {
        setState(() {
          errorMessage = "API 호출 실패: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "오류 발생: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('정류장 검색'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: stationNameController,
              decoration: InputDecoration(
                labelText: '정류장 이름 입력',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.directions_bus),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                final stationName = stationNameController.text.trim();
                if (stationName.isNotEmpty) {
                  fetchStations(stationName);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('정류장 이름을 입력해주세요.')),
                  );
                }
              },
              child: Text('검색', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(height: 16),
            if (errorMessage != null)
              Text(
                errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            Expanded(
              child: stations.isEmpty
                  ? Center(
                child: Text(
                  '검색 결과가 없습니다.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  final station = stations[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: Icon(Icons.directions_bus, color: Colors.blue),
                      title: Text('정류장 이름: ${station['stationName']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('정류장 ID: ${station['stationID']}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BusArrivalScreen(
                              stationId: station['stationID'].toString(), // Convert to String
                              stationName: station['stationName'],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BusArrivalScreen extends StatefulWidget {
  final String stationId;
  final String stationName;

  BusArrivalScreen({required this.stationId, required this.stationName});

  @override
  _BusArrivalScreenState createState() => _BusArrivalScreenState();
}

class _BusArrivalScreenState extends State<BusArrivalScreen> {
  final String apiKey = 'FjpqKmjQJYwJJphhBGmxCP4mPkoN/i6OPGk5nxlg6LQ';
  List<dynamic> busData = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? countdownTimer;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    fetchBusArrivalInfo();
    startTimers();
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    refreshTimer?.cancel();
    super.dispose();
  }

  void startTimers() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        for (var bus in busData) {
          if (bus['arrival1'] != null) {
            var arrival1 = Map<String, dynamic>.from(bus['arrival1']);
            if (arrival1['arrivalSec'] != null && arrival1['arrivalSec'] > 0) {
              arrival1['arrivalSec']--;
            }
            bus['arrival1'] = arrival1;
          }
          if (bus['arrival2'] != null) {
            var arrival2 = Map<String, dynamic>.from(bus['arrival2']);
            if (arrival2['arrivalSec'] != null && arrival2['arrivalSec'] > 0) {
              arrival2['arrivalSec']--;
            }
            bus['arrival2'] = arrival2;
          }
        }
      });
    });

    refreshTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchBusArrivalInfo();
    });
  }

  Future<void> fetchBusArrivalInfo() async {
    setState(() {
      isLoading = true;
    });
    final url =
        'https://api.odsay.com/v1/api/realtimeStation?lang=0&stationID=${widget.stationId}&stationBase=0&apiKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] != null && data['result']['real'] != null) {
          setState(() {
            busData = data['result']['real'];
            errorMessage = null;
            isLoading = false;
          });
        } else {
          setState(() {
            busData = [];
            errorMessage = "도착 예정 버스가 없습니다.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "API 호출 실패: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "오류 발생: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.stationName} 버스 도착 정보'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : ListView.builder(
        itemCount: busData.length,
        itemBuilder: (context, index) {
          final bus = busData[index];
          final arrival1 = bus['arrival1'] ?? {};
          final arrival2 = bus['arrival2'] ?? {};
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '버스 번호: ${bus['routeNm']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (arrival1.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '첫 번째 도착: ${_convertTime(arrival1['arrivalSec'] ?? 0)}\n남은 정류장: ${arrival1['leftStation'] ?? '정보 없음'}\n혼잡도: ${_getCongestion(arrival1['congestion'] ?? 0)}\n저상버스 여부: ${arrival1['lowBusYn'] == 'Y' ? '예' : '아니오'}',
                      ),
                    ),
                  if (arrival2.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '두 번째 도착: ${_convertTime(arrival2['arrivalSec'] ?? 0)}\n남은 정류장: ${arrival2['leftStation'] ?? '정보 없음'}\n혼잡도: ${_getCongestion(arrival2['congestion'] ?? 0)}\n저상버스 여부: ${arrival2['lowBusYn'] == 'Y' ? '예' : '아니오'}',
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _convertTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes분 $remainingSeconds초';
  }

  String _getCongestion(int congestion) {
    switch (congestion) {
      case 1:
        return '여유';
      case 2:
        return '보통';
      case 3:
        return '혼잡';
      default:
        return '정보 없음';
    }
  }
}
