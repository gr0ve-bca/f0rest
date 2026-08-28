import 'package:f0rest/src/news/models/news_article.dart';

class NewsSearchResult {
  final NewsArticle article;
  final double score;

  const NewsSearchResult({required this.article, required this.score});
}
