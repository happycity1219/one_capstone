import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchTestPage extends StatefulWidget {
  @override
  _SearchTestPageState createState() => _SearchTestPageState();
}

class _SearchTestPageState extends State<SearchTestPage> {
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  List<String> suggestions = [];
  bool isStartFieldActive = true;

  final String googleApiKey = 'AIzaSyAI7IvUjGkoQODBkPdrTspxzzOHfhmiSaw';

  // Google Places API를 통해 연관 검색어 가져오기
  Future<List<String>> fetchSuggestions(String query) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&components=country:kr&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          return data['predictions']
              .map<String>((item) => item['description'] ?? '')
              .toList();
        } else {
          print('No predictions found.');
          return [];
        }
      } else {
        print('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
        return [];
      }
    } catch (e) {
      print('Network Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("출발지와 도착지 검색 (테스트)"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 출발지 입력
            TextField(
              controller: startController,
              onChanged: (value) async {
                if (value.isNotEmpty) {
                  final results = await fetchSuggestions(value);
                  setState(() {
                    suggestions = results;
                    isStartFieldActive = true;
                  });
                } else {
                  setState(() {
                    suggestions = [];
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "출발지 검색",
                border: OutlineInputBorder(),
                hintText: "예: 서울역",
              ),
            ),
            SizedBox(height: 10),

            // 도착지 입력
            TextField(
              controller: endController,
              onChanged: (value) async {
                if (value.isNotEmpty) {
                  final results = await fetchSuggestions(value);
                  setState(() {
                    suggestions = results;
                    isStartFieldActive = false;
                  });
                } else {
                  setState(() {
                    suggestions = [];
                  });
                }
              },
              decoration: InputDecoration(
                labelText: "도착지 검색",
                border: OutlineInputBorder(),
                hintText: "예: 강남역",
              ),
            ),
            SizedBox(height: 10),

            // 연관 검색어 리스트
            Expanded(
              child: ListView.builder(
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(suggestions[index]),
                    onTap: () {
                      setState(() {
                        if (isStartFieldActive) {
                          startController.text = suggestions[index];
                        } else {
                          endController.text = suggestions[index];
                        }
                        suggestions = []; // 선택 후 연관 검색어 초기화
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),

            // 길찾기 버튼
            ElevatedButton(
              onPressed: () {
                if (startController.text.isNotEmpty &&
                    endController.text.isNotEmpty) {
                  Navigator.pushNamed(
                    context,
                    '/find',
                    arguments: {
                      'startLocation': startController.text,
                      'endLocation': endController.text,
                    },
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("출발지와 도착지를 모두 입력해주세요.")),
                  );
                }
              },
              child: Text("길찾기"),
            ),
          ],
        ),
      ),
    );
  }
}
