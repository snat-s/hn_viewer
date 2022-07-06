import 'package:birthday_reminder/widgets/view_for_timelines.dart';

import 'widgets/element_on_list.dart';
import 'package:flutter/material.dart';
import 'classes/top_stories.dart';
import 'widgets/title_page.dart';

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
  late Future<TopStories> news, questions, show;
  final PageController _controller = PageController(initialPage: 0);
  final List<String> tabs = <String>['Top Stories', 'Ask', 'Show'];

  @override
  void initState() {
    super.initState();
    news = fetchTopStories('topstories');
    questions = fetchTopStories('askstories');
    show = fetchTopStories('showstories');
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: _controller,
      children: [
        Scaffold(
          body: RefreshIndicator(
            color: Colors.orange,
            onRefresh: _refresh,
            child: FutureBuilder(
              future: news,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final goodNews =
                      snapshot.data!.topStories.take(numberOfItems);
                  return NotificationListener<ScrollEndNotification>(
                    onNotification: (ScrollEndNotification notification) {
                      bool isTop = notification.metrics.pixels == 0;
                      if (notification.metrics.atEdge) {
                        if (!isTop) {
                          _controller.animateToPage(1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut);
                        }
                      }
                      return true;
                    },
                    child: CustomScrollView(
                      slivers: <Widget>[
                        TitlePage(
                          title: 'Top Stories',
                          height2: 195,
                        ),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            ((context, index) {
                              if (index < 20) {
                                // Oh my god what have i done, i think this is
                                // Unsafe code please add a TODO: ask.
                                final specificNews =
                                    fetchNews(goodNews.elementAt(index));
                                return ElementOnList(
                                    specificNews: specificNews);
                              }
                              return null;
                            }),
                          ),
                        ),
                        TitlePage(
                          title: 'Ask HN',
                          height2: 195,
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(((context, index) {
                            if (index < 20) {
                              return FutureBuilder(
                                future: questions,
                                builder: ((context, snapshot3) {
                                  if (snapshot3.hasData) {
                                    final specificNews = fetchNews(
                                        snapshot3.data!.topStories[index]);
                                    return ElementOnList(
                                        specificNews: specificNews);
                                  } else if (snapshot3.hasError) {
                                    return const Text(
                                        "ERRORRRRR no questions :(");
                                  }
                                  return const Text('Loading...');
                                }),
                              );
                            }
                          })),
                        ),
                        TitlePage(
                          title: 'Show HN',
                          height2: 195,
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(((context, index) {
                            if (index < 20) {
                              return FutureBuilder(
                                future: show,
                                builder: ((context, snapshot3) {
                                  if (snapshot3.hasData) {
                                    final specificNews = fetchNews(
                                        snapshot3.data!.topStories[index]);
                                    return ElementOnList(
                                        specificNews: specificNews);
                                  } else if (snapshot3.hasError) {
                                    return const Text("ERRORRRRR no questions");
                                  }
                                  return const Text('Loading...');
                                }),
                              );
                            }
                          })),
                        ),
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Text('Eror');
                }
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('HN Viewer'),
                    backgroundColor: Colors.orange,
                  ),
                  body: const Center(
                    child: Text("Loading..."),
                  ),
                );
              },
            ),
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
                        pinned: true,
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
                    RefreshIndicator(
                      onRefresh: _refresh,
                      child: ViewForTimeLines(
                        news: news,
                        section: 'topstories',
                        isSection: false,
                        separator: '',
                      ),
                    ),
                    ViewForTimeLines(
                      news: questions,
                      section: 'askstories',
                      isSection: false,
                      separator: '',
                    ),
                    ViewForTimeLines(
                      news: show,
                      section: 'showstories',
                      isSection: false,
                      separator: '',
                    ),
                  ],
                )),
          ),
        ),
      ],
    );
  }

  Future<TopStories> _refresh() async {
    return news = fetchTopStories('topstories');
  }
}
