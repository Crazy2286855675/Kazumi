import 'package:hive_ce/hive.dart';
import 'package:kazumi/modules/bangumi/bangumi_item.dart';

part 'history_module.g.dart';

class HistoryEntryKind {
  static const String online = 'online';
  static const String offline = 'offline';

  static String normalize(String value) {
    return value == offline ? offline : online;
  }

  HistoryEntryKind._();
}

class PlaybackHistoryIdentity {
  const PlaybackHistoryIdentity({
    required this.bangumiItem,
    required this.pluginName,
    required this.episodeNumber,
    required this.episodeTitle,
    required this.road,
    required this.entryKind,
    this.onlineBangumiSrc = '',
    this.episodePageUrl = '',
    this.roadName = '',
  });

  final BangumiItem bangumiItem;
  final String pluginName;
  final int episodeNumber;
  final String episodeTitle;
  final int road;
  final String entryKind;
  final String onlineBangumiSrc;
  final String episodePageUrl;
  final String roadName;

  bool get canRecord => pluginName.isNotEmpty && episodeNumber > 0;

  factory PlaybackHistoryIdentity.online({
    required BangumiItem bangumiItem,
    required String pluginName,
    required int episodeNumber,
    required String episodeTitle,
    required int road,
    required String onlineBangumiSrc,
    required String episodePageUrl,
    String roadName = '',
  }) {
    return PlaybackHistoryIdentity(
      bangumiItem: bangumiItem,
      pluginName: pluginName,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      road: road,
      entryKind: HistoryEntryKind.online,
      onlineBangumiSrc: onlineBangumiSrc,
      episodePageUrl: episodePageUrl,
      roadName: roadName,
    );
  }

  factory PlaybackHistoryIdentity.offline({
    required BangumiItem bangumiItem,
    required String pluginName,
    required int episodeNumber,
    required String episodeTitle,
    required int road,
    required String episodePageUrl,
    String roadName = '',
  }) {
    return PlaybackHistoryIdentity(
      bangumiItem: bangumiItem,
      pluginName: pluginName,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      road: road,
      entryKind: HistoryEntryKind.offline,
      episodePageUrl: episodePageUrl,
      roadName: roadName,
    );
  }
}

@HiveType(typeId: 1)
class History {
  @HiveField(0)
  Map<int, Progress> progresses = {};

  @HiveField(1)
  int lastWatchEpisode;

  @HiveField(2)
  String adapterName;

  @HiveField(3)
  BangumiItem bangumiItem;

  @HiveField(4)
  DateTime lastWatchTime;

  @HiveField(5)
  String lastSrc;

  @HiveField(6, defaultValue: '')
  String lastWatchEpisodeName;

  @HiveField(7, defaultValue: HistoryEntryKind.online)
  String entryKind;

  @HiveField(8, defaultValue: '')
  String episodePageUrl;

  @HiveField(9, defaultValue: '')
  String lastRoadName;

  String get key => scopedKey(adapterName, bangumiItem, entryKind);

  /// Road title when one was recorded; otherwise the plugin name.
  String get playbackSourceName {
    final road = lastRoadName.trim();
    return road.isNotEmpty ? road : adapterName;
  }

  String timelinePlaybackSummary() {
    final position = formatWatchPosition(
      progresses[lastWatchEpisode]?.progress,
    );
    return [
      '第 $lastWatchEpisode 集',
      if (playbackSourceName.isNotEmpty) playbackSourceName,
      if (position.isNotEmpty) '看到 $position',
    ].join(' · ');
  }

  History(
    this.bangumiItem,
    this.lastWatchEpisode,
    this.adapterName,
    this.lastWatchTime,
    this.lastSrc,
    this.lastWatchEpisodeName, {
    this.entryKind = HistoryEntryKind.online,
    this.episodePageUrl = '',
    this.lastRoadName = '',
  });

  static String legacyKey(String n, BangumiItem s) => n + s.id.toString();

  static String scopedKey(String n, BangumiItem s, String entryKind) {
    return '${legacyKey(n, s)}::${HistoryEntryKind.normalize(entryKind)}';
  }

  static String getKey(
    String n,
    BangumiItem s, {
    String entryKind = HistoryEntryKind.online,
  }) {
    return scopedKey(n, s, entryKind);
  }

  @override
  String toString() {
    return 'Adapter: $adapterName, anime: ${bangumiItem.name}';
  }
}

@HiveType(typeId: 2)
class Progress {
  @HiveField(0)
  int episode;

  @HiveField(1)
  int road;

  @HiveField(2)
  int _progressInMilli;

  @HiveField(3, defaultValue: 0)
  int updatedAtMs;

  Duration get progress => Duration(milliseconds: _progressInMilli);

  set progress(Duration d) => _progressInMilli = d.inMilliseconds;

  Progress(
    this.episode,
    this.road,
    this._progressInMilli, {
    this.updatedAtMs = 0,
  });

  int effectiveUpdatedAtMs(DateTime fallback) {
    return updatedAtMs > 0 ? updatedAtMs : fallback.millisecondsSinceEpoch;
  }

  @override
  String toString() {
    return 'Episode ${episode.toString()}, progress $progress';
  }
}

/// `mm:ss`, or `h:mm:ss` once the position passes an hour. Empty at zero.
String formatWatchPosition(Duration? progress) {
  if (progress == null || progress.inSeconds <= 0) return '';
  final seconds = (progress.inSeconds % 60).toString().padLeft(2, '0');
  final minutes = (progress.inMinutes % 60).toString().padLeft(2, '0');
  if (progress.inHours > 0) {
    return '${progress.inHours}:$minutes:$seconds';
  }
  return '${progress.inMinutes}:$seconds';
}
