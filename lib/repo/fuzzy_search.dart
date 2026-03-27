import 'package:fuzzywuzzy/fuzzywuzzy.dart';
import 'package:pokemon/utils/constants.dart';

class FuzzySearchArgs {
  final String query;
  final List<({int id, String name})> corpus;

  const FuzzySearchArgs({required this.query, required this.corpus});
}

List<int> runFuzzySearch(FuzzySearchArgs args) {
  final query = args.query.toLowerCase().trim();

  final scored = <({int id, int score})>[];
  for (final entry in args.corpus) {
    final score = weightedRatio(query, entry.name.toLowerCase());
    if (score >= AppConfig.fuzzyThreshold) {
      scored.add((id: entry.id, score: score));
    }
  }

  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored.map((e) => e.id).toList();
}
