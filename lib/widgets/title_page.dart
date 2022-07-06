import 'package:flutter/material.dart';

class TitlePage extends StatelessWidget {
  TitlePage({super.key, required this.title, required this.height2});
  String title;
  double height2;
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.tightForFinite(
          height: height2,
        ),
        color: Colors.orange,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
    );
  }
}
