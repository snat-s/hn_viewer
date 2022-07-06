import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:birthday_reminder/classes/top_stories.dart';
import 'package:birthday_reminder/widgets/element_on_list.dart';
import 'package:birthday_reminder/widgets/title_page.dart';
import 'package:flutter/material.dart';
import 'package:birthday_reminder/classes/news.dart';

Future<News> fetchNews(int specificRequest) async {
  final response = await http.get(Uri.parse(
      'https://hacker-news.firebaseio.com/v0/item/$specificRequest.json?print=pretty'));

  if (response.statusCode == 200) {
    return News.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some News :( ');
  }
}

class ViewForTimeLines extends StatefulWidget {
  const ViewForTimeLines(
      {super.key,
      required this.news,
      required this.section,
      required this.isSection,
      required this.separator});

  final Future<TopStories> news;
  final String section;
  final bool isSection;
  final String separator;
  @override
  State<ViewForTimeLines> createState() => _ViewForTimeLinesState();
}

class _ViewForTimeLinesState extends State<ViewForTimeLines> {
  late Future<TopStories> news = widget.news;
  final List<String> faces = <String>[
    ':)',
    ';)',
    ':O',
    "ʕ•ᴥ•ʔ",
    "(ᵔᴥᵔ)",
    "◉_◉",
    "⚆ _ ⚆",
    "˙ ͜ʟ˙",
  ];

  @override
  void initState() {
    super.initState();
    news = fetchTopStories(widget.section);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        TitlePage(
          title: widget.isSection
              ? widget.separator
              : (faces.toList()..shuffle())
                  .first, // TODO: The random faces is because I don't know how to fix this dead space
          // maybe not a bug but a *feature*?
          height2: 150,
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(((context, index) {
            return FutureBuilder(
              future: news,
              builder: ((context, snapshot3) {
                if (snapshot3.hasData) {
                  if (index < snapshot3.data!.topStories.length) {
                    final specificNews =
                        fetchNews(snapshot3.data!.topStories[index]);
                    return ElementOnList(specificNews: specificNews);
                  }
                } else if (snapshot3.hasError) {
                  return const Text("ERRORRRRR no questions");
                }
                return const Text('Loading...');
              }),
            );
          })),
        ),
      ],
    );
  }
}
