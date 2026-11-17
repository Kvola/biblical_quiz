import 'dart:convert';

import 'package:biblical_quiz/app.dart';
import 'package:biblical_quiz/core/theme.dart';
import 'package:biblical_quiz/data/database.dart';
import 'package:biblical_quiz/providers.dart';
import 'package:biblical_quiz/l10n/gen/app_localizations.dart';
import 'package:biblical_quiz/online/api.dart';
import 'package:biblical_quiz/online/online_providers.dart';
import 'package:biblical_quiz/online/service.dart';
import 'package:biblical_quiz/ui/online/match_screen.dart';
import 'package:biblical_quiz/ui/online/projection_screen.dart';
import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

int get _now => DateTime.now().millisecondsSinceEpoch;

Map<String, dynamic> _match({String code = 'DUEL01', String state = 'running', String kind = 'free'}) => {
  'id': 7, 'code': code, 'version': 3, 'server_now': _now, 'kind': kind, 'mode': 'solo',
  'state': state, 'phase': 'open', 'lang': 'fr', 'creator_id': 1, 'is_public': true,
  'passages': [{'code': '43:3', 'label': 'Jean 3'}], 'passages_label': 'Jean 3',
  'settings': {'question_count': 5, 'question_seconds': 30, 'hand_seconds': 5, 'max_players': 10},
  'participants': [
    {'id': 11, 'player_id': 1, 'pseudo': 'Alice', 'team_id': null, 'score': 10, 'correct': 1, 'wrong': 0,
     'left': false, 'online': true, 'ready': false, 'rank': state == 'finished' ? 1 : null},
    {'id': 12, 'player_id': 2, 'pseudo': 'Bruno', 'team_id': null, 'score': 0, 'correct': 0, 'wrong': 0,
     'left': false, 'online': true, 'ready': false, 'rank': state == 'finished' ? 2 : null},
  ],
  'teams': [], 'phase_until': null, 'tournament': null,
  'result': state == 'finished' ? {'outcome': 'normal', 'winner_participant_id': 11} : null,
  'question': state == 'running'
      ? {
          'index': 2, 'total': 5, 'tiebreak': false, 'prompt': 'Qui vint trouver Jésus de nuit ?',
          'options': ['Pierre', 'Nicodème', 'Jean', 'Thomas'], 'ref_label': 'Jean 3:2', 'source': 'reviewed',
          'locked': <String>[], 'deadline': _now + 20000, 'remaining_ms': null, 'hand': null,
        }
      : null,
};

Map<String, dynamic> _tournament({required String state, List<Map<String, dynamic>> duels = const []}) => {
  'id': 5, 'code': 'TRN123', 'name': 'Tournoi de Noël', 'version': 2, 'server_now': _now, 'mode': 'solo',
  'state': state, 'organizer_id': 1, 'organizer_pseudo': 'Alice', 'is_public': true, 'lang': 'fr',
  'passages_label': 'Jean 3', 'passages': [{'code': '43:3', 'label': 'Jean 3'}], 'round_passages': {},
  'settings': {'question_count': 5, 'question_seconds': 30, 'hand_seconds': 5, 'forfeit_minutes': 10,
               'min_entries': 2, 'max_entries': 8, 'team_min_size': 1, 'team_max_size': 5},
  'rounds': duels.isEmpty ? 0 : 1,
  'entries': [
    {'id': 21, 'name': 'Alice', 'state': 'in', 'eliminated_round': null, 'player': {'id': 1, 'pseudo': 'Alice'}},
    {'id': 22, 'name': 'Bruno', 'state': 'in', 'eliminated_round': null, 'player': {'id': 2, 'pseudo': 'Bruno'}},
  ],
  'duels': duels, 'winner_entry_id': null,
};

Map<String, dynamic> _liveFinal() => {
  'id': 31, 'round': 1, 'position': 1, 'state': 'playing', 'result': null, 'entry_a_id': 21, 'entry_b_id': 22,
  'ready_a': true, 'ready_b': true, 'winner_entry_id': null, 'match_id': 7, 'match_code': 'DUEL01',
  'deadline': null, 'score_a': 0, 'score_b': 0,
};

/// Faux serveur : [routes] rend le résultat d'un chemin, ou null pour un 404 (route inconnue).
OnlineService _service(Map<String, dynamic>? Function(String path, Map params) routes, List<String> calls) {
  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path.replaceFirst('/quiz-biblique/api/v1', '');
    final params = (jsonDecode(request.body) as Map)['params'] as Map;
    calls.add('$path ${params['code'] ?? ''}'.trim());
    final result = path == '/config'
        ? {'server_now': _now, 'websocket_version': '19.0-2', 'limits': {}, 'defaults': {}}
        : routes(path, params);
    if (result == null) return http.Response('Not Found', 404);
    return http.Response(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': {...result, 'success': true}}), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }

  return OnlineService(
    server: 'http://test',
    tokens: MemoryTokenStore()..token = 'jeton',
    client: ApiClient(baseUrl: 'http://test', httpClient: MockClient(handle)),
  );
}

Widget _app(OnlineService service, Widget child) => ProviderScope(
  overrides: [onlineServiceProvider.overrideWithValue(service)],
  child: MaterialApp(
    theme: buildTheme(Brightness.light),
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  ),
);

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// Ferme l'écran : ses minuteurs s'arrêtent.
Future<void> _close(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 20));
}

void main() {
  testWidgets('lien de projection (?watch=) : l’écran s’ouvre sans l’accueil, même au tout premier lancement',
      (tester) async {
    tester.platformDispatcher.localeTestValue = const Locale('fr');
    tester.platformDispatcher.localesTestValue = [const Locale('fr')];
    addTearDown(tester.platformDispatcher.clearAllTestValues);
    final db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory(), closeStreamsSynchronously: true));
    final service = _service(
      (path, p) => path == '/watch' ? {'kind': 'tournament', 'tournament': _tournament(state: 'registration'),
                                       'my_entry_id': null, 'channel': ''} : null,
      <String>[],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        onlineServiceProvider.overrideWithValue(service),
        launchWatchCodeProvider.overrideWithValue('TRN123'),
      ],
      child: const BibleQuizApp(),
    ));
    await _settle(tester);
    expect(find.text('Commencer'), findsNothing, reason: 'pas d’écran d’accueil');
    expect(find.text('Inscriptions ouvertes — code TRN123'), findsOneWidget);
    // Rien n'est marqué comme vu : l'accueil reste proposé au prochain lancement normal.
    final onboarded = await tester.runAsync(() async => (await db.select(db.settingsEntries).get())
        .any((e) => e.key == 'onboarded' && e.value == '1'));
    expect(onboarded, isFalse);
    await _close(tester);
    await tester.runAsync(db.close);
  });

  testWidgets('le code d’un tournoi s’affiche : inscriptions, QR code, inscrits', (tester) async {
    final calls = <String>[];
    final service = _service(
      (path, p) => path == '/watch' ? {'kind': 'tournament', 'tournament': _tournament(state: 'registration'),
                                       'my_entry_id': null, 'channel': ''} : null,
      calls,
    );
    await tester.pumpWidget(_app(service, const ProjectionScreen(code: 'trn123')));
    await _settle(tester);
    expect(calls, contains('/watch TRN123'));
    expect(calls.where((c) => c.startsWith('/match/watch')), isEmpty);
    expect(find.text('Tournoi de Noël'), findsOneWidget);
    expect(find.text('Inscriptions ouvertes — code TRN123'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bruno'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('tournoi en cours : le duel seul en cours s’affiche en grand, « Tableau » revient au tableau',
      (tester) async {
    final calls = <String>[];
    final service = _service((path, p) {
      if (path == '/watch' && p['code'] == 'TRN123') {
        return {'kind': 'tournament', 'tournament': _tournament(state: 'running', duels: [_liveFinal()]),
                'my_entry_id': null, 'channel': ''};
      }
      if (path == '/match/watch' && p['code'] == 'DUEL01') return {'match': _match(kind: 'duel'), 'me': null, 'channel': ''};
      return null;
    }, calls);
    await tester.pumpWidget(_app(service, const ProjectionScreen(code: 'TRN123')));
    await _settle(tester);
    expect(calls, contains('/match/watch DUEL01'));
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsOneWidget);
    expect(find.text('Tournoi de Noël · Finale'), findsOneWidget);

    await tester.tap(find.text('Tableau'));
    await _settle(tester);
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsNothing);
    expect(find.text('Duels en cours — touchez-en un pour l’afficher en grand'), findsOneWidget);
    // Choisi à la main, le tableau reste (pas de bascule automatique).
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsNothing);
    // Toucher le duel l'affiche de nouveau.
    await tester.tap(find.text('Alice contre Bruno'));
    await _settle(tester);
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('duel terminé : son résultat reste affiché un moment, puis le tableau revient', (tester) async {
    var finished = false;
    final service = _service((path, p) {
      if (path == '/watch') {
        final duel = _liveFinal();
        final t = _tournament(state: 'running', duels: [
          if (finished) {...duel, 'state': 'done', 'result': 'played', 'winner_entry_id': 21, 'score_a': 10} else duel,
        ]);
        return {'kind': 'tournament', 'tournament': {...t, 'version': finished ? 3 : 2}, 'my_entry_id': null,
                'channel': ''};
      }
      if (path == '/match/watch') {
        return {'match': _match(kind: 'duel', state: finished ? 'finished' : 'running'), 'me': null, 'channel': ''};
      }
      return null;
    }, <String>[]);
    await tester.pumpWidget(_app(service, const ProjectionScreen(code: 'TRN123')));
    await _settle(tester);
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsOneWidget);
    finished = true;
    await tester.pump(const Duration(seconds: 5)); // relèves du match et du tournoi
    await _settle(tester);
    expect(find.text('Alice gagne !'), findsOneWidget, reason: 'résultat du duel encore à l’écran');
    await tester.pump(const Duration(seconds: 13));
    await _settle(tester);
    expect(find.text('Alice gagne !'), findsNothing);
    expect(find.text('Aucun duel en cours pour l’instant.'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('serveur pas encore à jour (pas de /watch) : un code de match s’affiche quand même', (tester) async {
    final calls = <String>[];
    final service = _service(
      (path, p) => path == '/match/watch' ? {'match': _match(code: 'ABC123'), 'me': null, 'channel': ''} : null,
      calls,
    );
    await tester.pumpWidget(_app(service, const ProjectionScreen(code: 'ABC123')));
    await _settle(tester);
    expect(calls.first, '/watch ABC123');
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('code inconnu : message, puis retour à la saisie', (tester) async {
    final service = OnlineService(
      server: 'http://test',
      tokens: MemoryTokenStore(),
      client: ApiClient(
        baseUrl: 'http://test',
        httpClient: MockClient((r) async => http.Response(
          jsonEncode({'result': {'success': false, 'error': {'code': 'UNKNOWN_CODE', 'message': 'Inconnu'}}}),
          200,
        )),
      ),
    );
    await tester.pumpWidget(_app(service, const ProjectionScreen(code: 'ZZZZZZ')));
    await _settle(tester);
    expect(find.text('Retour'), findsOneWidget);
    await tester.tap(find.text('Retour'));
    await _settle(tester);
    expect(find.text('Code du match ou du tournoi'), findsOneWidget);
    await _close(tester);
  });

  testWidgets('fin de match : « Revanche » est nettement séparé de « Revoir les questions »', (tester) async {
    final service = _service(
      (path, p) => {'match': _match(code: 'ABC123', state: 'finished'), 'me': 11, 'channel': ''},
      <String>[],
    );
    await tester.pumpWidget(_app(service, const MatchScreen(matchId: 7)));
    await _settle(tester);
    final review = find.ancestor(of: find.text('Revoir les questions'), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    final rematch = find.ancestor(of: find.text('Revanche'), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    await tester.scrollUntilVisible(rematch, 100, scrollable: find.byType(Scrollable).first);
    expect(review, findsOneWidget);
    expect(rematch, findsOneWidget);
    final gap = tester.getTopLeft(rematch).dy - tester.getBottomLeft(review).dy;
    expect(gap, greaterThanOrEqualTo(12));
    await _close(tester);
  });
}
