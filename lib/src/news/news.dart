// lib/src/news/news.dart

import 'package:f0rest/src/news/models/news_article.dart';
import 'package:f0rest/src/news/sources/news_source.dart';
import 'package:f0rest/src/news/search/news_searcher.dart';
import 'package:f0rest/src/news/search/news_search_result.dart';
import 'package:f0rest/src/news/search/news_search_type.dart';

class News {
  final NewsSource _source;
  final NewsSearcher _searcher;

  News(this._source, [NewsSearcher? searcher])
    : _searcher = searcher ?? NewsSearcher();

  Future<List<NewsArticle>> fetchArticles() {
    return fetchPage(1);
  }

  Future<List<NewsArticle>> fetchPage(int page) {
    return _source.fetchPage(page);
  }

  Future<List<NewsArticle>> fetchRecentArticles({int count = 50}) async {
    final pagesNeeded = (count / 10).ceil();
    List<NewsArticle> allArticles = [];

    for (int page = 1; page <= pagesNeeded; page++) {
      final pageArticles = await fetchPage(page);
      if (pageArticles.isEmpty) break;
      allArticles.addAll(pageArticles);
      if (allArticles.length >= count) break;
    }

    final uniqueArticles = <String, NewsArticle>{};
    for (var article in allArticles) {
      uniqueArticles.putIfAbsent(article.link, () => article);
    }

    final articles = uniqueArticles.values.toList();
    articles.sort((a, b) {
      if (a.published == null && b.published == null) return 0;
      if (a.published == null) return 1;
      if (b.published == null) return -1;
      return b.published!.compareTo(a.published!);
    });

    return articles.take(count).toList();
  }

  List<String> getCategories(List<NewsArticle> articles) {
    final categories = <String>{};
    for (var article in articles) {
      categories.addAll(article.categories);
    }
    return categories.toList()..sort();
  }

  List<String> getTags(List<NewsArticle> articles) {
    final tags = <String>{};
    for (var article in articles) {
      tags.addAll(article.tags);
    }
    return tags.toList()..sort();
  }

  List<NewsArticle> getArticlesByCategory(
    List<NewsArticle> articles,
    String category,
  ) {
    return articles.where((article) {
      return article.categories.any(
        (cat) => cat.toLowerCase() == category.toLowerCase(),
      );
    }).toList();
  }

  List<NewsArticle> getArticlesByTag(List<NewsArticle> articles, String tag) {
    return articles.where((article) {
      return article.tags.any((t) => t.toLowerCase() == tag.toLowerCase());
    }).toList();
  }

  List<NewsSearchResult> search(
    List<NewsArticle> articles,
    String query, {
    Set<NewsSearchType> types = const {
      NewsSearchType.title,
      NewsSearchType.author,
    },
  }) {
    return _searcher.search(articles, query, types);
  }
}
