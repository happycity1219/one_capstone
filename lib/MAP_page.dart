import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'Search_page.dart';

class MAP_page extends StatefulWidget {
  @override
  State<MAP_page> createState() => _RouteFindingScreenState();
}

class _RouteFindingScreenState extends State<MAP_page> {
  GoogleMapController? mapController;
  LocationData? currentLocation;
  final String googleApiKey = 'AIzaSyCDtwnXGep0Dz_WLt8gn9WDOLKlQQGp5y8';

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();

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

    currentLocation = await location.getLocation();
    if (currentLocation != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        title: Text(
          '지도',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(37.5665, 126.9780), // 서울 중심
              zoom: 15,
            ),
            myLocationEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              if (currentLocation != null) {
                controller.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                  ),
                );
              }
            },
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.menu, color: Colors.black),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // 검색 페이지 이동 구현
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SearchPage()),
                        );
                      },
                      child: TextField(
                        enabled: false, // 직접 입력 불가, 클릭 시 검색 페이지 이동
                        decoration: InputDecoration(
                          hintText: '장소, 버스, 지하철, 주소 검색',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.black),
                ],
              ),
            ),
          ),
          Positioned(
            top: 80,
            left: 16,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.star_border),
              label: Text('즐겨찾기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shadowColor: Colors.grey.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                elevation: 3,
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: getCurrentLocation,
              child: Icon(Icons.my_location),
            ),
          ),
        ],
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
