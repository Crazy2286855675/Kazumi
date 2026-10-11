import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazumi/bean/card/bangumi_timeline_card.dart';
import 'package:kazumi/modules/collect/collect_type.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';
import 'package:kazumi/modules/bangumi/bangumi_tag.dart';
import 'package:kazumi/modules/history/history_module.dart';
import 'package:kazumi/modules/roads/road_module.dart';
import 'package:kazumi/pages/history/history_record_tile.dart';
import 'package:kazumi/pages/video/episode_selection_panel.dart';

void main() {
  testWidgets('history row shows the episode number, road, and position', (
    tester,
  ) async {
    final history = History(
      _item(1),
      12,
      'plugin',
      DateTime(2026, 10, 11, 8, 30),
      'https://example.com/source',
      '空岛篇',
      lastRoadName: '线路A',
    );
    history.progresses[12] = Progress(12, 1, 95000);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryRecordTile(
            history: history,
            onPlay: () {},
            onDetails: () {},
            onDelete: () async {},
            collectType: CollectType.watching,
            onChangeCollect: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('第 12 话 · 空岛篇'), findsOneWidget);
    expect(find.textContaining('线路A'), findsOneWidget);
    expect(find.text('看到 1:35'), findsOneWidget);
  });

  testWidgets('timeline card shows the last second and continues playback', (
    tester,
  ) async {
    var continued = false;
    var openedDetails = false;
    final history = History(
      _item(1),
      12,
      'plugin',
      DateTime(2026, 10, 11),
      'https://example.com/source',
      '空岛篇',
      lastRoadName: '线路A',
    );
    history.progresses[12] = Progress(12, 1, 95000);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BangumiTimelineCard(
            bangumiItem: _item(1),
            showRating: false,
            playbackHistory: history,
            onContinue: () => continued = true,
            onTap: () => openedDetails = true,
          ),
        ),
      ),
    );

    expect(find.text('第 12 集 · 线路A · 看到 1:35'), findsOneWidget);
    await tester.tap(find.byTooltip('继续播放'));
    await tester.pump();
    expect(continued, isTrue);
    expect(openedDetails, isFalse);
  });

  testWidgets('episode search jumps to a numbered episode in a long list', (
    tester,
  ) async {
    final selected = <int>[];
    final roads = [
      Road(
        name: '线路A',
        data: List.generate(1200, (index) => 'https://example/$index'),
        identifier: List.generate(1200, (index) {
          if (index == 121) return '空岛篇';
          return '第${index + 1}集';
        }),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EpisodeSelectionPanel(
            title: '海贼王',
            roads: roads,
            selectedRoad: 0,
            selectedEpisode: 1,
            downloads: const {},
            onEpisodeSelected: (episode, road) => selected.add(episode),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '第122集');
    await tester.pump();
    expect(find.text('空岛篇'), findsOneWidget);
    expect(find.text('第1集'), findsNothing);

    await tester.testTextInput.receiveAction(TextInputAction.go);
    await tester.pump();
    expect(selected, [122]);

    await tester.enterText(find.byType(TextField), '空岛');
    await tester.pump();
    expect(find.text('空岛篇'), findsOneWidget);
    expect(find.text('没有匹配的剧集'), findsNothing);

    await tester.enterText(find.byType(TextField), '10000');
    await tester.pump();
    expect(find.text('没有匹配的剧集'), findsOneWidget);
  });

  testWidgets(
    'numeric search follows the episode title when the list is reversed',
    (tester) async {
      const count = 1180;
      final selected = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EpisodeSelectionPanel(
              title: '航海王',
              roads: [
                Road(
                  name: '播放线路1',
                  data: List.generate(
                    count,
                    (index) => 'https://example/$index',
                  ),
                  identifier: List.generate(
                    count,
                    (index) => '${count - index}',
                  ),
                ),
              ],
              selectedRoad: 0,
              selectedEpisode: 1,
              downloads: const {},
              onEpisodeSelected: (episode, road) => selected.add(episode),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), '302');
      await tester.pump();
      expect(find.text('302'), findsWidgets);
      expect(find.text('879'), findsNothing);

      await tester.testTextInput.receiveAction(TextInputAction.go);
      await tester.pump();
      expect(selected, [879]);
    },
  );
}

BangumiItem _item(int id) {
  return BangumiItem(
    id: id,
    type: 2,
    name: 'One Piece',
    nameCn: '海贼王',
    summary: '',
    airDate: '2026-01-01',
    airWeekday: 4,
    rank: 0,
    images: const {
      'large': '',
      'common': '',
      'medium': '',
      'small': '',
      'grid': '',
    },
    tags: const <BangumiTag>[],
    alias: const [],
    ratingScore: 0,
    votes: 0,
    votesCount: const [],
    info: '1000话',
  );
}
