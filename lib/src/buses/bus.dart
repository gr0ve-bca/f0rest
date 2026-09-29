import 'package:f0rest/src/buses/models/bus_error.dart';
import 'package:f0rest/src/buses/sources/bus_source.dart';
import 'package:f0rest/src/buses/sources/google_bus_sheet_source.dart';
import 'package:f0rest/src/buses/models/bus_spot.dart';

typedef _Index = Map<String, List<BusSpot>>;

class Bus {
  Bus({BusSource? source, this.ttl = const Duration(hours: 1)})
    : _source = source ?? GoogleSheetBusSource();

  final BusSource _source;
  final Duration ttl;

  _Index? _index;
  DateTime _expires = DateTime.fromMillisecondsSinceEpoch(0);
  Future<_Index>? _inflight;

  Future<List<BusSpot>> get(String town) async =>
      (await _load())[_key(town)] ?? const [];

  Future<_Index> _load() {
    final index = _index;
    if (index != null && DateTime.now().isBefore(_expires)) {
      return Future.value(index);
    }
    return _inflight ??= _refresh().whenComplete(() => _inflight = null);
  }

  Future<_Index> _refresh() async {
    final index = _buildIndex(await _source.fetchRows());
    _expires = DateTime.now().add(ttl);
    return _index = index;
  }

  static _Index _buildIndex(List<List<String>> rows) {
    final header = rows.isEmpty ? const <String>[] : rows.first;
    final columns = [
      for (var c = 0; c < header.length; c++)
        if (header[c].trim() == 'Town(s)') c,
    ];
    if (columns.isEmpty) {
      throw const BusFormatException('No "Town(s)" column in bus sheet');
    }

    final index = _Index();
    for (final c in columns) {
      for (var r = 1; r < rows.length; r++) {
        final cell = c < rows[r].length ? rows[r][c].trim() : '';
        if (cell.isEmpty) break;
        final spot = c + 1 < rows[r].length ? rows[r][c + 1].trim() : '';
        final entry = (label: cell, spot: spot.isEmpty ? null : spot);
        for (final town in cell.split('/')) {
          final key = _key(town);
          if (key.isNotEmpty) (index[key] ??= []).add(entry);
        }
      }
    }
    return index;
  }

  static final _nonAlnum = RegExp(r'[^a-z0-9]');
  static final _busTag = RegExp(r'ba\d+$');

  static String _key(String s) =>
      s.toLowerCase().replaceAll(_nonAlnum, '').replaceFirst(_busTag, '');
}
