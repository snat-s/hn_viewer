class TopStories {
  TopStories({required this.topStories});

  final List<dynamic> topStories;

  factory TopStories.fromJson(List<dynamic> json) {
    return TopStories(topStories: json);
  }
  List<dynamic> get getTopStories {
    return topStories;
  }
}
