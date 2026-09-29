abstract interface class BusSource {
  Future<List<List<String>>> fetchRows();
}
