import '../core/verse_ref.dart';

/// Texte bilingue du contenu.
class LText {
  const LText(this.fr, this.en);

  final String fr;
  final String en;

  String of(String lang) => lang == 'en' ? en : fr;

  static LText parse(Object? json, String field) {
    if (json is! Map || json['fr'] is! String || json['en'] is! String) {
      throw FormatException('« $field » : {fr, en} attendu');
    }
    return LText((json['fr'] as String).trim(), (json['en'] as String).trim());
  }
}

sealed class Question {
  const Question({required this.id, required this.prompt, required this.explain, required this.ref});

  final String id;
  final LText prompt;
  final LText explain;
  final VerseRef ref;

  /// Libellés des réponses dans l'ordre du contenu.
  List<String> options(String lang);

  /// Indice (dans l'ordre du contenu) de la bonne réponse.
  int get correctIndex;

  /// Un vrai/faux garde son ordre (Vrai, Faux) ; un choix multiple est mélangé.
  bool get shuffle;

  static Question parse(Map<String, dynamic> j) {
    final id = j['id'] as String;
    final prompt = LText.parse(j['q'], '$id.q');
    final explain = LText.parse(j['explain'], '$id.explain');
    final ref = VerseRef.parse(j['ref'] as String);
    switch (j['kind']) {
      case 'choice':
        final c = j['choices'] as Map<String, dynamic>;
        final fr = (c['fr'] as List).cast<String>();
        final en = (c['en'] as List).cast<String>();
        final answer = j['answer'] as int;
        if (fr.length != en.length || fr.length < 2 || answer < 0 || answer >= fr.length) {
          throw FormatException('$id : propositions incohérentes');
        }
        return ChoiceQuestion(id: id, prompt: prompt, explain: explain, ref: ref, fr: fr, en: en, answer: answer);
      case 'truefalse':
        return TrueFalseQuestion(id: id, prompt: prompt, explain: explain, ref: ref, answer: j['answer'] as bool);
      default:
        throw FormatException('$id : kind inconnu ${j['kind']}');
    }
  }
}

class ChoiceQuestion extends Question {
  const ChoiceQuestion({
    required super.id,
    required super.prompt,
    required super.explain,
    required super.ref,
    required this.fr,
    required this.en,
    required this.answer,
  });

  final List<String> fr;
  final List<String> en;
  final int answer;

  @override
  List<String> options(String lang) => lang == 'en' ? en : fr;

  @override
  int get correctIndex => answer;

  @override
  bool get shuffle => true;
}

class TrueFalseQuestion extends Question {
  const TrueFalseQuestion({
    required super.id,
    required super.prompt,
    required super.explain,
    required super.ref,
    required this.answer,
  });

  final bool answer;

  /// Les libellés « Vrai » / « Faux » viennent de la traduction de l'interface.
  @override
  List<String> options(String lang) => lang == 'en' ? const ['True', 'False'] : const ['Vrai', 'Faux'];

  @override
  int get correctIndex => answer ? 0 : 1;

  @override
  bool get shuffle => false;
}

class Lesson {
  const Lesson({
    required this.id,
    required this.pathId,
    required this.title,
    required this.passages,
    required this.intro,
    required this.keyVerse,
    required this.takeaway,
    required this.questions,
  });

  final String id;
  final String pathId;
  final LText title;
  final List<VerseRef> passages;
  final LText intro;
  final VerseRef keyVerse;
  final LText takeaway;
  final List<Question> questions;

  static Lesson parse(Map<String, dynamic> j, String pathId) => Lesson(
    id: j['id'] as String,
    pathId: pathId,
    title: LText.parse(j['title'], 'title'),
    passages: (j['passages'] as List).cast<String>().map(VerseRef.parse).toList(),
    intro: LText.parse(j['intro'], 'intro'),
    keyVerse: VerseRef.parse(j['keyVerse'] as String),
    takeaway: LText.parse(j['takeaway'], 'takeaway'),
    questions: (j['questions'] as List).cast<Map<String, dynamic>>().map(Question.parse).toList(),
  );
}

class LearningPath {
  const LearningPath({
    required this.id,
    required this.order,
    required this.icon,
    required this.title,
    required this.description,
    required this.lessons,
  });

  final String id;
  final int order;
  final String icon;
  final LText title;
  final LText description;
  final List<Lesson> lessons;

  static LearningPath parse(Map<String, dynamic> j) {
    final id = j['id'] as String;
    return LearningPath(
      id: id,
      order: j['order'] as int,
      icon: j['icon'] as String,
      title: LText.parse(j['title'], 'title'),
      description: LText.parse(j['description'], 'description'),
      lessons: (j['lessons'] as List).cast<Map<String, dynamic>>().map((l) => Lesson.parse(l, id)).toList(),
    );
  }
}

class BookInfoText {
  const BookInfoText({required this.author, required this.period, required this.summary, required this.themes});

  final String author;
  final String period;
  final String summary;
  final List<String> themes;

  static BookInfoText parse(Map<String, dynamic> j) => BookInfoText(
    author: (j['author'] as String).trim(),
    period: (j['period'] as String).trim(),
    summary: (j['summary'] as String).trim(),
    themes: (j['themes'] as List).cast<String>(),
  );
}

/// Fiche d'un livre de la Bible, avec ses quelques questions.
class BookInfo {
  const BookInfo({required this.id, required this.keyVerse, required this.fr, required this.en, required this.questions});

  final int id;
  final VerseRef keyVerse;
  final BookInfoText fr;
  final BookInfoText en;
  final List<Question> questions;

  BookInfoText of(String lang) => lang == 'en' ? en : fr;

  /// Identifiant de « leçon » pour la progression (même table que les leçons).
  String get lessonId => 'book-$id';

  static BookInfo parse(Map<String, dynamic> j) => BookInfo(
    id: j['id'] as int,
    keyVerse: VerseRef.parse(j['keyVerse'] as String),
    fr: BookInfoText.parse(j['fr'] as Map<String, dynamic>),
    en: BookInfoText.parse(j['en'] as Map<String, dynamic>),
    questions: (j['questions'] as List).cast<Map<String, dynamic>>().map(Question.parse).toList(),
  );
}
