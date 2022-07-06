import 'dart:convert';
import 'widgets/element_on_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'classes/news.dart';
import 'classes/top_stories.dart';
import 'widgets/title_page.dart';

const numberOfItems = 100;

Future<News> fetchNews(int specificRequest) async {
  final response = await http.get(Uri.parse(
      'https://hacker-news.firebaseio.com/v0/item/$specificRequest.json?print=pretty'));

  if (response.statusCode == 200) {
    return News.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some News :( ');
  }
}

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
    news = fetchTopStories('topstories');
    questions = fetchTopStories('askstories');
    show = fetchTopStories('showstories');
    //print(news2);
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
                    CustomScrollView(
                      slivers: [
                        TitlePage(
                          title: (faces.toList()..shuffle())
                              .first, // TODO: The random faces is because I don't know how to fix this dead space
                          height2: 150,
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(((context, index) {
                            return FutureBuilder(
                              future: news,
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
                          })),
                        ),
                      ],
                    ),
                    CustomScrollView(
                      slivers: [
                        TitlePage(
                          title: (faces.toList()..shuffle()).first,
                          height2: 150,
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return FutureBuilder(
                              future: questions,
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
                          }),
                        ),
                      ],
                    ),
                    CustomScrollView(
                      slivers: [
                        TitlePage(
                          title: (faces.toList()..shuffle()).first,
                          height2: 150,
                        ),
                        SliverList(
                          delegate:
                              SliverChildBuilderDelegate(((context, index) {
                            return FutureBuilder(
                              future: show,
                              builder: ((context, snapshot3) {
                                if (snapshot3.hasData) {
                                  if (index <
                                      snapshot3.data!.topStories.length) {
                                    final specificNews = fetchNews(
                                        snapshot3.data!.topStories[index]);
                                    return ElementOnList(
                                        specificNews: specificNews);
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
