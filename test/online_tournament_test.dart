import 'package:biblical_quiz/core/theme.dart';
import 'package:biblical_quiz/l10n/gen/app_localizations.dart';
import 'package:biblical_quiz/online/models.dart';
import 'package:biblical_quiz/ui/online/tournament_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tableau et inscriptions d'un tournoi, d'après un état JSON fictif (sans réseau).
void main() {
  Map<String, dynamic> entry(int id, String name, {String state = 'in', int? out, Map<String, dynamic>? team}) => {
    'id': id,
    'name': name,
    'state': state,
    'eliminated_round': out,
    if (team == null) 'player': {'id': id * 10, 'pseudo': name},
    'team': ?team,
  };

  Map<String, dynamic> duel(
    int id,
    int round,
    int position, {
    required String state,
    String? result,
    int? a,
    int? b,
    int? winner,
    int scoreA = 0,
    int scoreB = 0,
  }) => {
    'id': id,
    'round': round,
    'position': position,
    'state': state,
    'result': result,
    'entry_a_id': a,
    'entry_b_id': b,
    'ready_a': false,
    'ready_b': false,
    'winner_entry_id': winner,
    'match_id': null,
    'deadline': null,
    'score_a': scoreA,
    'score_b': scoreB,
  };

  Map<String, dynamic> tournament({
    String state = 'running',
    String mode = 'solo',
    List<Map<String, dynamic>> entries = const [],
    List<Map<String, dynamic>> duels = const [],
    int rounds = 0,
    int? winner,
  }) => {
    'id': 7,
    'code': 'ABC123',
    'name': 'Tournoi de Jean',
    'version': 3,
    'server_now': 0,
    'mode': mode,
    'state': state,
    'organizer_id': 10,
    'organizer_pseudo': 'Alice',
    'is_public': true,
    'lang': 'fr',
    'passages_label': 'Jean 3',
    'passages': [
      {'code': '43:3', 'label': 'Jean 3'},
    ],
    'round_passages': <String, dynamic>{},
    'settings': {
      'question_count': 10,
      'question_seconds': 30,
      'hand_seconds': 5,
      'forfeit_minutes': 10,
      'min_entries': 2,
      'max_entries': 8,
      'team_min_size': 2,
      'team_max_size': 4,
    },
    'rounds': rounds,
    'entries': entries,
    'duels': duels,
    'winner_entry_id': winner,
  };

  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      locale: const Locale('fr'),
      theme: buildTheme(Brightness.light),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );

  testWidgets('tableau : noms des tours, exemption, vainqueur mis en avant', (tester) async {
    // Trois joueurs : Alice bat Bruno, Chloé est exemptée ; la finale attend les joueurs.
    final t = TournamentState(tournament(
      rounds: 2,
      entries: [
        entry(1, 'Alice'),
        entry(2, 'Bruno', state: 'eliminated', out: 1),
        entry(3, 'Chloé'),
      ],
      duels: [
        duel(11, 1, 0, state: 'done', result: 'played', a: 1, b: 2, winner: 1, scoreA: 40, scoreB: 25),
        duel(12, 1, 1, state: 'done', result: 'bye', a: 3, winner: 3),
        duel(13, 2, 0, state: 'ready_wait', a: 1, b: 3),
      ],
    ));
    await pump(tester, TournamentBracket(state: t, myEntryId: 3));

    expect(find.text('Demi-finales'), findsOneWidget);
    expect(find.text('Finale'), findsOneWidget);
    expect(find.text('Exempt'), findsOneWidget);
    expect(find.text('Qualifié d’office'), findsOneWidget);
    expect(find.text('En attente des joueurs'), findsOneWidget);
    expect(find.text('Chloé (vous)'), findsNWidgets(2));

    // Vainqueur du premier duel : ligne repérée, en gras, avec son score.
    final winnerRow = find.byKey(const ValueKey('duel-11-winner'));
    expect(winnerRow, findsOneWidget);
    final name = tester.widget<Text>(find.descendant(of: winnerRow, matching: find.text('Alice')));
    expect(name.style?.fontWeight, FontWeight.w800);
    expect(find.descendant(of: winnerRow, matching: find.text('40')), findsOneWidget);
    expect(find.descendant(of: winnerRow, matching: find.byIcon(Icons.check_circle)), findsOneWidget);
    // Exempté : vainqueur sans score.
    expect(find.byKey(const ValueKey('duel-12-winner')), findsOneWidget);
    // La finale n'a pas encore de vainqueur.
    expect(find.byKey(const ValueKey('duel-13-winner')), findsNothing);
  });

  testWidgets('tableau à quatre tours : « Tour 1 » puis quarts, demies, finale', (tester) async {
    final duels = <Map<String, dynamic>>[];
    var id = 100;
    for (var r = 1; r <= 4; r++) {
      for (var p = 0; p < (16 >> r); p++) {
        duels.add(duel(id++, r, p, state: 'pending'));
      }
    }
    await pump(tester, TournamentBracket(state: TournamentState(tournament(rounds: 4, duels: duels))));
    for (final title in ['Tour 1', 'Quarts de finale', 'Demi-finales', 'Finale']) {
      expect(find.text(title), findsOneWidget);
    }
    expect(find.text('À venir'), findsNWidgets(15));
  });

  testWidgets('inscriptions par équipes : équipe incomplète signalée', (tester) async {
    Map<String, dynamic> team(int id, String name, List<String> members) => {
      'id': id,
      'name': name,
      'captain_id': id * 100,
      'members': [
        for (var i = 0; i < members.length; i++) {'id': id * 100 + i, 'pseudo': members[i]},
      ],
      'pending': const [],
    };
    final t = TournamentState(tournament(
      state: 'registration',
      mode: 'team',
      entries: [
        entry(1, 'Les Lions', team: team(1, 'Les Lions', ['Alice', 'Bruno'])),
        entry(2, 'Les Aigles', team: team(2, 'Les Aigles', ['Chloé'])),
      ],
    ));
    final actions = <String>[];
    await pump(
      tester,
      TournamentRegistrationList(
        state: t,
        myEntryId: null,
        myPlayerId: 999,
        onTeamAction: (team, action, playerId) => actions.add('${team.id}:$action'),
      ),
    );
    expect(find.text('Les Lions'), findsOneWidget);
    expect(find.text('Les Aigles'), findsOneWidget);
    expect(find.textContaining('Équipe incomplète'), findsOneWidget);
    // Sans équipe, on peut demander à entrer.
    await tester.tap(find.text('Demander à entrer').first);
    expect(actions, ['1:request']);
  });

  testWidgets('inscriptions entre joueurs : « vous » et liste vide', (tester) async {
    await pump(
      tester,
      TournamentRegistrationList(
        state: TournamentState(tournament(state: 'registration', entries: [entry(1, 'Alice'), entry(2, 'Bruno')])),
        myEntryId: 2,
        myPlayerId: 20,
      ),
    );
    expect(find.text('Bruno (vous)'), findsOneWidget);
    expect(find.byTooltip('Organisateur'), findsOneWidget);

    await pump(
      tester,
      TournamentRegistrationList(state: TournamentState(tournament(state: 'registration')), myEntryId: null, myPlayerId: 1),
    );
    expect(find.text('Personne n’est encore inscrit. Partagez le code !'), findsOneWidget);
  });
}
