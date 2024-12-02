import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Find.dart'; // 길 안내 페이지

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final String googleApiKey = 'AIzaSyCDtwnXGep0Dz_WLt8gn9WDOLKlQQGp5y8'; // 실제 API 키로 교체하세요
  late TabController _tabController;

  bool showStartSuggestions = false;
  bool showDestinationSuggestions = false;

  List<String> startSuggestions = [];
  List<String> destinationSuggestions = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchSuggestions(String query) async {
    if (query.isEmpty) return [];

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$googleApiKey&language=ko';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final predictions = data['predictions'] as List;

      return predictions.map((item) => item['description'] as String).toList();
    } else {
      throw Exception('Failed to fetch suggestions');
    }
  }

  void fetchStartSuggestions(String query) async {
    final suggestions = await fetchSuggestions(query);
    setState(() {
      startSuggestions = suggestions;
      showStartSuggestions = suggestions.isNotEmpty;
    });
  }

  void fetchDestinationSuggestions(String query) async {
    final suggestions = await fetchSuggestions(query);
    setState(() {
      destinationSuggestions = suggestions;
      showDestinationSuggestions = suggestions.isNotEmpty;
    });
  }

  void clearSuggestions() {
    setState(() {
      showStartSuggestions = false;
      showDestinationSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          '검색',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.black),
            onPressed: () {
              if (startController.text.isNotEmpty &&
                  destinationController.text.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FindPage(
                      startLocation: startController.text,
                      endLocation: destinationController.text,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('출발지와 도착지를 입력하세요.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: clearSuggestions,
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: startController,
                                decoration: InputDecoration(
                                  hintText: '출발지 입력',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: fetchStartSuggestions,
                                onTap: () {
                                  setState(() {
                                    showDestinationSuggestions = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.swap_vert, color: Colors.black),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                controller: destinationController,
                                decoration: InputDecoration(
                                  hintText: '도착지 입력',
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                ),
                                onChanged: fetchDestinationSuggestions,
                                onTap: () {
                                  setState(() {
                                    showStartSuggestions = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.menu, color: Colors.black),
                        ],
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.blue,
                  tabs: [
                    Tab(text: '최근검색'),
                    Tab(text: '장소'),
                    Tab(text: '버스'),
                    Tab(text: '경로'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      Center(child: Text('최근 검색 기록이 없습니다.')),
                      Center(child: Text('장소 검색')),
                      Center(child: Text('버스 검색')),
                      Center(child: Text('경로 검색')),
                    ],
                  ),
                ),
              ],
            ),
            if (showStartSuggestions && startSuggestions.isNotEmpty)
              Positioned(
                top: 110,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: startSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(startSuggestions[index]),
                        onTap: () {
                          setState(() {
                            startController.text = startSuggestions[index];
                            showStartSuggestions = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
            if (showDestinationSuggestions && destinationSuggestions.isNotEmpty)
              Positioned(
                top: 200,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 4,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: destinationSuggestions.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(destinationSuggestions[index]),
                        onTap: () {
                          setState(() {
                            destinationController.text = destinationSuggestions[index];
                            showDestinationSuggestions = false;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
