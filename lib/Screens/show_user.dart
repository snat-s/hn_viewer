import 'dart:convert';

import 'package:birthday_reminder/widgets/element_on_list.dart';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:birthday_reminder/classes/user.dart';

import '../widgets/view_for_timelines.dart';

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

class ShowUser extends StatefulWidget {
  const ShowUser({super.key, required this.user});
  final String user;
  @override
  State<ShowUser> createState() => _ShowUserState();
}

class _ShowUserState extends State<ShowUser> {
  late Future<User> specificUser;

  @override
  void initState() {
    super.initState();
    specificUser = fetchUser(widget.user);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: specificUser,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                SliverAppBar(
                  title: Text(snapshot.data!.id),
                  backgroundColor: Colors.orange,
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15),
                  sliver: SliverToBoxAdapter(
                    child: Text('Name: ${snapshot.data!.id}'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15),
                  sliver: SliverToBoxAdapter(
                    child: Text('Karma: ${snapshot.data!.karma}'),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.all(15),
                  sliver: SliverToBoxAdapter(
                    child: Text('About: '),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15.0),
                  sliver: SliverToBoxAdapter(
                    child: Html(
                      data: snapshot.data!.about,
                      onLinkTap: (url, context, attributes, element) async {
                        if (!await launchUrl(Uri.parse(url!))) {
                          throw 'Could not launch $url';
                        }
                      },
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.all(8.0),
                  sliver: SliverToBoxAdapter(
                      child: Text(
                    'Stories published',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index < snapshot.data!.submitted.length) {
                      final specificNews =
                          fetchNews(snapshot.data!.submitted[index]);

                      return FutureBuilder(
                        future: specificNews,
                        builder: (context, snapshot2) {
                          if (snapshot2.hasData) {
                            if (snapshot2.data!.type == 'story') {
                              return ElementOnList(
                                specificNews: specificNews,
                              );
                            }
                          } else if (snapshot2.hasError) {
                            return const Text(
                                "Error, unable to fetch user stories.");
                          }
                          return const Text('');
                        },
                      );
                    }
                    return null;
                  }),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Error!'),
              backgroundColor: Colors.orange,
            ),
            body: const Center(
              child: Text("Could not download the user data :("),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Loading...'),
            backgroundColor: Colors.orange,
          ),
          body: const Center(child: Text("Loading...")),
        );
      },
    );
  }
}
