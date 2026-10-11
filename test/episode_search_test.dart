import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/pages/video/episode_search.dart';

void main() {
  const titles = ['东海篇', '阿拉巴斯坦', '空岛'];

  test('parses an episode number and ignores titles', () {
    expect(EpisodeSearch.parseEpisodeNumber('123'), 123);
    expect(EpisodeSearch.parseEpisodeNumber('第123集'), 123);
    expect(EpisodeSearch.parseEpisodeNumber('第 12 话'), 12);
    expect(EpisodeSearch.parseEpisodeNumber('第8話'), 8);
    expect(EpisodeSearch.parseEpisodeNumber('  7  '), 7);
    expect(EpisodeSearch.parseEpisodeNumber('东海'), isNull);
    expect(EpisodeSearch.parseEpisodeNumber('第123集 特别篇'), isNull);
  });

  test('returns the requested episode, or nothing when it is out of range', () {
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '2',
        count: titles.length,
        identifiers: titles,
      ),
      [2],
    );
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '第3集',
        count: titles.length,
        identifiers: titles,
      ),
      [3],
    );
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '1000',
        count: titles.length,
        identifiers: titles,
      ),
      isEmpty,
    );
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '0',
        count: titles.length,
        identifiers: titles,
      ),
      isEmpty,
    );
  });

  test('numeric search matches the displayed episode number', () {
    final reversed = List.generate(1180, (index) => '${1180 - index}');

    expect(
      EpisodeSearch.visibleEpisodes(
        query: '302',
        count: reversed.length,
        identifiers: reversed,
      ),
      [879],
    );
    expect(reversed[878], '302');
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '879',
        count: reversed.length,
        identifiers: reversed,
      ),
      [302],
    );
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '第302集',
        count: reversed.length,
        identifiers: reversed,
      ),
      [879],
    );
  });

  test('filters by title and returns every episode for an empty query', () {
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '阿拉',
        count: titles.length,
        identifiers: titles,
      ),
      [2],
    );
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '',
        count: titles.length,
        identifiers: titles,
      ),
      [1, 2, 3],
    );
    expect(
      EpisodeSearch.visibleEpisodes(
        query: '不存在',
        count: titles.length,
        identifiers: titles,
      ),
      isEmpty,
    );
  });
}
