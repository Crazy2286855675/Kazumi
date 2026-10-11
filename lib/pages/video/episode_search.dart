/// Matches an episode query against a road's episode list.
class EpisodeSearch {
  static final _episodeNumber = RegExp(r'^(?:第\s*)?(\d+)\s*(?:集|话|話)?$');

  /// `123`, `第123集`, `第 123 话`. Returns null when the query is a title.
  static int? parseEpisodeNumber(String query) {
    final match = _episodeNumber.firstMatch(query.trim());
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static final _labelNumber = RegExp(r'^(?:第\s*)?0*(\d+)\s*(?:集|话|話)?$');

  /// 1-based list positions to show for [query].
  ///
  /// An empty query returns every episode. A numeric query matches the
  /// episode whose title is that number, so a reversed source list still
  /// opens the episode the user typed. Lists titled without numbers fall
  /// back to that list position. Any other query filters by title.
  static List<int> visibleEpisodes({
    required String query,
    required int count,
    required List<String> identifiers,
  }) {
    if (count <= 0) return const [];
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [for (var episode = 1; episode <= count; episode++) episode];
    }
    final number = parseEpisodeNumber(trimmed);
    if (number != null) {
      final labeled = <int>[];
      for (var episode = 1; episode <= count; episode++) {
        if (_labelEqualsEpisode(_labelFor(episode, identifiers), number)) {
          labeled.add(episode);
        }
      }
      if (labeled.isNotEmpty) return labeled;
      return number >= 1 && number <= count ? [number] : const [];
    }
    final needle = trimmed.toLowerCase();
    final matches = <int>[];
    for (var episode = 1; episode <= count; episode++) {
      final label = _labelFor(episode, identifiers);
      if (label.toLowerCase().contains(needle)) matches.add(episode);
    }
    return matches;
  }

  static String _labelFor(int episode, List<String> identifiers) {
    final index = episode - 1;
    final title = index < identifiers.length ? identifiers[index].trim() : '';
    return title.isEmpty ? '第$episode集' : title;
  }

  static bool _labelEqualsEpisode(String label, int number) {
    final match = _labelNumber.firstMatch(label.trim());
    if (match == null) return false;
    return int.tryParse(match.group(1)!) == number;
  }

  EpisodeSearch._();
}
