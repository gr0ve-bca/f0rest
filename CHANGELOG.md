## 0.1.0

- Initial release of the News module.
- `NewsArticle` model; includes proper hashing and equality.
- `AcademyChronicleSource` for fetching Academy Chronicle's RSS feed
- `AcademyChronicleParser` for converting raw RSS XML into `NewsArticle` instances.
- Typed exceptions (`NewsException`, `NewsFetchException`) to help understand the root of errors
- `News` API exposing paginated fetching and synchronous querying over caller-supplied article lists.
- `NewsSearcher` with "typo-proof", filtered search (`title`, `author`, `category`, `tag`) through string similarity scoring, returning ranked `NewsSearchResult`s.

## 0.2.0

- Initial release of the Lunch module.
- `LunchItem` model; includes proper hashing and equality.
- Overall structure is similar to `News` modules.
- Users can fetch for current or specific dates
