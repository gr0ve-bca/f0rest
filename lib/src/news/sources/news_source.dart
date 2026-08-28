import 'package:f0rest/src/news/models/news_article.dart';

abstract interface class NewsSource {
  Future<List<NewsArticle>> fetchPage(int page);
}
