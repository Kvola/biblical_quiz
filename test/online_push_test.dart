import 'dart:async';
import 'dart:convert';

import 'package:biblical_quiz/core/theme.dart';
import 'package:biblical_quiz/l10n/gen/app_localizations.dart';
import 'package:biblical_quiz/online/api.dart';
import 'package:biblical_quiz/online/online_providers.dart';
import 'package:biblical_quiz/online/push.dart';
import 'package:biblical_quiz/online/service.dart';
import 'package:biblical_quiz/ui/online/online_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Notifications simulées : on pousse soi-même ce que Firebase livrerait.
class FakePush extends NoPushService {
  final receivedCtl = StreamController<PushData>.broadcast();
  final openedCtl = StreamController<PushData>.broadcast();

  @override
  Stream<PushData> get received => receivedCtl.stream;

  @override
  Stream<PushData> get opened => openedCtl.stream;

  @override
  Future<String?> token() async => 'jeton-fcm';

  @override
  Future<String?> currentToken() async => 'jeton-fcm';
}

/// Serveur minimal : enregistre les appels et leurs paramètres.
class Recorder {
  final calls = <String, Map>{};

  Future<http.Response> handle(http.Request request) async {
    final path = request.url.path.replaceFirst('/quiz-biblique/api/v1', '');
    calls[path] = (jsonDecode(request.body) as Map)['params'] as Map;
    final result = switch (path) {
      '/devices' => {'registered': true},
      '/me' => {'account': {'id': 1}, 'player': null},
      _ => <String, dynamic>{},
    };
    return http.Response(jsonEncode({'result': {...result, 'success': true}}), 200,
        headers: {'content-type': 'application/json; charset=utf-8'});
  }
}

OnlineService serviceWith(Recorder r, {String? token = 'session'}) => OnlineService(
  server: 'http://test',
  tokens: MemoryTokenStore()..token = token,
  client: ApiClient(baseUrl: 'http://test', httpClient: MockClient(r.handle)),
);

void main() {
  test('même événement par le temps réel et par la notification : même clé', () {
    final bus = {'event': 'duel_ready', 'tournament_id': 4, 'duel_id': 9, 'match_id': 31, 'title': 'T', 'body': 'B'};
    final fcm = {'event': 'duel_ready', 'tournament_id': '4', 'duel_id': '9', 'match_id': '31', 'title': 'T', 'body': ''};
    expect(playerEventKey(bus), playerEventKey(fcm));
    expect(playerEventKey({...fcm, 'duel_id': '10'}), isNot(playerEventKey(fcm)));
  });

  test('inscription du téléphone seulement avec une session', () async {
    final r = Recorder();
    await registerPushDevice(serviceWith(r), FakePush());
    expect(r.calls['/devices'], {'device_token': 'jeton-fcm', 'platform': 'android', 'device': 'Quiz Biblique'});

    final none = Recorder();
    await registerPushDevice(serviceWith(none, token: null), FakePush());
    expect(none.calls, isEmpty);
  });

  test('déconnexion : le téléphone est désinscrit', () async {
    final r = Recorder();
    await serviceWith(r).signOut(deviceToken: 'jeton-fcm');
    expect(r.calls['/auth/logout'], {'device_token': 'jeton-fcm'});
  });

  testWidgets('notification reçue application ouverte : un seul bandeau', (tester) async {
    final push = FakePush();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        onlineServiceProvider.overrideWithValue(serviceWith(Recorder(), token: null)),
        pushProvider.overrideWithValue(push),
      ],
      child: MaterialApp(
        theme: buildTheme(Brightness.light),
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const OnlineLinkHandler(child: Scaffold(body: Text('accueil'))),
      ),
    ));
    await tester.pump();
    final l = await AppLocalizations.delegate.load(const Locale('fr'));
    final event = {'event': 'duel_ready', 'tournament_id': '4', 'duel_id': '9', 'match_id': '31'};
    push.receivedCtl.add(event);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l.eventDuelReady), findsOneWidget);
    expect(find.text(l.eventSee), findsOneWidget);

    // Le doublon (arrivé aussi par le temps réel) est ignoré, même après le bandeau.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.text(l.eventDuelReady), findsNothing);
    push.receivedCtl.add(event);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(l.eventDuelReady), findsNothing);
  });
}
