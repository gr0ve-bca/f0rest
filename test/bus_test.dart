import 'package:f0rest/src/buses/bus.dart';
import 'package:f0rest/src/buses/sources/google_bus_sheet_source.dart';
import 'package:test/test.dart';

void main() {
  late Bus bus;
  setUpAll(() => bus = Bus()); // real GoogleSheetBusSource, default ttl

  test('layout: "Town(s)" headers are in A1 and C1', () async {
    final rows = await GoogleSheetBusSource().fetchRows();
    expect(rows.first[0].trim(), 'Town(s)');
    expect(rows.first[2].trim(), 'Town(s)');
  });

  test('reads both blocks: first of A and last of C', () async {
    expect(await bus.get('Allendale'), isNotEmpty);
    expect(await bus.get('Wallington'), isNotEmpty);
  });

  test('normalization finds the same entry', () async {
    final exact = await bus.get('Glen Rock');
    expect(exact, isNotEmpty);
    expect(await bus.get('  glen   ROCK '), exact);
    expect(
      await bus.get('Cliffside Park'),
      isNotEmpty,
    ); // "CliffsidePark" in sheet
    expect(await bus.get('ho ho kus'), isNotEmpty); //      "Ho-Ho-Kus" in sheet
  });

  test('slash-joined cells and BA tags', () async {
    expect((await bus.get('Bergenfield')).single.label, 'Alpine/Bergenfield');
    expect(
      (await bus.get('Wyckoff')).single.label,
      'Franklin Lakes/Wyckoff BA 10',
    );
    expect(await bus.get('Mahwah West'), hasLength(1));
  });

  test('towns that sit in several cells', () async {
    expect(await bus.get('Franklin Lakes'), hasLength(3));
    expect(await bus.get('Hillsdale'), hasLength(2));
  });

  test('unknown towns and rows below the gap are not indexed', () async {
    expect(await bus.get('Narnia'), isEmpty);
    expect(await bus.get('Last in Row:'), isEmpty);
    expect(await bus.get('Duplicates:'), isEmpty);
  });

  test('every spot is null or a valid grid cell (A-I, 1-13)', () async {
    final grid = RegExp(r'^[A-I]([1-9]|1[0-3])$', caseSensitive: false);
    for (final town in [
      'Allendale',
      'Bergenfield',
      'Glen Rock',
      'Franklin Lakes',
      'Hillsdale',
      'Mahwah West',
      'Saddle River',
      'Teaneck',
      'Wallington',
    ]) {
      for (final b in await bus.get(town)) {
        expect(
          b.spot == null || grid.hasMatch(b.spot!),
          isTrue,
          reason: '$town -> ${b.spot}',
        );
      }
    }
  });
}
