import 'package:flutter/material.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key, required this.title, required this.height});

  final String title;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints.tightForFinite(
          height: height,
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
