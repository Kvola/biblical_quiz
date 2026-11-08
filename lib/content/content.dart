import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';

/// Tout le contenu éditorial, chargé une fois au démarrage.
class Content {
  Content(List<LearningPath> paths, this.books) : paths = [...paths]..sort((a, b) => a.order.compareTo(b.order)) {
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
  final _lessons = <String, Lesson>{};
  final _questions = <String, (Question, String)>{};

  static const pathsDir = 'assets/content/paths/';
  static const booksAsset = 'assets/content/books.json';

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
    return Content(paths, booksJson.cast<Map<String, dynamic>>().map(BookInfo.parse).toList());
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

  int get questionCount => _questions.length;

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

  /// Ce qu'on propose de faire ensuite : la suite du dernier parcours ouvert,
  /// sinon le premier parcours pas encore terminé.
  Lesson? suggestedNext(Set<String> completed, String? lastPathId) {
    if (lastPathId != null) {
      final n = nextInPath(lastPathId, completed);
      if (n != null) return n;
    }
    for (final p in paths) {
      final n = nextInPath(p.id, completed);
      if (n != null) return n;
    }
    return null;
  }
}
