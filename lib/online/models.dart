/// États du jeu en ligne tels que le serveur les envoie (lecture seule).
///
/// Le serveur est le seul arbitre : l'application n'a jamais la bonne
/// réponse avant que la question soit close ([QuestionState.answer]).
library;

int _int(Object? v, [int fallback = 0]) => v is num ? v.toInt() : fallback;
int? _intOrNull(Object? v) => v is num ? v.toInt() : null;
String _str(Object? v) => v == null ? '' : '$v';
List<Map<String, dynamic>> _maps(Object? v) =>
    v is List ? v.whereType<Map>().map((m) => m.cast<String, dynamic>()).toList() : const [];

class PlayerProfile {
  PlayerProfile(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get pseudo => _str(json['pseudo']);
  String get lang => _str(json['lang']).isEmpty ? 'fr' : _str(json['lang']);
  String get channel => _str(json['channel']);
  int? get matchId => _intOrNull(json['match_id']);
  String? get matchCode => json['match_code'] as String?;
  String? get matchState => json['match_state'] as String?;
  int? get tournamentId => _intOrNull(json['tournament_id']);
  String? get tournamentName => json['tournament_name'] as String?;
  Map<String, dynamic> get stats => (json['stats'] as Map?)?.cast<String, dynamic>() ?? const {};
  int get played => _int(stats['played']);
  int get won => _int(stats['won']);
  int get tournamentsWon => _int(stats['tournaments_won']);
}

/// Le compte connecté : un numéro vérifié, et (peut-être) déjà un profil de joueur.
class OnlineMe {
  OnlineMe(this.json);

  final Map<String, dynamic> json;

  String get phone => _str(json['phone']);
  PlayerProfile? get player => json['player'] is Map ? PlayerProfile((json['player'] as Map).cast()) : null;
}

class Passage {
  const Passage(this.code, this.label);

  final String code;
  final String label;

  static List<Passage> list(Object? v) => [for (final m in _maps(v)) Passage(_str(m['code']), _str(m['label']))];
}

class Participant {
  Participant(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  int get playerId => _int(json['player_id']);
  String get pseudo => _str(json['pseudo']);
  int? get teamId => _intOrNull(json['team_id']);
  int get score => _int(json['score']);
  int get correct => _int(json['correct']);
  int get wrong => _int(json['wrong']);
  bool get left => json['left'] == true;
  bool get online => json['online'] == true;
  bool get ready => json['ready'] == true;
  int? get rank => _intOrNull(json['rank']);
}

class PendingMember {
  PendingMember(this.json);

  final Map<String, dynamic> json;

  int get playerId => _int(json['player_id']);
  String get pseudo => _str(json['pseudo']);

  /// `invited` (le capitaine a invité) ou `requested` (le joueur a demandé).
  String get kind => _str(json['kind']);
}

class TeamState {
  TeamState(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get name => _str(json['name']);
  int get captainId => _int(json['captain_id']);
  int get score => _int(json['score']);
  List<({int id, String pseudo})> get members =>
      [for (final m in _maps(json['members'])) (id: _int(m['id']), pseudo: _str(m['pseudo']))];
  List<PendingMember> get pending => [for (final m in _maps(json['pending'])) PendingMember(m)];

  bool hasMember(int playerId) => members.any((m) => m.id == playerId);
}

class AnswerLog {
  AnswerLog(this.json);

  final Map<String, dynamic> json;

  int get participantId => _int(json['participant_id']);

  /// `correct`, `wrong` ou `timeout`.
  String get kind => _str(json['kind']);
  int get choice => _int(json['choice'], -1);
  int get points => _int(json['points']);
}

class QuestionState {
  QuestionState(this.json);

  final Map<String, dynamic> json;

  int get index => _int(json['index']);
  int get total => _int(json['total']);
  bool get tiebreak => json['tiebreak'] == true;
  String get prompt => _str(json['prompt']);
  List<String> get options => (json['options'] as List? ?? const []).map((e) => '$e').toList();
  String get refLabel => _str(json['ref_label']);

  /// `reviewed` (question relue) ou `generated` (tirée du texte).
  String get source => _str(json['source']);
  List<String> get locked => (json['locked'] as List? ?? const []).map((e) => '$e').toList();

  /// Échéance de la question (horloge du serveur, ms) quand elle est ouverte.
  int? get deadline => _intOrNull(json['deadline']);

  /// Temps de question restant, mis en pause pendant une main.
  int? get remainingMs => _intOrNull(json['remaining_ms']);
  int? get handParticipantId => json['hand'] is Map ? _intOrNull((json['hand'] as Map)['participant_id']) : null;
  int? get handDeadline => json['hand'] is Map ? _intOrNull((json['hand'] as Map)['deadline']) : null;

  // Après la clôture seulement :
  int? get answer => _intOrNull(json['answer']);
  String get explain => _str(json['explain']);
  String get ref => _str(json['ref']);
  int? get winnerParticipantId => _intOrNull(json['winner_participant_id']);
  List<AnswerLog> get answers => [for (final m in _maps(json['answers'])) AnswerLog(m)];
}

class MatchResult {
  MatchResult(this.json);

  final Map<String, dynamic> json;

  /// `played`, `tiebreak`, `tiebreak_rule`, `abandon`, `idle`.
  String get outcome => _str(json['outcome']);
  int? get winnerParticipantId => _intOrNull(json['winner_participant_id']);
  int? get winnerTeamId => _intOrNull(json['winner_team_id']);
}

class MatchState {
  MatchState(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get code => _str(json['code']);
  int get version => _int(json['version']);
  int get serverNow => _int(json['server_now']);

  /// `free` (match libre) ou `duel` (tournoi).
  String get kind => _str(json['kind']);

  /// `solo` ou `team`.
  String get mode => _str(json['mode']);
  bool get isTeam => mode == 'team';

  /// `lobby`, `running`, `finished`, `cancelled`.
  String get state => _str(json['state']);

  /// `countdown`, `open`, `hand`, `reveal` (pendant `running`).
  String? get phase => json['phase'] as String?;
  String get lang => _str(json['lang']);
  int? get creatorId => _intOrNull(json['creator_id']);
  bool get isPublic => json['is_public'] == true;
  List<Passage> get passages => Passage.list(json['passages']);
  String get passagesLabel => _str(json['passages_label']);
  Map<String, dynamic> get settings => (json['settings'] as Map?)?.cast<String, dynamic>() ?? const {};
  int get questionCount => _int(settings['question_count']);
  int get questionSeconds => _int(settings['question_seconds']);
  int get handSeconds => _int(settings['hand_seconds']);
  int get maxPlayers => _int(settings['max_players']);
  List<Participant> get participants => [for (final m in _maps(json['participants'])) Participant(m)];
  List<TeamState> get teams => [for (final m in _maps(json['teams'])) TeamState(m)];
  int? get phaseUntil => _intOrNull(json['phase_until']);
  QuestionState? get question => json['question'] is Map ? QuestionState((json['question'] as Map).cast()) : null;
  MatchResult? get result => json['result'] is Map ? MatchResult((json['result'] as Map).cast()) : null;
  Map<String, dynamic>? get tournament => (json['tournament'] as Map?)?.cast<String, dynamic>();

  List<Participant> get active => participants.where((p) => !p.left).toList();

  Participant? participant(int? id) => participants.where((p) => p.id == id).firstOrNull;
  Participant? participantOfPlayer(int? playerId) => participants.where((p) => p.playerId == playerId).firstOrNull;
  TeamState? team(int? id) => teams.where((t) => t.id == id).firstOrNull;

  /// Clé de blocage d'un participant (lui seul, ou toute son équipe).
  String lockKey(Participant p) => isTeam ? 't${p.teamId}' : 'p${p.id}';
}

/// État renvoyé par le serveur : l'état public, mon participant, le canal temps réel.
class MatchEnvelope {
  MatchEnvelope(this.match, this.me, this.channel);

  final MatchState match;
  final int? me;
  final String channel;

  static MatchEnvelope parse(Map<String, dynamic> r) =>
      MatchEnvelope(MatchState((r['match'] as Map).cast()), _intOrNull(r['me']), _str(r['channel']));
}

class HistoryQuestion {
  HistoryQuestion(this.json);

  final Map<String, dynamic> json;
  QuestionState get q => QuestionState(json);
}

// ------------------------------------------------------------------ tournois

class TournamentEntry {
  TournamentEntry(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get name => _str(json['name']);

  /// `in`, `eliminated`, `winner`.
  String get state => _str(json['state']);
  int? get eliminatedRound => _intOrNull(json['eliminated_round']);
  int? get playerId => json['player'] is Map ? _intOrNull((json['player'] as Map)['id']) : null;
  TeamState? get team => json['team'] is Map ? TeamState((json['team'] as Map).cast()) : null;
}

class Duel {
  Duel(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  int get round => _int(json['round']);
  int get position => _int(json['position']);

  /// `pending`, `ready_wait`, `playing`, `done`.
  String get state => _str(json['state']);

  /// `played`, `bye`, `forfeit`, `double_forfeit`.
  String? get result => json['result'] as String?;
  int? get entryA => _intOrNull(json['entry_a_id']);
  int? get entryB => _intOrNull(json['entry_b_id']);
  bool get readyA => json['ready_a'] == true;
  bool get readyB => json['ready_b'] == true;
  int? get winner => _intOrNull(json['winner_entry_id']);
  int? get matchId => _intOrNull(json['match_id']);
  int? get deadline => _intOrNull(json['deadline']);
  int get scoreA => _int(json['score_a']);
  int get scoreB => _int(json['score_b']);

  bool involves(int? entryId) => entryId != null && (entryA == entryId || entryB == entryId);
}

class TournamentState {
  TournamentState(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get code => _str(json['code']);
  String get name => _str(json['name']);
  int get version => _int(json['version']);
  int get serverNow => _int(json['server_now']);
  String get mode => _str(json['mode']);
  bool get isTeam => mode == 'team';

  /// `registration`, `running`, `finished`, `cancelled`.
  String get state => _str(json['state']);
  int? get organizerId => _intOrNull(json['organizer_id']);
  String get organizerPseudo => _str(json['organizer_pseudo']);
  String get lang => _str(json['lang']);
  String get passagesLabel => _str(json['passages_label']);
  List<Passage> get passages => Passage.list(json['passages']);
  Map<String, List<Passage>> get roundPassages => {
    for (final e in ((json['round_passages'] as Map?) ?? const {}).entries) '${e.key}': Passage.list(e.value),
  };
  Map<String, dynamic> get settings => (json['settings'] as Map?)?.cast<String, dynamic>() ?? const {};
  int get minEntries => _int(settings['min_entries'], 2);
  int get maxEntries => _int(settings['max_entries'], 2);
  int get forfeitMinutes => _int(settings['forfeit_minutes'], 10);
  int get questionCount => _int(settings['question_count']);
  int get questionSeconds => _int(settings['question_seconds']);
  int get handSeconds => _int(settings['hand_seconds']);
  int get teamMinSize => _int(settings['team_min_size'], 2);
  int get teamMaxSize => _int(settings['team_max_size'], 5);
  int get rounds => _int(json['rounds']);
  List<TournamentEntry> get entries => [for (final m in _maps(json['entries'])) TournamentEntry(m)];
  List<Duel> get duels => [for (final m in _maps(json['duels'])) Duel(m)];
  int? get winnerEntryId => _intOrNull(json['winner_entry_id']);

  TournamentEntry? entry(int? id) => entries.where((e) => e.id == id).firstOrNull;
}

class TournamentEnvelope {
  TournamentEnvelope(this.tournament, this.myEntryId, this.channel);

  final TournamentState tournament;
  final int? myEntryId;
  final String channel;

  static TournamentEnvelope parse(Map<String, dynamic> r) => TournamentEnvelope(
    TournamentState((r['tournament'] as Map).cast()),
    _intOrNull(r['my_entry_id']),
    _str(r['channel']),
  );
}

// ------------------------------------------------------------------ listes

class OpenMatch {
  OpenMatch(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get code => _str(json['code']);
  String get mode => _str(json['mode']);
  String get lang => _str(json['lang']);
  String get passagesLabel => _str(json['passages_label']);
  String get creator => _str(json['creator']);
  int get players => _int(json['players']);
  int get maxPlayers => _int(json['max_players']);
  int get questionCount => _int(json['question_count']);
}

class OpenTournament {
  OpenTournament(this.json);

  final Map<String, dynamic> json;

  int get id => _int(json['id']);
  String get code => _str(json['code']);
  String get name => _str(json['name']);
  String get mode => _str(json['mode']);
  String get state => _str(json['state']);
  String get passagesLabel => _str(json['passages_label']);
  String get organizer => _str(json['organizer']);
  int get entries => _int(json['entries']);
  int get maxEntries => _int(json['max_entries']);
  String? get winner => json['winner'] as String?;
}

class Invitation {
  Invitation(this.json);

  final Map<String, dynamic> json;

  int get teamId => _int(json['team_id']);
  String get teamName => _str(json['team_name']);
  String get captain => _str(json['captain']);
  int? get matchId => _intOrNull(json['match_id']);
  String? get matchCode => json['match_code'] as String?;
  int? get tournamentId => _intOrNull(json['tournament_id']);
  String? get tournamentName => json['tournament_name'] as String?;
}

class PastMatch {
  PastMatch(this.json);

  final Map<String, dynamic> json;

  int get matchId => _int(json['match_id']);
  String get code => _str(json['code']);
  String get mode => _str(json['mode']);
  String? get finishedAt => json['finished_at'] as String?;
  String get passagesLabel => _str(json['passages_label']);
  int get rank => _int(json['rank']);
  int get score => _int(json['score']);
  int get players => _int(json['players']);
  bool get won => json['won'] == true;
  String? get tournament => json['tournament'] as String?;
}

class ServerConfig {
  ServerConfig(this.json);

  final Map<String, dynamic> json;

  int get serverNow => _int(json['server_now']);
  String get websocketVersion => _str(json['websocket_version']);
  Map<String, dynamic> get limits => (json['limits'] as Map?)?.cast<String, dynamic>() ?? const {};
  Map<String, dynamic> get defaults => (json['defaults'] as Map?)?.cast<String, dynamic>() ?? const {};
  int get maxPlayers => _int(limits['max_players'], 10);
  int get teamMaxSize => _int(limits['team_max_size'], 5);
  int get teamMinSize => _int(limits['team_min_size'], 2);
  int get tournamentMaxEntries => _int(limits['tournament_max_entries'], 32);
  int get maxPassages => _int(limits['max_passages'], 10);
  (int, int) range(String key, (int, int) fallback) {
    final v = limits[key];
    return v is List && v.length == 2 ? (_int(v[0]), _int(v[1])) : fallback;
  }

  int defaultOf(String key, int fallback) => _int(defaults[key], fallback);
}
