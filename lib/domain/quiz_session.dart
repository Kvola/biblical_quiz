import 'dart:math';

import '../content/models.dart';

/// Une question telle qu'affichée : propositions éventuellement mélangées.
class PresentedQuestion {
  PresentedQuestion(this.question, this.order);

  final Question question;

  /// order[i] = indice, dans le contenu, de la proposition affichée en position i.
  final List<int> order;

  List<String> options(String lang) {
    final all = question.options(lang);
    return [for (final i in order) all[i]];
  }

  /// Position affichée de la bonne réponse.
  int get correctPosition => order.indexOf(question.correctIndex);
}

class AnswerRecord {
  const AnswerRecord(this.questionId, this.correct);

  final String questionId;
  final bool correct;
}

/// Déroulé d'un quiz : une question après l'autre, une seule réponse par
/// question, pas de retour en arrière. Logique pure, testée sans interface.
class QuizSession {
  QuizSession(List<Question> questions, {Random? random, bool shuffleQuestions = false})
    : assert(questions.isNotEmpty) {
    final rnd = random ?? Random();
    final qs = [...questions];
    if (shuffleQuestions) qs.shuffle(rnd);
    _items = [
      for (final q in qs)
        PresentedQuestion(q, [for (var i = 0; i < q.options('fr').length; i++) i]..shuffleIf(q.shuffle, rnd)),
    ];
  }

  late final List<PresentedQuestion> _items;
  final _answers = <int, int>{}; // indice de question -> position choisie
  int _index = 0;

  int get length => _items.length;
  int get index => _index;
  PresentedQuestion get current => _items[_index];
  List<PresentedQuestion> get items => List.unmodifiable(_items);

  bool get isAnswered => _answers.containsKey(_index);
  int? get chosenPosition => _answers[_index];
  bool get isLast => _index == _items.length - 1;
  bool get isFinished => _answers.length == _items.length;

  /// Enregistre la réponse à la question courante. Renvoie vrai si elle est juste.
  /// Une deuxième réponse à la même question est ignorée (double appui).
  bool answer(int position) {
    final item = current;
    if (position < 0 || position >= item.order.length) {
      throw RangeError.index(position, item.order, 'position');
    }
    _answers.putIfAbsent(_index, () => position);
    return _answers[_index] == item.correctPosition;
  }

  /// Passe à la question suivante ; renvoie faux s'il n'y en a plus.
  bool next() {
    if (!isAnswered || isLast) return false;
    _index++;
    return true;
  }

  int get score => [
    for (final e in _answers.entries)
      if (e.value == _items[e.key].correctPosition) 1,
  ].length;

  List<AnswerRecord> get records => [
    for (final e in _answers.entries) AnswerRecord(_items[e.key].question.id, e.value == _items[e.key].correctPosition),
  ];

  List<Question> get missed => [
    for (final e in _answers.entries)
      if (e.value != _items[e.key].correctPosition) _items[e.key].question,
  ];
}

extension on List<int> {
  void shuffleIf(bool condition, Random rnd) {
    if (condition) shuffle(rnd);
  }
}
