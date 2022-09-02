import 'dart:convert';
import 'package:http/http.dart' as http;

import '../classes/user.dart';
import '../classes/news.dart';
import '../classes/top_stories.dart';
import '../classes/comment.dart';

Future<User> fetchUser(String user) async {
  final response = await http.get(
    Uri.parse(
        'https://hacker-news.firebaseio.com/v0/user/$user.json?print=pretty'),
  );
  if (response.statusCode == 200) {
    return User.fromJson((jsonDecode(response.body)));
  } else {
    throw Exception('Failed to fetch user :(');
  }
}

Future<News> fetchNews(int specificRequest) async {
  final response = await http.get(
    Uri.parse(
        'https://hacker-news.firebaseio.com/v0/item/$specificRequest.json?print=pretty'),
  );

  if (response.statusCode == 200) {
    return News.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some News :( ');
  }
}

Future<TopStories> fetchTopStories(String queryParameter) async {
  final response = await http.get(
    Uri.parse(
        'https://hacker-news.firebaseio.com/v0/$queryParameter.json?print=pretty'),
  );
  if (response.statusCode == 200) {
    return TopStories(topStories: jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some stories');
  }
}

Future<Comment> fetchComments(int specificRequest) async {
  final response = await http.get(Uri.parse(
      'https://hacker-news.firebaseio.com/v0/item/$specificRequest.json?print=pretty'));
  if (response.statusCode == 200) {
    return Comment.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some News :( ');
  }
}
