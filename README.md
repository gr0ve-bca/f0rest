# f0rest

f0rest is a standalone, pure-Dart data layer package built for gr0ve, designed to hold no Flutter dependency at all. Every module is meant to be usable from plain Dart, tested without a UI, and swapped into gr0ve (or any other consumer) as a git or path dependency. The package is organized module by module, with each module owning its own models, data sources, parsing, and any domain-specific logic; a handful of other modules exist internally alongside News but aren't included in this public repository for privacy reasons.

The first and currently only public module is **News**, which fetches, parses, and searches articles from [Academy Chronicle](https://academychronicle.org)'s RSS feed. Internally, it follows a clean pipeline: `AcademyChronicleSource` handles the actual HTTP fetch and hands raw XML to `AcademyChronicleParser`, which turns it into plain `NewsArticle` objects with no knowledge of HTTP or XML itself. `News` sits on top of both, exposing everything a consumer actually needs — fetching, filtering, and search — without leaking any of the underlying RSS/HTTP machinery.

`News`'s methods split into two deliberate categories. Fetch methods are asynchronous and hit the network through the underlying `NewsSource`:

```dart
final news = News(AcademyChronicleSource());

final page1 = await news.fetchPage(1);
final latest = await news.fetchArticles();
final recent = await news.fetchRecentArticles(count: 50);
```

Query methods, by contrast, are synchronous and operate on whatever `List<NewsArticle>` you already have in hand, rather than fetching anything themselves — this means filtering or searching never triggers a redundant network call, and a consumer is always in control of exactly which articles it's querying against:

```dart
final categories = news.getCategories(latest);
final stemArticles = news.getArticlesByCategory(latest, 'STEM');
```

Search is the most involved piece of the module. It supports searching by title, author, category, or tag — simultaneously, if desired — and uses string-similarity scoring rather than exact substring matching, so a typo in the query doesn't prevent a relevant match:

```dart
final results = news.search(
  latest,
  'robtics', // typo included
  types: {NewsSearchType.title, NewsSearchType.tag},
);

for (final result in results) {
  print('${result.article.title} — score: ${result.score}');
}
```

Results come back as `NewsSearchResult` objects, sorted descending by relevance, so the best match is always at index `0`. When a query is checked against more than one `NewsSearchType`, an article's per-type scores are merged and averaged rather than simply concatenated, so an article matching on two criteria doesn't automatically outrank one with a single strong match for the wrong reasons.

Failures throughout the module are surfaced as typed exceptions rather than generic ones — a failed HTTP request raises a `NewsFetchException` carrying the page number and status code involved, letting a consumer distinguish a fetch failure from other kinds of errors and react accordingly; more specific exception types are planned as the module's error handling continues to be filled out.

f0rest has no test suite dependent on the live Academy Chronicle feed — every layer, from parsing to searching, is verified against fabricated data via `package:test` and `http`'s `MockClient`, so the whole module can be validated without a single real network request.
