import 'package:f0rest/src/news/sources/academy_chronicle_source.dart';

void main() async {
  final source = AcademyChronicleSource();
  final articles = await source.fetchPage(1);
}
