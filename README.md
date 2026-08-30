<div align="center">
<h1>f0rest</h1>
</div>

f0rest is a standalone, pure-Dart data layer package engineered for [gr0ve](https://github.com/gr0ve-bca/gr0ve). Every module is designed to be usable in plain Dart, and tested without a UI, and swapped into gr0ve – or any other consumer – as a git or path dependency. The package, currently a work in progress, is intended to have five key components: buses, lunch, news, events, and teacher absences. It is important to note that teacher absences and events have been publicly excluded, however, if desired, please email the appropriate email listed below.

## What's Here

### News

The news module returns data fetched from Academy Chronicle, BCA's first, and only, newspaper. The module returns the data into clean objects, allowing for easy handling thereafter. Moreover, the module also supports querying.

```dart
final news = News(AcademyChronicleSource());

final page1 = await news.fetchPage(1);
final latest = await news.fetchArticles();
final recent = await news.fetchRecentArticles(count: 50);
```

The searching section of the module never fetches to outside sources. Instead, it returns results based on the provided list of articles.

```dart
final categories = news.getCategories(latest);
final stemArticles = news.getArticlesByCategory(latest, 'STEM');
```

The module was built off of the [string_similarity] (https://pub.dev/packages/string_similarity/) package, which ensures that minor typos and misspellings to not affect the final list.

```dart
final results = news.search(
  latest,
  'robtics', // typo is intentional
  types: {NewsSearchType.title, NewsSearchType.tag},
);

for (final result in results) {
  print('${result.article.title} — score: ${result.score}');
}
```

Results come back ranked by relevance, with the best match first.

### Lunch

The lunch module fetches data through Nutrislice's API. After fetching it cleanly sorts all of the items into clean objects, giving each dish there respective properties: common allergens, ingredients, stations, etc.

```dart
final lunchMenu = LunchMenu(NutrisliceSource());

final today = await lunchMenu.fetchToday();
final tuesday = await lunchMenu.fetchForDate(DateTime(2026, 9, 1));
```

Similar to the news module, searching is also provided.

```dart
final results = lunchMenu.search(today, 'chicken');
```

## Usage

Anyone is free to use this repository, so long as they agree to the [LICENSE.md](LICENSE.md).

In short: when using this repository, they must have explicit permission from the owner, and clients must clearly attribute the source of their data to **f0rest** or **Arjun Yuvaraj**.

## Ownership

This repository is maintained by Arjun Yuvaraj, the founder of gr0ve. For questions about usage, citations, or anything else, email **[gr0ve.bca@gmail.com](mailto:gr0ve.bca@gmail.com)**.

---

_This is f0rest, Version 0.2.0, a data-collection layer, and part of the gr0ve family._
