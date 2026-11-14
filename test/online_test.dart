import 'dart:convert';

import 'package:biblical_quiz/core/theme.dart';
import 'package:biblical_quiz/l10n/gen/app_localizations.dart';
import 'package:biblical_quiz/online/api.dart';
import 'package:biblical_quiz/online/models.dart';
import 'package:biblical_quiz/online/online_providers.dart';
import 'package:biblical_quiz/online/realtime.dart';
import 'package:biblical_quiz/online/service.dart';
import 'package:biblical_quiz/ui/online/match_screen.dart';
import 'package:biblical_quiz/ui/online/online_common.dart';
import 'package:biblical_quiz/ui/online/online_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Faux serveur : rejoue un match à deux joueurs (Alice = moi, Bruno).
class FakeServer {
  int version = 1;
  String phase = 'open';
  int? hand;
  int? answer;
  int? winner;
  final calls = <String>[];

  int get now => DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> state() => {
    'id': 7, 'code': 'ABC123', 'version': version, 'server_now': now, 'kind': 'free', 'mode': 'solo',
    'state': 'running', 'phase': phase, 'lang': 'fr', 'creator_id': 1, 'is_public': true,
    'passages': [{'code': '43:3', 'label': 'Jean 3'}], 'passages_label': 'Jean 3',
    'settings': {'question_count': 5, 'question_seconds': 30, 'hand_seconds': 5, 'max_players': 10},
    'participants': [
      {'id': 11, 'player_id': 1, 'pseudo': 'Alice', 'team_id': null, 'score': winner == 11 ? 10 : 0,
       'correct': 0, 'wrong': 0, 'left': false, 'online': true, 'ready': false, 'rank': null},
      {'id': 12, 'player_id': 2, 'pseudo': 'Bruno', 'team_id': null, 'score': 0, 'correct': 0, 'wrong': 0,
       'left': false, 'online': true, 'ready': false, 'rank': null},
    ],
    'teams': [], 'phase_until': phase == 'reveal' ? now + 6000 : null, 'result': null, 'tournament': null,
    'question': {
      'index': 1, 'total': 5, 'tiebreak': false, 'prompt': 'Qui vint trouver Jésus de nuit ?',
      'options': ['Pierre', 'Nicodème', 'Jean', 'Thomas'], 'ref_label': 'Jean 3:2', 'source': 'reviewed',
      'locked': <String>[],
      'deadline': phase == 'open' ? now + 20000 : null,
      'remaining_ms': phase == 'hand' ? 18000 : null,
      'hand': phase == 'hand' ? {'participant_id': hand, 'deadline': now + 5000} : null,
      if (phase == 'reveal') ...{
        'answer': 1, 'explain': 'Jean 3:1-2', 'ref': '43:3:1-2', 'winner_participant_id': winner, 'answers': [],
      },
    },
  };

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path.replaceFirst('/quiz-biblique/api/v1', '');
    final params = (jsonDecode(request.body) as Map)['params'] as Map;
    calls.add(path);
    Map<String, dynamic> result;
    switch (path) {
      case '/config':
        result = {'server_now': now, 'websocket_version': '19.0-2', 'limits': {}, 'defaults': {}};
      case '/match/buzz':
        phase = 'hand';
        hand = 11;
        version++;
        result = {'match': state(), 'me': 11, 'channel': ''};
      case '/match/answer':
        answer = params['choice'] as int;
        phase = 'reveal';
        winner = answer == 1 ? 11 : null;
        version++;
        result = {'correct': answer == 1, 'match': state(), 'me': 11, 'channel': ''};
      default:
        result = {'match': state(), 'me': 11, 'channel': ''};
    }
    return http.Response(jsonEncode({'jsonrpc': '2.0', 'id': 1, 'result': {...result, 'success': true}}), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}

Widget app(OnlineService service, Widget child) => ProviderScope(
  overrides: [onlineServiceProvider.overrideWithValue(service)],
  child: MaterialApp(
    theme: buildTheme(Brightness.light),
    locale: const Locale('fr'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  ),
);

void main() {
  group('liens de partie', () {
    test('lien du serveur, schéma de l’application, version web', () {
      expect(parseGameLink(Uri.parse('https://x.org/quiz-biblique/rejoindre/abc123')).join, 'ABC123');
      expect(parseGameLink(Uri.parse('https://x.org/quiz-biblique/join/ABC123')).join, 'ABC123');
      expect(parseGameLink(Uri.parse('quizbiblique://join/XYZ789')).join, 'XYZ789');
      expect(parseGameLink(Uri.parse('https://x.org/apps/quiz-biblique/web/?join=ab12cd')).join, 'AB12CD');
      expect(parseGameLink(Uri.parse('https://x.org/apps/quiz-biblique/web/?watch=AB12CD')).watch, 'AB12CD');
      expect(parseGameLink(Uri.parse('https://x.org/apps/quiz-biblique/web/')).join, isNull);
      expect(parseGameLink(Uri.parse('quizbiblique://join/TOOLONG1')).join, isNull);
    });
  });

  group('passages', () {
    test('codes envoyés au serveur', () {
      expect(passageCode(43, 3, 3), '43:3');
      expect(passageCode(1, 1, 3), '1:1-3');
      expect(passageCode(43, 3, 3, v1: 1, v2: 21), '43:3:1-21');
      expect(passageCode(43, 3, 4, v1: 36, v2: 2), '43:3:36-4:2');
      expect(passageLabel('1:1-3', 'fr'), 'Genèse 1–3');
      expect(passageLabel('43:3:1-21', 'en'), 'John 3:1-21');
    });
  });

  group('horloge du serveur', () {
    test('décalage mesuré au milieu de l’aller-retour, lissé', () {
      final clock = ServerClock();
      expect(clock.known, isFalse);
      clock.sample(10500, 1000, 2000); // serveur en avance de 9000 ms
      expect(clock.offset, 9000);
      clock.sample(10900, 1000, 2000); // mesure isolée : lissée
      expect(clock.offset, 9100);
      clock.sample(99999, 1000, 20000); // aller-retour aberrant : ignoré
      expect(clock.offset, 9100);
      expect(clock.remaining(null), 0);
    });
  });

  group('modèles', () {
    test('la bonne réponse n’existe pas avant la clôture', () {
      final fake = FakeServer();
      final m = MatchState(fake.state());
      expect(m.question!.answer, isNull);
      expect(m.question!.deadline, isNotNull);
      expect(m.lockKey(m.participants.first), 'p11');
      fake.phase = 'reveal';
      expect(MatchState(fake.state()).question!.answer, 1);
    });
  });

  testWidgets('prendre la main puis répondre juste', (tester) async {
    final fake = FakeServer();
    final service = OnlineService(
      server: 'http://test',
      tokens: MemoryTokenStore()..token = 'jeton',
      client: ApiClient(baseUrl: 'http://test', httpClient: MockClient(fake.handle)),
    );
    await tester.pumpWidget(app(service, const MatchScreen(matchId: 7)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Qui vint trouver Jésus de nuit ?'), findsOneWidget);
    // Avant la main, les réponses sont inactives.
    final option = find.widgetWithText(OutlinedButton, 'Nicodème');
    expect(tester.widget<OutlinedButton>(option).onPressed, isNull);
    await tester.tap(find.text('Je réponds !'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(fake.calls, contains('/match/buzz'));
    expect(find.text('Chrono en pause'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(option).onPressed, isNotNull);
    await tester.tap(option);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(fake.answer, 1);
    expect(find.text('Alice a trouvé'), findsOneWidget);
    // Fermer l'écran arrête les minuteurs.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  test('refus du serveur : code et message', () async {
    final client = ApiClient(
      baseUrl: 'http://test',
      httpClient: MockClient((r) async => http.Response(
        jsonEncode({'result': {'success': false, 'error': {'code': 'HAND_TAKEN', 'message': 'Bruno a pris la main.'}}}),
        200,
      )),
    );
    expect(
      () => client.write('/match/buzz'),
      throwsA(isA<ApiException>().having((e) => e.code, 'code', 'HAND_TAKEN')),
    );
  });
}
