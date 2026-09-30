import 'dart:math' as math;

import 'package:f0rest/src/news/models/news_article.dart';
import 'package:f0rest/src/news/search/news_search_result.dart';
import 'package:f0rest/src/news/search/news_search_type.dart';
import 'package:string_similarity/string_similarity.dart';

class NewsSearcher {
  static const double _similarityThreshold = 0.3;

  Map<NewsArticle, double> searchByType(
    List<NewsArticle> articles,
    NewsSearchType type,
    String query,
  ) {
    final Map<NewsArticle, double> searchResults = {};
    for (final article in articles) {
      final double similarity = switch (type) {
        NewsSearchType.author => StringSimilarity.compareTwoStrings(
          query,
          article.author,
        ),
        NewsSearchType.title => StringSimilarity.compareTwoStrings(
          query,
          article.title,
        ),
        NewsSearchType.category =>
          article.categories.isNotEmpty
              ? StringSimilarity.findBestMatch(
                      query,
                      article.categories,
                    ).bestMatch.rating ??
                    0.0
              : 0.0,
        NewsSearchType.tag =>
          article.tags.isNotEmpty
              ? StringSimilarity.findBestMatch(
                      query,
                      article.tags,
                    ).bestMatch.rating ??
                    0.0
              : 0.0,
      };

      if (similarity > _similarityThreshold) {
        searchResults[article] = similarity;
      }
    }
    return searchResults;
  }

  Map<NewsArticle, double> mergeResults(
    Map<NewsArticle, double> a,
    Map<NewsArticle, double> b,
  ) {
    final Map<NewsArticle, double> merged = {};

    for (final entry in a.entries) {
      if (b.containsKey(entry.key)) {
        merged[entry.key] = math.max(entry.value, b[entry.key]!);
      } else {
        merged[entry.key] = entry.value;
      }
    }

    for (final entry in b.entries) {
      if (!a.containsKey(entry.key)) {
        merged[entry.key] = entry.value;
      }
    }

    return merged;
  }

  List<NewsSearchResult> search(
    List<NewsArticle> articles,
    String query,
    Set<NewsSearchType> types,
  ) {
    Map<NewsArticle, double> results = {};
    for (final type in types) {
      results = mergeResults(searchByType(articles, type, query), results);
    }
    final convertedResults = [
      for (final entry in results.entries)
        NewsSearchResult(article: entry.key, score: entry.value),
    ];
    convertedResults.sort((a, b) => b.score.compareTo(a.score));
    return convertedResults;
  }
}
