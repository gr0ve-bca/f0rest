## 0.1.0

- Initial release of the News module.
- `NewsArticle` model with value equality.
- `AcademyChronicleSource` (`NewsSource` implementation) for fetching Academy Chronicle's RSS feed, with dependency-injectable `http.Client`.
- `AcademyChronicleParser` for converting raw RSS XML into `NewsArticle` instances.
- Typed exceptions (`NewsException`, `NewsFetchException`) for distinguishing fetch failures from other errors.
- `News` API exposing paginated fetching (`fetchPage`, `fetchArticles`, `fetchRecentArticles`) and synchronous querying (`getCategories`, `getTags`, `getArticlesByCategory`, `getArticlesByTag`) over caller-supplied article lists.
- `NewsSearcher` with typo-tolerant, multi-type search (`title`, `author`, `category`, `tag`) via string similarity scoring, returning ranked `NewsSearchResult`s.
- Full test coverage for parsing, fetching, and search logic using fabricated data and `MockClient` — no live network calls required.
