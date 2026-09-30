import 'dart:convert';
import 'package:http/http.dart' as http;

class SchedulePeriod {
  final DateTime start, end;
  final bool lunch;
  const SchedulePeriod(this.start, this.end, this.lunch);
}

class Schedule {
  Schedule(this.url, {http.Client? client, DateTime Function()? clock})
    : _client = client ?? http.Client(),
      _now = clock ?? DateTime.now {
    _validateUrl(url);
  }

  static void _validateUrl(Uri url) {
    if (!url.hasScheme || (url.scheme != 'https' && url.scheme != 'http')) {
      throw ArgumentError.value(url, 'url', 'URL must be http or https');
    }
    final host = url.host.toLowerCase();
    if (host.isEmpty ||
        host == 'localhost' ||
        host == '127.0.0.1' ||
        host == '::1' ||
        host.startsWith('10.') ||
        host.startsWith('192.168.') ||
        host.startsWith('169.254.') ||
        host.endsWith('.local') ||
        host.endsWith('.internal')) {
      throw ArgumentError.value(url, 'url', 'Disallowed host for schedule');
    }
  }

  final Uri url;
  final http.Client _client;
  final DateTime Function() _now;
  Future<Map<String, dynamic>>? _data;

  Future<Map<String, SchedulePeriod>> today() => on(_now());

  Future<Map<String, SchedulePeriod>> on(DateTime day) async {
    final d = DateTime(day.year, day.month, day.day);
    final kind = _kind(d);
    if (kind == null) return const {};

    final data = await _load();
    return {
      for (final p in (data[kind] as List).cast<Map<String, dynamic>>())
        p['period'] as String: SchedulePeriod(
          _rebase(d, p['start']),
          _rebase(d, p['end']),
          p['lunch'] == true,
        ),
    };
  }

  Future<Map<String, dynamic>> _load() => _data ??= _client
      .get(url)
      .then((r) => jsonDecode(r.body) as Map<String, dynamic>)
      .catchError((Object e) {
        _data = null;
        throw e;
      });

  static DateTime _rebase(DateTime d, String iso) {
    final t = DateTime.parse(iso);
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  static String? _kind(DateTime d) {
    if (d.weekday > DateTime.friday) return null;
    if (d.isBefore(_firstDay) || d.isAfter(_lastDay)) return null;
    if (_in(_closed, d)) return null;
    return _in(_half, d) ? 'half' : 'regular';
  }

  static bool _in(List<(DateTime, DateTime)> ranges, DateTime d) =>
      ranges.any((r) => !d.isBefore(r.$1) && !d.isAfter(r.$2));

  static (DateTime, DateTime) _r(int y, int m, int from, [int? to]) =>
      (DateTime(y, m, from), DateTime(y, m, to ?? from));

  static final _firstDay = DateTime(2026, 8, 31);
  static final _lastDay = DateTime(2027, 6, 16);

  static final _closed = [
    _r(2026, 8, 27, 28),
    _r(2026, 9, 7),
    _r(2026, 9, 21),
    _r(2026, 10, 12),
    _r(2026, 11, 5, 6),
    _r(2026, 11, 26, 27),
    _r(2026, 12, 24, 31),
    _r(2027, 1, 1),
    _r(2027, 1, 18),
    _r(2027, 2, 12, 15),
    _r(2027, 3, 10),
    _r(2027, 3, 22, 26),
    _r(2027, 5, 31),
  ];

  static final _half = [
    _r(2026, 9, 4),
    _r(2026, 9, 18),
    _r(2026, 9, 25),
    _r(2026, 11, 25),
    _r(2026, 12, 14),
    _r(2026, 12, 23),
    _r(2027, 2, 11),
    _r(2027, 3, 2),
    _r(2027, 3, 4),
    _r(2027, 5, 20),
    _r(2027, 6, 10, 15),
    _r(2027, 6, 16),
  ];
}
