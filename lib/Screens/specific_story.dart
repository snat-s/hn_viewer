import 'dart:convert';

import 'package:birthday_reminder/Screens/show_user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../classes/comment.dart';
import '../classes/news.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

Future<Comment> fetchComments(int specificRequest) async {
  final response = await http.get(Uri.parse(
      'https://hacker-news.firebaseio.com/v0/item/$specificRequest.json?print=pretty'));
  if (response.statusCode == 200) {
    return Comment.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to fetch some News :( ');
  }
}

class SpecificNews extends StatefulWidget {
  final Future<News> news;

  const SpecificNews({super.key, required this.news});

  @override
  State<SpecificNews> createState() => _SpecificNewsState();
}

class _SpecificNewsState extends State<SpecificNews> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.news,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<int> commentIDs = List<int>.from(snapshot.data!.kids);

            return NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                if (notification.metrics.atEdge) {
                  bool isTop = notification.metrics.pixels == 0.0;
                  if (!isTop) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(''),
                        action: SnackBarAction(
                          label: 'Go Back',
                          onPressed: () {
                            if (!mounted) return;
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }
                }
                return true;
              },
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Text(snapshot.data!.title),
                    backgroundColor: Colors.orange,
                    floating: true,
                  ),
                  SliverToBoxAdapter(
                    child: GestureDetector(
                      onTap: () async {
                        if (!await launchUrl(Uri.parse(snapshot.data!.url))) {
                          throw 'Could not launch ${snapshot.data!.title}';
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          snapshot.data!.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (snapshot.data!.type == 'story')
                    SliverPadding(
                      padding: const EdgeInsets.all(15.0),
                      sliver: SliverToBoxAdapter(
                        child: Html(
                          data: snapshot.data!.text,
                          style: {"body": Style(fontWeight: FontWeight.bold)},
                        ),
                      ),
                    ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(((context, index) {
                      if (index < commentIDs.length) {
                        Future<Comment> comment =
                            fetchComments(commentIDs[index]);
                        return FutureBuilder<Comment>(
                          future: comment,
                          builder: ((context, snapshot) {
                            if (snapshot.hasData) {
                              //print(snapshot.data!.kids);
                              return Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListTile(
                                  title: Html(
                                    data: snapshot.data!.comment,
                                    onLinkTap: (url, context, attributes,
                                        element) async {
                                      if (kDebugMode) {
                                        print(url.runtimeType);
                                      }
                                      if (!await launchUrl(Uri.parse(url!))) {
                                        throw 'Could not launch $url';
                                      }
                                    },
                                  ),
                                  subtitle: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ShowUser(
                                              user: snapshot.data!.by,
                                            ),
                                          ));
                                    },
                                    child: Text(
                                      snapshot.data!.by,
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text('${snapshot.error}');
                            }
                            return const Text('Loading...');
                          }),
                        );
                      }
                      return null;
                    })),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Text('Loading...');
        },
      ),
    );
  }
}
