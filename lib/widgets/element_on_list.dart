import 'package:flutter/material.dart';

import '../classes/news.dart';
import '../Screens/specific_story.dart';

class ElementOnList extends StatefulWidget {
  Future<News> specificNews;
  ElementOnList({super.key, required this.specificNews});

  @override
  State<ElementOnList> createState() => _ElementOnListState();
}

class _ElementOnListState extends State<ElementOnList> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecificNews(news: widget.specificNews),
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<News>(
            future: widget.specificNews,
            builder: ((BuildContext context, AsyncSnapshot<News> snapshot2) {
              if (snapshot2.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot2.data!.title,
                            textAlign: TextAlign.left,
                            softWrap: true,
                          ),
                          Text(
                            '${snapshot2.data!.score} points ' +
                                'by ${snapshot2.data!.by}',
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else if (snapshot2.hasError) {
                return Text('${snapshot2.error}');
              }
              return const Text('Loading...');
            })),
      ),
    );
  }
}
