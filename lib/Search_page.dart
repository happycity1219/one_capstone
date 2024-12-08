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
  final String googleApiKey = 'AIzaSyCDtwnXGep0Dz_WLt8gn9WDOLKlQQGp5y8';
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

  Widget buildSuggestionList(List<String> suggestions, bool isStart) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 4),
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  if (isStart) {
                    startController.text = suggestions[index];
                    showStartSuggestions = false;
                  } else {
                    destinationController.text = suggestions[index];
                    showDestinationSuggestions = false;
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: ListTile(
                  leading: Icon(Icons.search, color: Colors.grey[700], size: 20),
                  title: Text(
                    suggestions[index],
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.grey[800],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('검색', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white),
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
                      // 출발지 입력 필드
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: startController,
                                decoration: InputDecoration(
                                  hintText: '출발지 입력',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
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
                          Icon(Icons.swap_vert, color: Colors.black87),
                        ],
                      ),
                      SizedBox(height: 15),
                      // 도착지 입력 필드
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    spreadRadius: 1,
                                    blurRadius: 5,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: destinationController,
                                decoration: InputDecoration(
                                  hintText: '도착지 입력',
                                  hintStyle: TextStyle(color: Colors.grey[500]),
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
                          Icon(Icons.menu, color: Colors.black87),
                        ],
                      ),
                    ],
                  ),
                ),
                // 탭바
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
            // 출발지 추천
            if (showStartSuggestions && startSuggestions.isNotEmpty)
              Positioned(
                top: 110,
                left: 16,
                right: 16,
                child: buildSuggestionList(startSuggestions, true),
              ),
            // 도착지 추천
            if (showDestinationSuggestions && destinationSuggestions.isNotEmpty)
              Positioned(
                top: 200,
                left: 16,
                right: 16,
                child: buildSuggestionList(destinationSuggestions, false),
              ),
          ],
        ),
      ),
    );
  }
}
