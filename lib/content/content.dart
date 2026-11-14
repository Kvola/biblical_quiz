import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

/// Tout le contenu éditorial, chargé une fois au démarrage.
class Content {
  Content(List<LearningPath> paths, this.books, [List<PathGroup> groups = const []])
    : paths = [...paths]..sort((a, b) => a.order.compareTo(b.order)),
      groups = [...groups]..sort((a, b) => a.order.compareTo(b.order)) {
    for (final p in this.paths) {
      for (final l in p.lessons) {
        _lessons[l.id] = l;
        for (final q in l.questions) {
          _questions[q.id] = (q, l.id);
        }
      }
    }
    for (final b in books) {
      for (final q in b.questions) {
        _questions[q.id] = (q, b.lessonId);
      }
    }
  }

  final List<LearningPath> paths;
  final List<BookInfo> books;

  /// Sections de l'onglet Parcours, dans l'ordre.
  final List<PathGroup> groups;
  final _lessons = <String, Lesson>{};
  final _questions = <String, (Question, String)>{};

  static const pathsDir = 'assets/content/paths/';
  static const booksAsset = 'assets/content/books.json';
  static const groupsAsset = 'assets/content/groups.json';

  static Future<Content> load(AssetBundle bundle) async {
    final manifest = await AssetManifest.loadFromAssetBundle(bundle);
    final files = manifest.listAssets().where((a) => a.startsWith(pathsDir) && a.endsWith('.json')).toList()..sort();
    final paths = <LearningPath>[];
    for (final f in files) {
      try {
        paths.add(LearningPath.parse(jsonDecode(await bundle.loadString(f)) as Map<String, dynamic>));
      } catch (e) {
        throw FormatException('$f : $e');
      }
    }
    final booksJson = jsonDecode(await bundle.loadString(booksAsset)) as List;
    final groupsJson = jsonDecode(await bundle.loadString(groupsAsset)) as List;
    return Content(
      paths,
      booksJson.cast<Map<String, dynamic>>().map(BookInfo.parse).toList(),
      groupsJson.cast<Map<String, dynamic>>().map(PathGroup.parse).toList(),
    );
  }

  Lesson? lesson(String id) => _lessons[id];

  LearningPath? path(String id) {
    for (final p in paths) {
      if (p.id == id) return p;
    }
    return null;
  }

  BookInfo? book(int id) => id >= 1 && id <= books.length ? books[id - 1] : null;

  Question? question(String id) => _questions[id]?.$1;

  /// Leçon (ou fiche « book-N ») à laquelle appartient une question.
  String? lessonOfQuestion(String id) => _questions[id]?.$2;

  Iterable<Lesson> get allLessons => paths.expand((p) => p.lessons);

  /// Toutes les questions relues (leçons et fiches des livres).
  Iterable<Question> get allQuestions => _questions.values.map((e) => e.$1);

  int get questionCount => _questions.length;

  /// Parcours d'un groupe, dans l'ordre. Les parcours sans groupe connu sont
  /// rangés dans le dernier groupe (jamais perdus).
  List<LearningPath> pathsOf(PathGroup group) {
    final known = {for (final g in groups) g.id};
    final last = groups.isEmpty ? null : groups.last.id;
    return [
      for (final p in paths)
        if (p.group == group.id || (!known.contains(p.group) && group.id == last)) p,
    ];
  }

  /// Première leçon non terminée d'un parcours, ou null s'il est fini.
  Lesson? nextInPath(String pathId, Set<String> completed) {
    final p = path(pathId);
    if (p == null) return null;
    for (final l in p.lessons) {
      if (!completed.contains(l.id)) return l;
    }
    return null;
  }

  /// Leçon suivante dans le même parcours.
  Lesson? after(Lesson lesson) {
    final ls = path(lesson.pathId)?.lessons ?? const [];
    final i = ls.indexWhere((l) => l.id == lesson.id);
    return i >= 0 && i + 1 < ls.length ? ls[i + 1] : null;
  }

  /// Parcours à suivre après [pathId] dans son groupe : le premier parcours
  /// non terminé qui le suit, sinon le premier non terminé du groupe
  /// (ex. « Le chemin de la foi », à suivre dans l'ordre). Null si le groupe
  /// est fini ou si le parcours n'a pas de groupe connu.
  LearningPath? nextPathInGroup(String pathId, Set<String> completed) {
    final p = path(pathId);
    if (p == null || !groups.any((g) => g.id == p.group)) return null;
    final group = groups.firstWhere((g) => g.id == p.group);
    final siblings = pathsOf(group);
    final i = siblings.indexWhere((x) => x.id == pathId);
    for (final x in [...siblings.skip(i + 1), ...siblings.take(i)]) {
      if (nextInPath(x.id, completed) != null) return x;
    }
    return null;
  }

  /// Ce qu'on propose de faire ensuite : la suite du dernier parcours ouvert ;
  /// s'il est fini, le parcours suivant de son groupe ; sinon le premier
  /// parcours pas encore terminé.
  Lesson? suggestedNext(Set<String> completed, String? lastPathId) {
    if (lastPathId != null) {
      final n = nextInPath(lastPathId, completed);
      if (n != null) return n;
      final p = nextPathInGroup(lastPathId, completed);
      if (p != null) return nextInPath(p.id, completed);
    }
    for (final p in paths) {
      final n = nextInPath(p.id, completed);
      if (n != null) return n;
    }
    return null;
  }
}
