<div align="center">
<h1>f0rest</h1>
</div>

f0rest is a standalone, pure-Dart data layer package engineered for [gr0ve](https://github.com/gr0ve-bca/gr0ve). Every module is designed to be usable in plain Dart, and tested without a UI, and swapped into gr0ve – or any other consumer – as a git or path dependency. The package, currently a work in progress, is intended to have five key components: buses, lunch, news, events, and teacher absences. It is important to note that teacher absences and events have been publicly excluded, however, if desired, please email the appropriate email listed below.

## What's Here

### News

Currently, the only public module is News, which fetches, parses, and searches articles from [Academy Chronicle](https://academychronicle.org)'s RSS feed. Internally, it follows a clean pipeline: `AcademyChronicleSource` handles the actual HTTP fetch and hands raw XML to `AcademyChronicleParser`, which turns it into plain `NewsArticle` objects with no knowledge of HTTP or XML itself. `News` sits on top of both, exposing everything a consumer actually needs — fetching, filtering, and search — without leaking any of the underlying RSS/HTTP machinery.

The `News` modules is split into two main components: fetching and querying. Fetch methods are asynchronous and hit the network through `NewsSource`:

```dart
final news = News(AcademyChronicleSource());

final page1 = await news.fetchPage(1);
final latest = await news.fetchArticles();
final recent = await news.fetchRecentArticles(count: 50);
```

On the other hand, query methods, are synchronous and operate on the provided `List<NewsArticles>`. They don't fetch anything themselves; filtering or searching never causes a redundant network call, and the consumer is always in control of what articles it's querying.

```dart
final categories = news.getCategories(latest);
final stemArticles = news.getArticlesByCategory(latest, 'STEM');
```

Search supports title, author, category, or tag (concurrently, if desired) and utilizes the `string_similarity` package. In doing so, typos or misspellings don't prevent relevant matches from surfacing.

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

Results are returned as `NewsSearchResult` objects, sorted descending by relevance, so the most relevant match is always at index `0`. When a query involves more the one `NewsSearchType`, the article's type scores are averaged out. In doing so, an article meeting multiple filters doesn't automatically outrank one with a single strong match.

Failures throughout the module are surfaced as typed exceptions rather than generic ones. For example, a failed HTTP request raises a `NewsFetchException` carrying the page number and status code involved, letting a consumer distinguish a fetch failure from other kinds of errors and react accordingly.

## Usage

Anyone is free to use this repository, so long as they agree to the [LICENSE.md](LICENSE.md).

In short: when using this repository, they must have explicit permission from the owner, and clients must clearly attribute the source of their data to **f0rest** or **Arjun Yuvaraj**.

## Ownership

This repository is maintained by Arjun Yuvaraj, the founder of gr0ve. For questions about usage, citations, or anything else, email **[gr0ve.bca@gmail.com](mailto:gr0ve.bca@gmail.com)**.

---

_This is f0rest, Version 0.1.0, a data-collection layer, and part of the gr0ve family._
