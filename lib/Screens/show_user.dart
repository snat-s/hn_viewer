import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../classes/user.dart';
import '../functions/all_functions.dart';

class ShowUser extends StatefulWidget {
  const ShowUser({super.key, required this.user});

  final String user;

  @override
  State<ShowUser> createState() => _ShowUserState();
}

class _ShowUserState extends State<ShowUser> {
  late Future<User> specificUser;
  final titleStyle = const TextStyle(color: Colors.black, fontSize: 30);

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
                    child: RichText(
                      text: TextSpan(
                        style: titleStyle,
                        children: [
                          const TextSpan(
                            text: 'Name: ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(text: snapshot.data!.id)
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15),
                  sliver: SliverToBoxAdapter(
                    child: RichText(
                      text: TextSpan(
                        style: titleStyle,
                        children: [
                          const TextSpan(
                            text: 'Karma: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: '${snapshot.data!.karma}'),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.all(15),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      'About: ',
                      //style: titleStyle,
                      style: TextStyle(color: Colors.black, fontSize: 30),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(15.0),
                  sliver: SliverToBoxAdapter(
                    //child: Text(snapshot.data!.about),
                    child: Html(
                      data: snapshot.data!.about,
                      onLinkTap: (url, context, attributes, element) async {
                        if (!await launchUrl(Uri.parse(url!))) {
                          throw 'Could not launch $url';
                        }
                      },
                      style: {
                        "body": Style(
                          fontSize: FontSize.large,
                        ),
                      },
                    ),
                  ),
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
