import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'show_user.dart';
import '../classes/comment.dart';
import '../classes/news.dart';
import '../functions/all_functions.dart';

class SpecificNews extends StatefulWidget {
  const SpecificNews({super.key, required this.news});

  final Future<News> news;

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
    return RefreshIndicator(
      onRefresh: _refresh,
      color: Colors.amber,
      child: Scaffold(
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
                            textColor: Colors.white,
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
                          if (snapshot.data!.url == '') {
                            return;
                          }
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
                            onLinkTap: _launchURL,
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: const EdgeInsets.only(right: 20.0),
                      sliver: SliverToBoxAdapter(
                        child: GestureDetector(
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
                                      onLinkTap: _launchURL,
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
      ),
    );
  }

  void _launchURL(url, context, attributes, element) async {
    if (kDebugMode) {
      print(url.runtimeType);
    }
    if (!await launchUrl(Uri.parse(url!))) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _refresh() async {
    // TODO: Actually make it make something
    return Future.delayed(const Duration(seconds: 1));
  }
}
