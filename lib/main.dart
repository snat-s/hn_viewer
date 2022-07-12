import 'package:flutter/material.dart';

import 'classes/top_stories.dart';
import 'functions/all_functions.dart';
import 'widgets/title_page.dart';
import 'widgets/view_for_timelines.dart';
import 'widgets/element_on_list.dart';

const numberOfItems = 100;

void main(List<String> args) {
  runApp(const HNApp());
}

class HNApp extends StatelessWidget {
  const HNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'HN Reader',
      home: HNMainScreen(),
    );
  }
}

class HNMainScreen extends StatefulWidget {
  const HNMainScreen({super.key});

  @override
  State<HNMainScreen> createState() => _HNMainScreenState();
}

class _HNMainScreenState extends State<HNMainScreen> {
  late Future<TopStories> newsFuture, questionsFuture, showFuture;
  late List<List> news = <List<dynamic>>[];
  final PageController _controller = PageController(initialPage: 0);
  final List<String> tabs = <String>['Top Stories', 'Ask', 'Show'];
  final List<String> typeOfStories = [
    'topstories',
    'askstories',
    'showstories',
  ];
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < typeOfStories.length; i++) {
      fetchTopStories(typeOfStories[i]).then((value) {
        setState(() {
          news.add(value.getTopStories);
        });
        //print(news[i]);
      });
    }
    newsFuture = fetchTopStories('topstories');
    questionsFuture = fetchTopStories('askstories');
    showFuture = fetchTopStories('showstories');
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              const TitlePage(title: 'Top Stories', height: 174),
              SliverList(
                delegate: SliverChildBuilderDelegate(((context, index) {
                  if (index < 10 && news.length == 3) {
                    final specificNews = fetchNews(news[0][index]);
                    return ElementOnList(specificNews: specificNews);
                  }
                  return null;
                })),
              ),
              const TitlePage(title: 'Ask HN', height: 174),
              SliverList(
                delegate: SliverChildBuilderDelegate(((context, index) {
                  if (index < 10 && news.length == 3) {
                    final specificNews = fetchNews(news[1][index]);
                    return ElementOnList(specificNews: specificNews);
                  }
                  return null;
                })),
              ),
              const TitlePage(title: 'Show HN', height: 174),
              SliverList(
                delegate: SliverChildBuilderDelegate(((context, index) {
                  if (index < 10 && news.length == 3) {
                    final specificNews = fetchNews(news[2][index]);
                    return ElementOnList(specificNews: specificNews);
                  }
                  return null;
                })),
              ),
            ],
          ),
        ),
        DefaultTabController(
          length: 3,
          child: Scaffold(
            body: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverAppBar(
                        backgroundColor: Colors.orange,
                        title: const Text('HN Viewer'),
                        floating: true,
                        expandedHeight: 150.0,
                        forceElevated: innerBoxIsScrolled,
                        bottom: TabBar(
                          indicatorColor: Colors.yellow,
                          // These are the widgets to put in each tab in the tab bar.
                          tabs: tabs
                              .map((String name) => Tab(text: name))
                              .toList(),
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    ViewForTimeLines(
                      news: newsFuture,
                      section: 'topstories',
                    ),
                    ViewForTimeLines(
                      news: questionsFuture,
                      section: 'askstories',
                    ),
                    ViewForTimeLines(
                      news: showFuture,
                      section: 'showstories',
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Future<TopStories> _refresh() async {
    final newestStories = fetchTopStories('topstories');
    await newestStories;
    return newestStories;
  }
}
