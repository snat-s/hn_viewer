class News {
  final String by;
  final String title;
  //final int descendants;
  final int id;
  final int score;
  final String type;
  final List<dynamic> kids;
  final String url;
  final String text;

  const News({
    required this.by,
    //required this.descendants,
    required this.id,
    required this.score,
    required this.title,
    required this.type,
    required this.kids,
    required this.url,
    required this.text,
  });
  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      by: (json["by"] ?? '') as String,
      title: (json["title"] ?? '') as String,
      id: json["id"] as int,
      score: (json["score"] ?? 0) as int,
      type: json["type"] as String,
      kids: (json["kids"] ?? []) as List<dynamic>,
      url: (json['url'] ?? '') as String,
      text: (json['text'] ?? '') as String,
    );
  }
}
