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

## 0.3.0

- Initial release of the Bus module.
- `Bus` API: `get(town)` returns where a town's bus is parked, as a list of `BusSpot`s.
- `BusSpot` result type (`label`, `spot`); `spot` is the sheet's text for that bus, usually a grid cell like `B2` but possibly a status like `5min`, and `null` if the bus hasn't arrived.
- `BusSource` interface and `GoogleSheetBusSource`, which reads BCA's public bus location sheet as CSV. No database, server, or API key.
- Forgiving lookup: ignores case, spacing, punctuation, and `BA` tags, and resolves each town inside slash-joined sheet cells (`Alpine/Bergenfield`).
- Towns that appear in several sheet cells (e.g. Franklin Lakes) return one entry per bus.
- Short-lived cache (30 second TTL by default) that shares one download between concurrent calls.
- Typed exceptions (`BusException`, `BusFetchException`, `BusFormatException`) to help understand the root of errors.
- Added the `csv` dependency.
