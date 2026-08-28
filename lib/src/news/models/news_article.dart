class NewsArticle {
  final String title;
  final String link;
  final String content;
  final String author;
  final DateTime? published;
  final List<String> categories;
  final List<String> tags;
  final String? featuredImage;
  final String? excerpt;
  final int? commentCount;

  NewsArticle({
    required this.title,
    required this.link,
    required this.content,
    required this.author,
    this.published,
    this.categories = const [],
    this.tags = const [],
    this.featuredImage,
    this.excerpt,
    this.commentCount,
  });

  @override
  String toString() {
    return "$title by $author. Link: $link";
  }

  @override
  bool operator ==(Object other) {
    if (other is NewsArticle) {
      return other.title == title && other.link == link;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(title, link);
}
