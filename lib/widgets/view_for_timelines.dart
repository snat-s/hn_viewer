import 'dart:convert';

import 'package:flutter/material.dart';

import '../classes/news.dart';
import '../classes/top_stories.dart';
import '../functions/all_functions.dart';
import 'element_on_list.dart';

class ViewForTimeLines extends StatefulWidget {
  const ViewForTimeLines({
    super.key,
    required this.news,
    required this.section,
  });

  final Future<TopStories> news;
  final String section;

  @override
  State<ViewForTimeLines> createState() => _ViewForTimeLinesState();
}

class _ViewForTimeLinesState extends State<ViewForTimeLines> {
  //late Future<TopStories> news = widget.news;
  List<News> allNews = [];
  List<dynamic> parsed = [];

  @override
  void initState() {
    super.initState();
    fetchEverything().then((_parsed) {
      setState(() {
        parsed = _parsed;
      });
    });
  }

  Future<List> fetchEverything() async {
    final parsed = await (widget.news).then((value) => value.getTopStories);
    return parsed;
  }

  fetchSpecificArticle(int article) async {
    final parsedArticle =
        await fetchNews(article).then((value) => value.getNews);
    return parsedArticle.getNews;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate(((context, index) {
            // TODO: I'm not sure if I should make all the requests
            // in the beginning and wait a bit more time or fetch everything
            // ahead of time.

            if (index < parsed.length) {
              final newNews = fetchNews(parsed[index]);
              return ElementOnList(specificNews: newNews);
            }
            return null;
          })),
        ),
      ],
    );
  }
}
