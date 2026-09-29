import 'dart:convert';

import 'package:f0rest/src/buses/bus.dart';
import 'package:f0rest/src/buses/sources/google_bus_sheet_source.dart';

String _col(int i) => String.fromCharCode(65 + i); // A..Z is plenty here

Future<void> main() async {
  final rows = await GoogleSheetBusSource().fetchRows();
  final bus = Bus();

  print(
    '=== RAW ROWS (${rows.length} total, trailing empty cells trimmed) ===',
  );
  for (var r = 0; r < rows.length; r++) {
    final row = [...rows[r]];
    while (row.isNotEmpty && row.last.trim().isEmpty) {
      row.removeLast();
    }
    if (row.isNotEmpty) print('row ${r + 1}: ${jsonEncode(row)}');
  }

  print('\n=== PARSED, per "Town(s)" column ===');
  final header = rows.first;
  for (var c = 0; c < header.length; c++) {
    if (header[c].trim() != 'Town(s)') continue;
    print(
      '\n--- column ${_col(c)} (spots read from column ${_col(c + 1)}) ---',
    );
    for (var r = 1; r < rows.length; r++) {
      final cell = c < rows[r].length ? rows[r][c].trim() : '';
      if (cell.isEmpty) {
        print('${_col(c)}${r + 1}: (blank, block ends)');
        break;
      }
      final spotRaw = c + 1 < rows[r].length ? rows[r][c + 1] : null;
      print(
        '${_col(c)}${r + 1}: ${jsonEncode(cell)}'
        '   spot cell ${_col(c + 1)}${r + 1}: ${jsonEncode(spotRaw)}',
      );
      for (final part in cell.split('/')) {
        print('    "${part.trim()}" -> ${await bus.get(part)}');
      }
    }
  }
}
