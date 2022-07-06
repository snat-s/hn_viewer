class User {
  final String about;
  final String id;
  final int karma;
  final int created;
  final List<dynamic> submitted;
  const User(
      {required this.about,
      required this.id,
      required this.karma,
      required this.submitted,
      required this.created});
  factory User.fromJson(Map<String?, dynamic> json) {
    return User(
        about: (json["about"] ?? '') as String,
        id: (json["id"] ?? '') as String,
        karma: json["karma"] as int,
        created: (json["created"] ?? 0) as int,
        submitted: (json["submitted"] ?? []) as List<dynamic>);
  }
}
