import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE Auto Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const BLEPage(),
    );
  }
}

class BLEPage extends StatefulWidget {
  const BLEPage({Key? key}) : super(key: key);

  @override
  State<BLEPage> createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  BluetoothDevice? connectedDevice;
  bool isConnected = false; // 현재 연결 상태 플래그

  @override
  void initState() {
    super.initState();
    requestPermissions(); // 권한 요청
    startAutoScan(); // BLE 스캔 시작
  }

  // BLE 및 알림 권한 요청
  void requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
      Permission.notification,
    ].request();
  }

  // BLE 스캔 시작
  void startAutoScan() {
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        debugPrint('발견된 장치: ${result.device.name} (${result.device.id})');
        if (result.device.name == 'ESP32_Bus_Beacon') {
          if (!isConnected) {
            FlutterBluePlus.stopScan();
            connectToDevice(result.device);
            return;
          }
        }
      }
    });
  }

  // BLE 장치 연결
  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      setState(() {
        connectedDevice = device;
        isConnected = true;
      });

      debugPrint('장치와 연결됨: ${device.name}');
      showNotification('버스 탑승 알림', '이제 버스에 탑승했습니다!');
    } catch (e) {
      debugPrint('연결 실패: $e');
    }
  }

  // 알림 표시
  void showNotification(String title, String message) {
    debugPrint('showNotification 호출됨: $title - $message');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BLE Auto Connect")),
      body: Center(
        child: connectedDevice == null
            ? const Text('BLE 장치를 탐색 중입니다...')
            : Text(
          '연결된 장치: ${connectedDevice!.name}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
