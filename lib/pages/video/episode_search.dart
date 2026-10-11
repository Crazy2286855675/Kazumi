/// Matches an episode query against a road's episode list.
class EpisodeSearch {
  static final _episodeNumber = RegExp(r'^(?:第\s*)?(\d+)\s*(?:集|话|話)?$');

  /// `123`, `第123集`, `第 123 话`. Returns null when the query is a title.
  static int? parseEpisodeNumber(String query) {
    final match = _episodeNumber.firstMatch(query.trim());
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  /// 1-based episode numbers to show for [query].
  ///
  /// An empty query returns every episode. A numeric query returns that
  /// episode when it exists, otherwise nothing. Any other query filters by
  /// title, falling back to `第N集`.
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
      return number >= 1 && number <= count ? [number] : const [];
    }
    final needle = trimmed.toLowerCase();
    final matches = <int>[];
    for (var episode = 1; episode <= count; episode++) {
      final index = episode - 1;
      final title = index < identifiers.length ? identifiers[index].trim() : '';
      final label = title.isEmpty ? '第$episode集' : title;
      if (label.toLowerCase().contains(needle) ||
          '第$episode集'.contains(trimmed)) {
        matches.add(episode);
      }
    }
    return matches;
  }

  EpisodeSearch._();
}
