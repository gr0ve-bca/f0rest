import 'package:f0rest/src/news/models/news_article.dart';
import 'package:f0rest/src/news/models/news_error.dart';
import 'package:f0rest/src/news/parsing/academy_chronicle_parser.dart';
import 'package:f0rest/src/news/sources/academy_chronicle_source.dart';
import 'package:f0rest/src/news/search/news_search_type.dart';
import 'package:f0rest/src/news/search/news_searcher.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('NewsArticle equality', () {
    test(
      'two articles with same title+link are equal, even if other fields differ',
      () {
        final a = NewsArticle(
          title: 'Robotics Wins',
          link: 'https://x.com/1',
          content: 'A',
          author: 'Jane',
        );
        final b = NewsArticle(
          title: 'Robotics Wins',
          link: 'https://x.com/1',
          content: 'Different content',
          author: 'Someone Else',
        );
        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      },
    );

    test('articles with different links are not equal', () {
      final a = NewsArticle(
        title: 'X',
        link: 'https://x.com/1',
        content: '',
        author: '',
      );
      final b = NewsArticle(
        title: 'X',
        link: 'https://x.com/2',
        content: '',
        author: '',
      );
      expect(a, isNot(equals(b)));
    });
  });

  group('AcademyChronicleParser.createArticle', () {
    final parser = AcademyChronicleParser();

    test('parses a fully-populated item correctly', () {
      final doc = XmlDocument.parse('''
        <rss xmlns:content="http://purl.org/rss/1.0/modules/content/"
             xmlns:dc="http://purl.org/dc/elements/1.1/"
             xmlns:slash="http://purl.org/rss/1.0/modules/slash/">
          <channel>
            <item>
              <title>Robotics Club Wins Regionals</title>
              <link>https://academychronicle.org/robotics-wins/</link>
              <dc:creator>Jane Doe</dc:creator>
              <pubDate>Mon, 12 Jan 2026 10:00:00 +0000</pubDate>
              <description>The robotics team took first place.</description>
              <content:encoded><![CDATA[<p>Full story <img src="https://example.com/photo.jpg"/></p>]]></content:encoded>
              <category domain="category">STEM</category>
              <category domain="post_tag">robotics</category>
              <slash:comments>4</slash:comments>
            </item>
          </channel>
        </rss>
      ''');
      final item = doc.findAllElements('item').first;
      final article = parser.createArticle(item);

      expect(article.title, 'Robotics Club Wins Regionals');
      expect(article.link, 'https://academychronicle.org/robotics-wins/');
      expect(article.author, 'Jane Doe');
      expect(article.published, isNotNull);
      expect(article.categories, ['STEM']);
      expect(article.tags, ['robotics']);
      expect(article.content, contains('Full story'));
      expect(article.featuredImage, 'https://example.com/photo.jpg');
      expect(article.commentCount, 4);
    });

    test('falls back to sane defaults when fields are missing', () {
      final doc = XmlDocument.parse(
        '<rss><channel><item></item></channel></rss>',
      );
      final item = doc.findAllElements('item').first;
      final article = parser.createArticle(item);

      expect(article.title, 'No title');
      expect(article.link, '');
      expect(article.author, 'Academy Chronicle');
      expect(article.published, isNull);
      expect(article.categories, isEmpty);
      expect(article.tags, isEmpty);
      expect(article.featuredImage, isNull);
      expect(article.commentCount, isNull);
    });
  });

  group('AcademyChronicleSource.fetchPage', () {
    const fakeFeed = '''
      <rss xmlns:content="http://purl.org/rss/1.0/modules/content/"
           xmlns:dc="http://purl.org/dc/elements/1.1/">
        <channel>
          <item>
            <title>Test Article</title>
            <link>https://academychronicle.org/test/</link>
            <dc:creator>Author One</dc:creator>
            <description>An excerpt.</description>
          </item>
        </channel>
      </rss>
    ''';

    test('returns parsed articles on a 200 response', () async {
      final client = MockClient(
        (request) async => http.Response(fakeFeed, 200),
      );
      final source = AcademyChronicleSource(client: client);

      final articles = await source.fetchPage(1);

      expect(articles, hasLength(1));
      expect(articles.first.title, 'Test Article');
    });

    test(
      'throws NewsFetchException with correct page/statusCode on failure',
      () async {
        final client = MockClient(
          (request) async => http.Response('Server Error', 500),
        );
        final source = AcademyChronicleSource(client: client);

        expect(
          () => source.fetchPage(3),
          throwsA(
            isA<NewsFetchException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having((e) => e.page, 'page', 3),
          ),
        );
      },
    );
  });

  group('NewsSearcher', () {
    final searcher = NewsSearcher();

    final robotics = NewsArticle(
      title: 'Robotics Club Wins Regionals',
      link: 'https://x.com/1',
      content: '',
      author: 'Jane Doe',
      categories: ['STEM'],
      tags: ['robotics'],
    );
    final bakeSale = NewsArticle(
      title: 'Bake Sale Fundraiser',
      link: 'https://x.com/2',
      content: '',
      author: 'John Smith',
      categories: ['Events'],
      tags: ['fundraiser'],
    );

    test('searchByType finds a title match even with a typo', () {
      final results = searcher.searchByType(
        [robotics, bakeSale],
        NewsSearchType.title,
        'Robitics',
      );
      expect(results, contains(robotics));
      expect(results.containsKey(bakeSale), isFalse);
    });

    test('searchByType category matches best entry in the list field', () {
      final results = searcher.searchByType(
        [robotics, bakeSale],
        NewsSearchType.category,
        'STEM',
      );
      expect(results[robotics], greaterThan(0.3));
      expect(results.containsKey(bakeSale), isFalse);
    });

    test(
      'mergeResults takes the maximum score for an article present in both maps',
      () {
        final merged = searcher.mergeResults({robotics: 0.8}, {robotics: 0.4});
        expect(merged[robotics], 0.8);
      },
    );

    test('mergeResults keeps an article present in only one map unchanged', () {
      final merged = searcher.mergeResults({
        robotics: 0.8,
      }, <NewsArticle, double>{});
      expect(merged[robotics], 0.8);
    });

    test('search returns results sorted descending by score', () {
      final results = searcher.search(
        [robotics, bakeSale],
        'robotics',
        {NewsSearchType.title, NewsSearchType.tag},
      );
      expect(results.first.article, robotics);
      expect(results.first.score, greaterThanOrEqualTo(results.last.score));
    });
  });
}
