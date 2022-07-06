import 'package:http/http.dart' as http;
import 'dart:convert';

class TopStories {
  final List<dynamic> topStories;
  TopStories({required this.topStories});
  factory TopStories.fromJson(List<dynamic> json) {
    return TopStories(topStories: json);
  }
}

Future<TopStories> fetchTopStories(String queryParameter) async {
  final response = await http.get(Uri.parse(
      'https://hacker-news.firebaseio.com/v0/$queryParameter.json?print=pretty'));
  if (response.statusCode == 200) {
    //print(TopStories(topStories: jsonDecode(response.body)).toString());
    return TopStories(topStories: jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some questions');
  }
}
