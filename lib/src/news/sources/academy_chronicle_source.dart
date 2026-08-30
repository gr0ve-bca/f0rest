// lib/src/news/sources/academy_chronicle_source.dart

import 'package:f0rest/src/news/models/news_article.dart';
import 'package:f0rest/src/news/models/news_error.dart';
import 'package:f0rest/src/news/parsing/academy_chronicle_parser.dart';
import 'package:f0rest/src/news/sources/news_source.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class AcademyChronicleSource implements NewsSource {
  AcademyChronicleSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;
  static const baseUrl = 'https://academychronicle.org/feed/';
  final parser = AcademyChronicleParser();
  @override
  Future<List<NewsArticle>> fetchPage(int page) async {
    final url = "$baseUrl?paged=$page";
    final response = await _client
        .get(
          Uri.parse(url),
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw NewsFetchException(
        message: 'Failed to fetch page $page: ${response.statusCode}',
        page: page,
        statusCode: response.statusCode,
      );
    }

    final document = xml.XmlDocument.parse(response.body);
    final items = document.findAllElements("item");

    List<NewsArticle> newsArticles = [];

    items.forEach((item) {
      newsArticles.add(parser.createArticle(item));
    });

    return newsArticles;
  }
}
