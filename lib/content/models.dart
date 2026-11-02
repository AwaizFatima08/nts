typedef Json = Map<String, Object?>;

List<T> _list<T>(Object? raw, T Function(Json) read) => [
  for (final item in raw! as List<Object?>) read(item! as Json),
];

/// One multiple-choice question from the bank.
class Question {
  const Question({
    required this.id,
    required this.section,
    required this.topic,
    required this.isPractice,
    required this.level,
    required this.stem,
    required this.options,
    required this.answer,
    required this.explanation,
    this.setId,
    this.table,
  });

  factory Question.fromJson(Json json, String section) => Question(
    id: json['id']! as String,
    section: section,
    topic: json['tp']! as String,
    isPractice: json['pl'] == 'p',
    level: json['lv']! as int,
    stem: json['s']! as String,
    options: (json['o']! as List<Object?>).cast<String>(),
    answer: json['a']! as int,
    explanation: json['e']! as String,
    setId: json['st'] as String?,
    table: switch (json['tb']) {
      final List<Object?> rows => [for (final row in rows) (row! as List<Object?>).cast<String>()],
      _ => null,
    },
  );

  final String id;
  final String section;
  final String topic;
  final bool isPractice;
  final int level;
  final String stem;
  final List<String> options;
  final int answer;
  final String explanation;
  final String? setId;
  final List<List<String>>? table;
}

/// A passage or scenario shared by several questions.
class QuestionSet {
  const QuestionSet({required this.title, required this.text});

  factory QuestionSet.fromJson(Json json) =>
      QuestionSet(title: json['t']! as String, text: json['x']! as String);

  final String title;
  final String text;
}

class TopicInfo {
  const TopicInfo({required this.key, required this.title, required this.practiceCount});

  factory TopicInfo.fromJson(Json json) => TopicInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    practiceCount: json['practice']! as int,
  );

  final String key;
  final String title;
  final int practiceCount;
}

class SectionInfo {
  const SectionInfo({required this.key, required this.title, required this.topics});

  factory SectionInfo.fromJson(Json json) => SectionInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    topics: _list(json['topics'], TopicInfo.fromJson),
  );

  final String key;
  final String title;
  final List<TopicInfo> topics;
}

class StreamInfo {
  const StreamInfo({required this.key, required this.title});

  factory StreamInfo.fromJson(Json json) =>
      StreamInfo(key: json['key']! as String, title: json['title']! as String);

  final String key;
  final String title;
}

class ModeInfo {
  const ModeInfo({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.minutes,
    required this.questionCount,
    required this.streams,
  });

  factory ModeInfo.fromJson(Json json) => ModeInfo(
    key: json['key']! as String,
    title: json['title']! as String,
    subtitle: json['subtitle']! as String,
    minutes: json['minutes']! as int,
    questionCount: json['questions']! as int,
    streams: _list(json['streams'], StreamInfo.fromJson),
  );

  final String key;
  final String title;
  final String subtitle;
  final int minutes;
  final int questionCount;
  final List<StreamInfo> streams;
}

class Catalog {
  const Catalog({required this.sections, required this.modes});

  factory Catalog.fromJson(Json json) => Catalog(
    sections: _list(json['sections'], SectionInfo.fromJson),
    modes: _list(json['modes'], ModeInfo.fromJson),
  );

  final List<SectionInfo> sections;
  final List<ModeInfo> modes;

  /// Title of a topic, falling back to its key for retired content.
  String topicTitle(String section, String topic) {
    for (final candidate in sections) {
      if (candidate.key != section) continue;
      for (final info in candidate.topics) {
        if (info.key == topic) return info.title;
      }
    }
    return topic;
  }
}

class PaperSection {
  const PaperSection({required this.key, required this.title, required this.itemIds, this.alt});

  factory PaperSection.fromJson(Json json) => PaperSection(
    key: json['key']! as String,
    title: json['title']! as String,
    itemIds: (json['items']! as List<Object?>).cast<String>(),
    alt: switch (json['alt']) {
      final Json alt => PaperSection.fromJson(alt),
      _ => null,
    },
  );

  final String key;
  final String title;
  final List<String> itemIds;

  /// The Ethics section offered to non-Muslim candidates in place of Islamic Studies.
  final PaperSection? alt;
}

/// One full-length test.
class Paper {
  const Paper({
    required this.id,
    required this.mode,
    required this.stream,
    required this.number,
    required this.title,
    required this.minutes,
    required this.sections,
  });

  factory Paper.fromJson(Json json) => Paper(
    id: json['id']! as String,
    mode: json['mode']! as String,
    stream: json['stream']! as String,
    number: json['number']! as int,
    title: json['title']! as String,
    minutes: json['minutes']! as int,
    sections: _list(json['sections'], PaperSection.fromJson),
  );

  final String id;
  final String mode;
  final String stream;
  final int number;
  final String title;
  final int minutes;
  final List<PaperSection> sections;

  /// The sections a candidate sits, honouring the Ethics choice.
  List<PaperSection> sectionsFor({required bool useEthics}) => [
    for (final section in sections)
      if (useEthics && section.alt != null) section.alt! else section,
  ];
}

/// One article of the Guidance section. Body lines: `## heading`, `- bullet`, or a paragraph.
class GuideArticle {
  const GuideArticle({
    required this.id,
    required this.group,
    required this.title,
    required this.lines,
  });

  factory GuideArticle.fromJson(Json json) => GuideArticle(
    id: json['id']! as String,
    group: json['group']! as String,
    title: json['title']! as String,
    lines: (json['lines']! as List<Object?>).cast<String>(),
  );

  final String id;
  final String group;
  final String title;
  final List<String> lines;
}
