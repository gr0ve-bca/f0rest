import 'package:f0rest/src/news/models/news_article.dart';
import 'package:f0rest/src/news/search/news_search_result.dart';
import 'package:f0rest/src/news/search/news_search_type.dart';
import 'package:string_similarity/string_similarity.dart';

class NewsSearcher {
  static const double _similarityThreshold = 0.3; // tune later

  Map<NewsArticle, double> searchByType(
    List<NewsArticle> articles,
    NewsSearchType type,
    String query,
  ) {
    Map<NewsArticle, double> searchResults = {};
    articles.forEach((article) {
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
    });
    return searchResults;
  }

  Map<NewsArticle, double> mergeResults(
    Map<NewsArticle, double> a,
    Map<NewsArticle, double> b,
  ) {
    Map<NewsArticle, double> merged = {};

    a.forEach((article, scoreA) {
      if (b.containsKey(article)) {
        merged[article] = (scoreA + b[article]!) / 2;
      } else {
        merged[article] = scoreA;
      }
    });

    b.forEach((article, scoreB) {
      if (!a.containsKey(article)) {
        merged[article] = scoreB;
      }
    });

    return merged;
  }

  List<NewsSearchResult> search(
    List<NewsArticle> articles,
    String query,
    Set<NewsSearchType> types,
  ) {
    Map<NewsArticle, double> results = {};
    List<NewsSearchResult> convertedResults = [];
    types.forEach((type) {
      results = mergeResults(searchByType(articles, type, query), results);
    });
    results.forEach((article, score) {
      convertedResults.add(NewsSearchResult(article: article, score: score));
    });
    convertedResults.sort((a, b) => b.score.compareTo(a.score));
    return convertedResults;
  }
}
