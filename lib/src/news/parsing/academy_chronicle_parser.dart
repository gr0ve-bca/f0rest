import 'package:f0rest/src/news/models/news_article.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

class AcademyChronicleParser {
  String? _extractFeaturedImage(XmlElement item, String content) {
    final mediaContent = item.getElement('media:content');
    if (mediaContent != null) {
      final url = mediaContent.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    final mediaThumbnail = item.getElement('media:thumbnail');
    if (mediaThumbnail != null) {
      final url = mediaThumbnail.getAttribute('url');
      if (url != null && url.isNotEmpty) {
        return url;
      }
    }

    final enclosure = item.getElement('enclosure');
    if (enclosure != null) {
      final type = enclosure.getAttribute('type');
      if (type != null && type.startsWith('image/')) {
        final url = enclosure.getAttribute('url');
        if (url != null && url.isNotEmpty) {
          return url;
        }
      }
    }

    final imgRegex = RegExp(r'<img[^>]+src="([^">]+)"', caseSensitive: false);
    final match = imgRegex.firstMatch(content);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    return null;
  }

  DateTime? _parseDate(String? pubDate) {
    if (pubDate == null || pubDate.isEmpty) return null;

    try {
      final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss zzz');
      return format.parse(pubDate);
    } catch (_) {
      try {
        return DateTime.parse(pubDate);
      } catch (_) {
        try {
          final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z');
          return format.parse(pubDate);
        } catch (_) {
          return null;
        }
      }
    }
  }

  NewsArticle createArticle(XmlElement item) {
    final title = item.getElement('title')?.innerText ?? 'No title';
    final link = item.getElement('link')?.innerText ?? '';
    final author =
        item.getElement('dc:creator')?.innerText ?? 'Academy Chronicle';

    final pubDate = item.getElement('pubDate')?.innerText;
    DateTime? published = _parseDate(pubDate);

    final description = item.getElement('description')?.innerText ?? '';
    final contentEncoded = item.getElement('content:encoded')?.innerText ?? '';
    final content = contentEncoded.isNotEmpty ? contentEncoded : description;

    final excerpt = description;

    final List<String> categories = [];
    final List<String> tags = [];

    final categoryElements = item.findElements('category');
    for (var categoryElement in categoryElements) {
      final domain = categoryElement.getAttribute('domain');
      final categoryValue = categoryElement.innerText;

      if (categoryValue.isNotEmpty) {
        if (domain == 'category') {
          categories.add(categoryValue);
        } else if (domain == 'post_tag') {
          tags.add(categoryValue);
        } else {
          categories.add(categoryValue);
        }
      }
    }

    String? featuredImage = _extractFeaturedImage(item, content);

    int? commentCount;
    final commentRssElement = item.getElement('slash:comments');
    if (commentRssElement != null) {
      commentCount = int.tryParse(commentRssElement.innerText);
    }

    return NewsArticle(
      title: title,
      link: link,
      content: content,
      author: author,
      published: published,
      categories: categories,
      tags: tags,
      featuredImage: featuredImage,
      excerpt: excerpt,
      commentCount: commentCount,
    );
  }
}
