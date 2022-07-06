class Comment {
  final String comment;
  final String by;
  final List<dynamic> kids;
  Comment({required this.comment, required this.by, required this.kids});
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comment: (json["text"] ?? '') as String,
      by: (json["by"] ?? '') as String,
      kids: (json["kids"] ?? []) as List<dynamic>,
    );
  }
}
