import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../content/models.dart';
import '../core/app_update.dart' show AppUpdateChecker, newInstallId;
import '../data/database.dart';
import '../online/api.dart';
import '../online/online_providers.dart' show serverUrlProvider;
import '../providers.dart';

/// Question de compréhension rédigée par IA (banque du serveur, un chapitre à la fois).
///
/// Son identifiant commence par [AiBank.idPrefix] (« gen-… ») : comme les
/// questions tirées du texte, elle n'entre pas dans la révision espacée — elle
/// peut être corrigée ou retirée côté serveur.
class AiChoiceQuestion extends ChoiceQuestion {
  const AiChoiceQuestion({
    required super.id,
    required super.prompt,
    required super.explain,
    required super.ref,
    required super.fr,
    required super.en,
    required super.answer,
    required this.reviewed,
  });

  /// Relue par une personne côté serveur ; sinon elle est affichée « non relue ».
  final bool reviewed;
}

class AiBank {
  static const idPrefix = 'gen-ai-';

  /// Chapitres par appel de lecture (limite du serveur : 200).
  static const chunk = 150;

  static String code(int book, int chapter) => '$book:$chapter';

  /// Lit une question servie par le serveur. Tout ce qui n'a pas exactement la
  /// forme attendue est ignoré (null) : une réponse abîmée ne casse pas un quiz.
  static AiChoiceQuestion? parseQuestion(Object? json, {int? book, int? chapter}) {
    if (json is! Map) return null;
    try {
      final j = json.cast<String, dynamic>();
      final id = j['id'];
      if (id is! String || !id.startsWith(idPrefix) || j['kind'] != 'choice') return null;
      final q = Question.parse(j);
      if (q is! ChoiceQuestion || q.fr.length != 4) return null;
      if (book != null && (q.ref.book != book || q.ref.startChapter != chapter)) return null;
      final texts = [q.prompt.fr, q.prompt.en, q.explain.fr, q.explain.en, ...q.fr, ...q.en];
      if (texts.any((t) => t.trim().isEmpty)) return null;
      if (q.fr.toSet().length != 4 || q.en.toSet().length != 4) return null;
      return AiChoiceQuestion(
        id: q.id,
        prompt: q.prompt,
        explain: q.explain,
        ref: q.ref,
        fr: q.fr,
        en: q.en,
        answer: q.answer,
        reviewed: j['reviewed'] == true,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Ce que le serveur dit d'un chapitre.
enum AiChapterState {
  /// Pas encore dans la banque : on peut le demander.
  none,

  /// Demandé, rédaction à venir ou en cours.
  preparing,

  /// Questions disponibles.
  ready,

  /// Rédigé, mais aucune question n'a passé les contrôles (listes, généalogies…).
  empty,

  /// Le service n'a pas répondu : on peut redemander.
  failed;

  static AiChapterState parse(Object? raw) => switch (raw) {
    'ready' => ready,
    'queued' || 'pending' => preparing,
    'empty' => empty,
    'failed' => failed,
    _ => none,
  };

  bool get canRequest => this == none || this == failed;
}

class AiQuota {
  const AiQuota({required this.enabled, required this.remaining, required this.daily, this.limited = ''});

  /// Le serveur propose-t-il les questions rédigées par IA ?
  final bool enabled;
  final int remaining;
  final int daily;

  /// « server_quota », « blocked » ou vide.
  final String limited;

  static AiQuota parse(Object? json) {
    final j = json is Map ? json : const {};
    int n(Object? v) => v is num ? v.toInt() : 0;
    return AiQuota(
      enabled: j['enabled'] == true,
      remaining: n(j['remaining']),
      daily: n(j['daily']),
      limited: j['limited'] is String ? j['limited'] as String : '',
    );
  }
}

/// État de la banque pour un ensemble de chapitres, après une lecture du serveur.
class AiBankStatus {
  const AiBankStatus(this.states, this.quota);

  final Map<String, AiChapterState> states;
  final AiQuota quota;

  int count(AiChapterState s) => states.values.where((v) => v == s).length;

  List<String> get requestable => [
    for (final e in states.entries)
      if (e.value.canRequest) e.key,
  ];
}

/// Cache hors ligne des chapitres de la banque (table `ai_chapters`).
class AiBankRepository {
  AiBankRepository(this.db);

  final AppDatabase db;

  Future<Map<String, int>> revisions() async => {
    for (final r in await db.select(db.aiChapters).get()) AiBank.code(r.book, r.chapter): r.rev,
  };

  Future<void> store(int book, int chapter, int rev, List<Object?> questions) => db
      .into(db.aiChapters)
      .insertOnConflictUpdate(
        AiChaptersCompanion.insert(book: book, chapter: chapter, rev: rev, questions: jsonEncode(questions)),
      );

  Future<void> remove(int book, int chapter) =>
      (db.delete(db.aiChapters)..where((t) => t.book.equals(book) & t.chapter.equals(chapter))).go();

  Future<void> clear() => db.delete(db.aiChapters).go();

  /// Questions gardées sur l'appareil pour les livres donnés (tous si null).
  Future<List<AiChoiceQuestion>> questions({Set<int>? books}) async {
    final query = db.select(db.aiChapters);
    if (books != null) query.where((t) => t.book.isIn(books));
    final out = <AiChoiceQuestion>[];
    for (final row in await query.get()) {
      Object? decoded;
      try {
        decoded = jsonDecode(row.questions);
      } on FormatException {
        continue;
      }
      if (decoded is! List) continue;
      for (final item in decoded) {
        final q = AiBank.parseQuestion(item, book: row.book, chapter: row.chapter);
        if (q != null) out.add(q);
      }
    }
    return out;
  }

  /// Retire une question du cache (signalée et retirée par le serveur).
  Future<void> dropQuestion(String id) async {
    for (final row in await db.select(db.aiChapters).get()) {
      Object? decoded;
      try {
        decoded = jsonDecode(row.questions);
      } on FormatException {
        continue;
      }
      if (decoded is! List || !decoded.any((q) => q is Map && q['id'] == id)) continue;
      final kept = [
        for (final q in decoded)
          if (!(q is Map && q['id'] == id)) q,
      ];
      await (db.update(db.aiChapters)..where((t) => t.book.equals(row.book) & t.chapter.equals(row.chapter))).write(
        AiChaptersCompanion(questions: Value(jsonEncode(kept))),
      );
    }
  }
}

/// Échanges avec le serveur. L'application s'y présente par son identifiant
/// d'installation (anonyme, le même que pour les mises à jour).
class AiBankService {
  AiBankService({required this.api, required this.repo, required this.deviceId});

  final ApiClient api;
  final AiBankRepository repo;
  final Future<String?> Function() deviceId;

  /// Lit l'état des chapitres [codes] et met le cache à jour. Lève [ApiException] sans réseau.
  Future<AiBankStatus> sync(List<String> codes) async {
    final device = await deviceId();
    final known = await repo.revisions();
    final states = <String, AiChapterState>{};
    var quota = const AiQuota(enabled: false, remaining: 0, daily: 0);
    for (var i = 0; i < codes.length || i == 0; i += AiBank.chunk) {
      final part = codes.skip(i).take(AiBank.chunk).toList();
      final result = await api.read('/ai/bank', {
        'chapters': part,
        'known': {
          for (final c in part)
            if (known.containsKey(c)) c: known[c],
        },
        'device': ?device,
      });
      quota = AiQuota.parse(result['quota']);
      for (final item in (result['chapters'] as List? ?? const [])) {
        if (item is Map) states[item['code'].toString()] = await _absorb(item, known);
      }
    }
    return AiBankStatus(states, quota);
  }

  /// Demande la rédaction d'un chapitre (quota gratuit du jour).
  Future<(AiChapterState, AiQuota)> request(String code) async {
    final device = await deviceId();
    if (device == null) throw ApiException('AI_BAD_DEVICE', '');
    final result = await api.write('/ai/request', {'device': device, 'chapter': code});
    final chapter = result['chapter'];
    final state = chapter is Map ? await _absorb(chapter, await repo.revisions()) : AiChapterState.none;
    return (state, AiQuota.parse(result['quota']));
  }

  /// Signale une question ; renvoie vrai si le serveur l'a retirée.
  Future<bool> report(String questionId, String reason, String note) async {
    final device = await deviceId();
    if (device == null) throw ApiException('AI_BAD_DEVICE', '');
    final result = await api.write('/ai/report', {
      'device': device,
      'question': questionId,
      'reason': reason,
      'note': note.trim(),
    });
    final withdrawn = result['withdrawn'] == true;
    if (withdrawn) await repo.dropQuestion(questionId);
    return withdrawn;
  }

  Future<AiChapterState> _absorb(Map<dynamic, dynamic> item, Map<String, int> known) async {
    final state = AiChapterState.parse(item['state']);
    final parts = item['code'].toString().split(':');
    final book = parts.length == 2 ? int.tryParse(parts[0]) : null;
    final chapter = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (book == null || chapter == null) return state;
    final questions = item['questions'];
    final rev = item['rev'];
    if (state == AiChapterState.ready && questions is List && rev is int) {
      await repo.store(book, chapter, rev, questions);
    } else if (state != AiChapterState.ready && known.containsKey(item['code'].toString())) {
      // Chapitre remis en rédaction ou vidé côté serveur : on garde ce qu'on a tant
      // que le serveur ne sert pas mieux, sauf s'il n'y a plus rien à servir.
      if (state == AiChapterState.empty) await repo.remove(book, chapter);
    }
    return state;
  }
}

/// Identifiant d'installation (celui du contrôle des mises à jour, créé au besoin).
Future<String?> aiDeviceId() async {
  try {
    final prefs = SharedPreferencesAsync();
    final known = await prefs.getString(AppUpdateChecker.keyInstallId);
    if (known != null && RegExp(r'^[0-9a-f-]{16,64}$').hasMatch(known)) return known;
    final fresh = newInstallId();
    await prefs.setString(AppUpdateChecker.keyInstallId, fresh);
    return fresh;
  } catch (_) {
    return null;
  }
}

final aiBankRepoProvider = Provider((ref) => AiBankRepository(ref.watch(databaseProvider)));

final aiDeviceIdProvider = Provider<Future<String?> Function()>((ref) => aiDeviceId);

final aiBankServiceProvider = Provider<AiBankService>((ref) {
  return AiBankService(
    api: ApiClient(baseUrl: ref.watch(serverUrlProvider), timeout: const Duration(seconds: 20)),
    repo: ref.watch(aiBankRepoProvider),
    deviceId: ref.watch(aiDeviceIdProvider),
  );
});
