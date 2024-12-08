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
      title: 'ESP32 BLE LED Control',
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
  BluetoothCharacteristic? controlCharacteristic;
  String busRouteData = ""; // STOP 명령 시 반환되는 데이터
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    startAutoScan();
  }

  // 권한 요청
  void requestPermissions() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  // BLE 스캔 및 연결
  void startAutoScan() {
    FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name == 'ESP32_Bus_Beacon') {
          FlutterBluePlus.stopScan();
          connectToDevice(result.device);
          return;
        }
      }
    });
  }

  // BLE 장치 연결 및 서비스 탐색
  void connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              "87654321-4321-4321-4321-cba987654321") {
            setState(() {
              connectedDevice = device;
              controlCharacteristic = characteristic;
              isConnected = true;
            });
            debugPrint('BLE 장치 연결 성공');
            return;
          }
        }
      }
      debugPrint('제어 특성을 찾을 수 없습니다.');
    } catch (e) {
      debugPrint('장치 연결 실패: $e');
    }
  }

  // 명령 전송 함수
  void sendCommand(String command) async {
    if (controlCharacteristic != null) {
      try {
        await controlCharacteristic!.write(command.codeUnits);
        debugPrint('명령 전송: $command');

        // STOP 명령일 때 응답 읽기
        if (command == "STOP") {
          final response = await controlCharacteristic!.read();
          setState(() {
            busRouteData = String.fromCharCodes(response);
          });
          debugPrint('응답 수신: $busRouteData');
        }
      } catch (e) {
        debugPrint('명령 전송 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ESP32 BLE LED Control")),
      body: Center(
        child: isConnected
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '연결된 장치: ${connectedDevice!.name}',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => sendCommand("ON"),
              child: const Text("LED 켜기"),
            ),
            ElevatedButton(
              onPressed: () => sendCommand("OFF"),
              child: const Text("LED 끄기"),
            ),
            ElevatedButton(
              onPressed: () => sendCommand("STOP"),
              child: const Text("STOP 요청"),
            ),
            const SizedBox(height: 20),
            busRouteData.isNotEmpty
                ? Text(
              '경로 정보: $busRouteData',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w400),
            )
                : const SizedBox(),
          ],
        )
            : const Text('BLE 장치를 탐색 중입니다...'),
      ),
    );
  }
}
