import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:biblical_quiz/ai/ai_bank.dart';
import 'package:biblical_quiz/bible/bible.dart';
import 'package:biblical_quiz/content/content.dart';
import 'package:biblical_quiz/content/models.dart';
import 'package:biblical_quiz/core/theme.dart';
import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/data/progress_repository.dart';
import 'package:biblical_quiz/domain/quiz_session.dart';
import 'package:biblical_quiz/domain/reading_quiz.dart';
import 'package:biblical_quiz/l10n/gen/app_localizations.dart';
import 'package:biblical_quiz/online/api.dart';
import 'package:biblical_quiz/providers.dart';
import 'package:biblical_quiz/ui/quiz/quiz_view.dart';
import 'package:biblical_quiz/ui/reading/ai_card.dart';
import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'content_test.dart' show loadBible, loadContent;

/// Une question telle que le serveur la sert (Philémon 1 : aucun parcours ne s'y trouve… ou presque).
Map<String, dynamic> served(int n, {String ref = '57:1:10', bool reviewed = false}) => {
  'id': 'gen-ai-$n',
  'kind': 'choice',
  'q': {'fr': 'Question $n ?', 'en': 'Question $n?'},
  'choices': {
    'fr': ['a$n', 'b$n', 'c$n', 'd$n'],
    'en': ['e$n', 'f$n', 'g$n', 'h$n'],
  },
  'answer': 2,
  'explain': {'fr': 'Parce que.', 'en': 'Because.'},
  'ref': ref,
  'reviewed': reviewed,
};

/// Faux serveur : état des chapitres en mémoire, comme `controllers/ai.py`.
class FakeServer {
  final chapters = <String, Map<String, dynamic>>{};
  final calls = <(String, Map<String, dynamic>)>[];
  int remaining = 3;
  bool enabled = true;
  bool down = false;
  String? refuse;

  Map<String, dynamic> get quota => {'enabled': enabled, 'remaining': remaining, 'daily': 3, 'limited': ''};

  void ready(String code, int rev, List<Map<String, dynamic>> questions) =>
      chapters[code] = {'code': code, 'state': 'ready', 'rev': rev, 'questions': questions};

  Future<http.Response> handle(http.Request request) async {
    if (down) throw http.ClientException('hors ligne');
    final params = (jsonDecode(request.body) as Map)['params'] as Map<String, dynamic>;
    final path = request.url.path.split('/api/v1').last;
    calls.add((path, params));
    Map<String, dynamic> result;
    switch (path) {
      case '/ai/bank':
        final known = (params['known'] as Map?) ?? const {};
        result = {
          'success': true,
          'quota': quota,
          'chapters': [
            for (final code in (params['chapters'] as List).cast<String>())
              if (chapters[code] case final c?)
                {...c, if (known[code] == c['rev']) 'questions': null}..removeWhere((k, v) => v == null)
              else
                {'code': code, 'state': 'none', 'rev': 0},
          ],
        };
      case '/ai/request':
        if (refuse != null) {
          result = {'success': false, 'error': {'code': refuse, 'message': 'refus'}};
        } else {
          final code = params['chapter'] as String;
          chapters.putIfAbsent(code, () {
            remaining--;
            return {'code': code, 'state': 'queued', 'rev': 0};
          });
          result = {'success': true, 'chapter': chapters[code], 'quota': quota};
        }
      case '/ai/report':
        result = {'success': true, 'withdrawn': params['reason'] == 'wrong'};
      default:
        return http.Response('', 404);
    }
    return http.Response.bytes(utf8.encode(jsonEncode({'jsonrpc': '2.0', 'result': result})), 200);
  }

  AiBankService service(AiBankRepository repo) => AiBankService(
    api: ApiClient(baseUrl: 'http://test', httpClient: MockClient(handle)),
    repo: repo,
    deviceId: () async => '0123456789abcdef0123',
  );
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('lecture d’une question servie', () {
    test('forme correcte', () {
      final q = AiBank.parseQuestion(served(7, reviewed: true))!;
      expect((q.id, q.reviewed, q.answer, q.ref.code), ('gen-ai-7', true, 2, '57:1:10'));
      expect(q.shuffle, isTrue);
    });

    test('toute forme douteuse est ignorée, sans erreur', () {
      final bad = <Object?>[
        null,
        'x',
        {...served(1), 'id': 'story-creation-1'}, // ne doit jamais remplacer une question du contenu
        {...served(1), 'kind': 'truefalse', 'answer': true},
        {...served(1), 'answer': 9},
        {...served(1), 'ref': 'nulle part'},
        {...served(1), 'choices': {'fr': ['a', 'b', 'c'], 'en': ['e', 'f', 'g']}},
        {...served(1), 'choices': {'fr': ['a', 'a', 'c', 'd'], 'en': ['e', 'f', 'g', 'h']}},
        {...served(1), 'q': {'fr': '  ', 'en': 'Q?'}},
        {...served(1)}..remove('explain'),
      ];
      for (final b in bad) {
        expect(AiBank.parseQuestion(b), isNull, reason: '$b');
      }
      // Une question rangée dans le mauvais chapitre est ignorée.
      expect(AiBank.parseQuestion(served(1), book: 43, chapter: 3), isNull);
      expect(AiBank.parseQuestion(served(1), book: 57, chapter: 1), isNotNull);
    });
  });

  group('cache et serveur', () {
    late AppDatabase db;
    late AiBankRepository repo;
    late FakeServer server;
    late AiBankService service;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = AiBankRepository(db);
      server = FakeServer();
      service = server.service(repo);
    });
    tearDown(() => db.close());

    test('synchronise, garde hors ligne, ne retélécharge pas une révision connue', () async {
      server.ready('57:1', 1, [served(1), served(2), {'id': 'abîmée'}]);
      var status = await service.sync(['57:1', '43:3']);
      expect(status.states, {'57:1': AiChapterState.ready, '43:3': AiChapterState.none});
      expect(status.requestable, ['43:3']);
      expect((status.quota.enabled, status.quota.remaining), (true, 3));
      expect((await repo.questions()).map((q) => q.id), ['gen-ai-1', 'gen-ai-2']);
      expect(await repo.questions(books: {43}), isEmpty);
      // Deuxième lecture : la révision connue est annoncée, rien n'est renvoyé, le cache reste.
      await service.sync(['57:1']);
      expect(server.calls.last.$2['known'], {'57:1': 1});
      expect(server.calls.last.$2['device'], '0123456789abcdef0123');
      expect(await repo.questions(), hasLength(2));
      // Le serveur corrige une question : nouvelle révision, le cache suit.
      server.ready('57:1', 2, [served(1, reviewed: true)]);
      await service.sync(['57:1']);
      final kept = await repo.questions();
      expect((kept.length, kept.single.reviewed), (1, true));
      // Hors ligne : erreur claire, cache intact.
      server.down = true;
      await expectLater(service.sync(['57:1']), throwsA(isA<ApiException>()));
      expect(await repo.questions(), hasLength(1));
    });

    test('un chapitre vidé côté serveur disparaît du cache ; en rédaction, il reste', () async {
      server.ready('57:1', 1, [served(1)]);
      await service.sync(['57:1']);
      server.chapters['57:1'] = {'code': '57:1', 'state': 'queued', 'rev': 1};
      expect((await service.sync(['57:1'])).states['57:1'], AiChapterState.preparing);
      expect(await repo.questions(), hasLength(1));
      server.chapters['57:1'] = {'code': '57:1', 'state': 'empty', 'rev': 1};
      await service.sync(['57:1']);
      expect(await repo.questions(), isEmpty);
    });

    test('beaucoup de chapitres : plusieurs appels', () async {
      final codes = [for (var c = 1; c <= 320; c++) '19:${c % 150 + 1}-$c'];
      await service.sync(codes);
      expect(server.calls.length, 3);
      expect((server.calls.first.$2['chapters'] as List).length, AiBank.chunk);
    });

    test('réponse réelle du serveur (enregistrée depuis biblical_quiz_backend 19.0.3.0.0)', () async {
      final body = File('test/fixtures/ai_bank_response.json').readAsBytesSync();
      final real = AiBankService(
        api: ApiClient(baseUrl: 'http://test', httpClient: MockClient((_) async => http.Response.bytes(body, 200))),
        repo: repo,
        deviceId: () async => '0123456789abcdef0123',
      );
      final status = await real.sync(['43:3', '57:1']);
      expect(status.states, {'43:3': AiChapterState.ready, '57:1': AiChapterState.none});
      final questions = await repo.questions();
      expect(questions, hasLength(3));
      expect(questions.first.ref.code, '43:3:16');
      expect(questions.first.options('fr')[questions.first.correctIndex], startsWith('Pour que celui qui croit'));
      expect(questions.first.reviewed, isFalse);
    });

    test('demande et refus', () async {
      final (state, quota) = await service.request('43:3');
      expect((state, quota.remaining), (AiChapterState.preparing, 2));
      server.refuse = 'AI_QUOTA';
      await expectLater(service.request('43:4'), throwsA(isA<ApiException>().having((e) => e.code, 'code', 'AI_QUOTA')));
    });

    test('signalement : une question retirée quitte le cache', () async {
      server.ready('57:1', 1, [served(1), served(2)]);
      await service.sync(['57:1']);
      expect(await service.report('gen-ai-2', 'unclear', ' note '), isFalse);
      expect(server.calls.last.$2['note'], 'note');
      expect(await repo.questions(), hasLength(2));
      expect(await service.report('gen-ai-1', 'wrong', ''), isTrue);
      expect((await repo.questions()).single.id, 'gen-ai-2');
    });

    test('migration : une base 1.12 (schéma 3) garde ses données et reçoit le cache', () async {
      final dir = await Directory.systemTemp.createTemp('bq_ai');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/db.sqlite');
      final old = AppDatabase.forTesting(NativeDatabase(file));
      await old.into(old.favorites).insert(FavoritesCompanion.insert(ref: '43:3:16', createdAt: 1));
      await old.customStatement('DROP TABLE ai_chapters');
      await old.customStatement('PRAGMA user_version = 3');
      await old.close();
      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(upgraded.close);
      expect((await upgraded.select(upgraded.favorites).get()).single.ref, '43:3:16');
      final cache = AiBankRepository(upgraded);
      await cache.store(57, 1, 1, [served(1)]);
      expect(await cache.questions(), hasLength(1));
      await cache.clear();
      expect(await cache.revisions(), isEmpty);
    });

    test('pas de révision espacée pour une question IA', () async {
      final progress = ProgressRepository(db, today: () => 20261124);
      await progress.recordQuiz(records: const [AnswerRecord('gen-ai-1', false)], total: 1);
      expect(await progress.watchDue().first, isEmpty);
    });
  });

  group('quiz de lecture', () {
    late final Content content;
    late final Bible lsg;
    setUpAll(() {
      content = loadContent();
      lsg = loadBible(Translation.lsg);
    });

    test('les questions IA passent après les relues et avant le texte, dans la portée seulement', () {
      final ai = <Question>[
        for (var n = 1; n <= 4; n++) AiBank.parseQuestion(served(n))!,
        AiBank.parseQuestion(served(9, ref: '43:3:16'))!, // hors portée
      ];
      final scope = ReadingScope({57: null});
      final curated = content.allQuestions.where((q) => scope.contains(q.ref)).length;
      final qs = ReadingQuiz.build(content: content, bible: lsg, lang: 'fr', scope: scope, count: 10, random: Random(1), ai: ai);
      final kinds = [for (final q in qs) q is AiChoiceQuestion ? 'ai' : q.id.startsWith('gen-') ? 'gen' : 'relue'];
      expect(kinds.where((k) => k == 'ai').length, 4);
      expect(kinds.take(curated), everyElement('relue'));
      expect(kinds.skip(curated).take(4), everyElement('ai'));
      expect(qs.any((q) => q.id == 'gen-ai-9'), isFalse);
      // Pas de mot à retrouver sur un verset déjà interrogé par une question IA.
      expect(qs.where((q) => q is! AiChoiceQuestion && q.id.contains('57:1:10')), isEmpty);
      // Sans questions IA : comme avant.
      final plain = ReadingQuiz.build(content: content, bible: lsg, lang: 'fr', scope: scope, count: 10, random: Random(1));
      expect(plain.whereType<AiChoiceQuestion>(), isEmpty);
    });

    test('plusieurs chapitres : chacun a sa part', () {
      final ai = <Question>[
        for (var n = 1; n <= 8; n++) AiBank.parseQuestion(served(n, ref: '65:1:3'))!,
        AiBank.parseQuestion(served(20, ref: '64:1:4'))!,
        AiBank.parseQuestion(served(21, ref: '63:1:6'))!,
      ];
      final qs = ReadingQuiz.build(
        content: content, bible: lsg, lang: 'fr', scope: ReadingScope({63: null, 64: null, 65: null}),
        count: 20, random: Random(3), ai: ai,
      );
      final curated = qs.where((q) => !q.id.startsWith('gen-')).length;
      final firstAi = qs.skip(curated).take(3).map((q) => q.ref.book).toSet();
      expect(firstAi, {63, 64, 65});
    });
  });

  group('interface', () {
    Widget host(AppDatabase db, Widget child, {AiBankService? service}) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        if (service != null) aiBankServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );

    AppDatabase memory() =>
        AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 6; i++) {
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
        await tester.pump(const Duration(milliseconds: 800));
      }
    }

    testWidgets('carte éteinte : aucun appel ; activée : état, demande, quota', (tester) async {
      final db = memory();
      final server = FakeServer()..ready('57:1', 1, [served(1)]);
      final service = server.service(AiBankRepository(db));
      await tester.pumpWidget(host(db, const AiQuestionsCard(chapters: ['57:1', '63:1', '64:1']), service: service));
      await settle(tester);
      expect(find.byKey(const ValueKey('ai-enable')), findsOneWidget);
      expect(server.calls, isEmpty);

      await tester.tap(find.byKey(const ValueKey('ai-enable')));
      await settle(tester);
      expect(find.text('Chapitres avec des questions de compréhension : 1 sur 3.'), findsOneWidget);
      expect(find.text('Demander 2 chapitres'), findsOneWidget);
      expect(find.text('Vous pouvez encore demander 3 chapitres aujourd’hui.'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('ai-ask')));
      await settle(tester);
      expect(server.calls.where((c) => c.$1 == '/ai/request').map((c) => c.$2['chapter']), ['63:1', '64:1']);
      expect(find.textContaining('2 chapitres en préparation'), findsOneWidget);
      expect(find.byKey(const ValueKey('ai-ask')), findsNothing);

      // Le serveur a fini : la lecture suivante (minuteur) le montre.
      server.ready('63:1', 1, [served(5, ref: '63:1:6')]);
      server.ready('64:1', 1, [served(6, ref: '64:1:4')]);
      await tester.pump(const Duration(seconds: 11));
      await settle(tester);
      expect(find.text('Tous les chapitres choisis ont leurs questions.'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(db.close);
    });

    testWidgets('carte : hors connexion, puis service absent du serveur', (tester) async {
      final db = memory();
      await tester.runAsync(
        () => db.into(db.settingsEntries).insert(SettingsEntriesCompanion.insert(key: 'aiQuestions', value: '1')),
      );
      final server = FakeServer()..down = true;
      await tester.pumpWidget(host(db, const AiQuestionsCard(chapters: ['57:1']), service: server.service(AiBankRepository(db))));
      await settle(tester);
      expect(find.textContaining('Hors connexion'), findsOneWidget);
      server
        ..down = false
        ..enabled = false;
      await tester.tap(find.text('Réessayer'));
      await settle(tester);
      expect(find.textContaining('ne sont pas disponibles'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(db.close);
    });

    testWidgets('quiz : étiquette « non relu » avant de répondre, signalement après', (tester) async {
      final db = memory();
      final server = FakeServer();
      final session = QuizSession([AiBank.parseQuestion(served(1))!, AiBank.parseQuestion(served(2, reviewed: true))!]);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            aiBankServiceProvider.overrideWithValue(server.service(AiBankRepository(db))),
          ],
          child: MaterialApp(
            theme: buildTheme(Brightness.light),
            locale: const Locale('fr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: QuizView(session: session, showSource: true, onFinished: (_) {})),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Rédigé par IA · non relu'), findsOneWidget);
      expect(find.text('Philémon'), findsOneWidget);
      expect(find.text('Tiré du texte'), findsNothing);
      expect(find.byKey(const ValueKey('ai-report')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('option-0')));
      await tester.pumpAndSettle();
      expect(find.textContaining('personne ne l’a encore relue'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('ai-report')));
      await tester.tap(find.byKey(const ValueKey('ai-report')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('ai-reason-several')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('ai-report-send')));
      await settle(tester);
      expect(server.calls.single.$2, containsPair('reason', 'several'));
      expect(server.calls.single.$2, containsPair('question', 'gen-ai-1'));
      expect(find.text('Merci : la question sera relue.'), findsOneWidget);

      // Le message de remerciement recouvre un instant le bouton : on le laisse partir.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Suivant'));
      await tester.pump();
      expect(find.text('Rédigé par IA · relu'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(db.close);
    });
  });
}
