import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../online/online_providers.dart';
import '../common.dart';
import 'online_home_screen.dart';
import 'projection_screen.dart';
import 'tournament_screen.dart';

/// Liens reçus par l'application (Android : app_links), fixés dans `main()` ; aucun dans les tests.
final gameLinksProvider = Provider<Stream<Uri>>((ref) => const Stream.empty());

/// Code de partie contenu dans un lien : `quizbiblique://join/ABC123`,
/// `…/quiz-biblique/rejoindre/ABC123`, ou `?join=ABC123` (version web).
/// [watch] : `?watch=ABC123` (écran de projection).
({String? join, String? watch}) parseGameLink(Uri uri) {
  String? clean(String? v) {
    final c = (v ?? '').toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    return c.length == 6 ? c : null;
  }

  final join = uri.queryParameters['join'];
  final watch = uri.queryParameters['watch'];
  if (join != null || watch != null) return (join: clean(join), watch: clean(watch));
  final segments = [if (uri.scheme == 'quizbiblique' && uri.host.isNotEmpty) uri.host, ...uri.pathSegments];
  final i = segments.indexWhere((s) => s == 'join' || s == 'rejoindre');
  if (i >= 0 && i + 1 < segments.length) return (join: clean(segments[i + 1]), watch: null);
  return (join: null, watch: null);
}

/// Un même événement arrive deux fois quand l'application est ouverte :
/// par le canal temps réel et par la notification push. Clé pour n'en montrer qu'un.
String playerEventKey(Map<String, dynamic> p) => [
  for (final k in ['event', 'team_id', 'tournament_id', 'duel_id', 'match_id', 'player_id', 'code', 'from_match_id'])
    '${p[k] ?? ''}',
].join('|');

int? _id(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

/// Autour de l'application : ouvre les liens d'invitation, les notifications
/// touchées, et montre les événements du joueur (invitation, duel à jouer,
/// revanche) pendant qu'elle est ouverte.
class OnlineLinkHandler extends ConsumerStatefulWidget {
  const OnlineLinkHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnlineLinkHandler> createState() => _OnlineLinkHandlerState();
}

class _OnlineLinkHandlerState extends ConsumerState<OnlineLinkHandler> {
  final _subs = <StreamSubscription<Object>>[];

  /// Événements déjà montrés (clé → instant), pour ignorer le doublon.
  final _seen = <String, DateTime>{};

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Version web : le lien du serveur ouvre la page avec ?join=… ou ?watch=….
      WidgetsBinding.instance.addPostFrameCallback((_) => _handle(Uri.base));
    } else {
      _subs.add(ref.read(gameLinksProvider).listen(_handle, onError: (_) {}));
    }
    final push = ref.read(pushProvider);
    final service = ref.read(onlineServiceProvider);
    _subs
      ..add(push.opened.listen(_openEvent))
      ..add(push.received.listen(_showEvent))
      ..add(push.tokenRefreshed.listen((t) => registerPushDevice(service, push, t)));
    push.ready.then((_) {
      // Déjà connecté : (ré)inscription du téléphone, sans rien demander d'autre.
      registerPushDevice(service, push);
      final initial = push.takeInitial();
      if (initial != null && mounted) WidgetsBinding.instance.addPostFrameCallback((_) => _openEvent(initial));
    });
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  Future<void> _handle(Uri uri) async {
    final link = parseGameLink(uri);
    if (!mounted || (link.join == null && link.watch == null)) return;
    if (link.watch != null) {
      await ProjectionScreen.open(context, code: link.watch);
      return;
    }
    final me = await ref.read(onlineMeProvider.future).catchError((_) => null);
    if (!mounted) return;
    if (me?.player == null) {
      // Pas encore joueur : l'accueil du jeu en ligne explique comment le devenir.
      await OnlineHomeScreen.open(context);
      return;
    }
    await joinByCode(context, ref, code: link.join);
  }

  /// Ce qu'on ouvre pour un événement, ou null.
  VoidCallback? _action(Map<String, dynamic> p) {
    final tournament = _id(p['tournament_id']);
    final code = '${p['code'] ?? ''}';
    return switch (p['event']) {
      'team_invitation' => () => OnlineHomeScreen.open(context),
      'rematch' when code.isNotEmpty => () => joinByCode(context, ref, code: code),
      'duel_ready' || 'tournament_eliminated' || 'tournament_won' || 'tournament_cancelled' ||
      'tournament_team_dropped' when tournament != null => () => TournamentScreen.open(context, tournament),
      'team_request' => tournament != null
          ? () => TournamentScreen.open(context, tournament)
          : () => OnlineHomeScreen.open(context),
      _ => null,
    };
  }

  /// Notification touchée : on ouvre directement ce qu'elle annonce.
  void _openEvent(Map<String, dynamic> p) {
    if (!mounted) return;
    _seen[playerEventKey(p)] = DateTime.now();
    unawaited(ref.read(onlineMeProvider.notifier).refresh());
    _action(p)?.call();
  }

  /// Événement reçu application ouverte : un bandeau propose de l'ouvrir.
  void _showEvent(Map<String, dynamic> p) {
    if (!mounted) return;
    final now = DateTime.now();
    _seen.removeWhere((_, at) => now.difference(at) > const Duration(minutes: 2));
    final key = playerEventKey(p);
    if (_seen.containsKey(key)) return;
    _seen[key] = now;
    final l = context.l10n;
    final text = switch (p['event']) {
      'team_invitation' => l.eventInvitation('${p['captain']}', '${p['team_name']}'),
      'team_request' => l.eventRequest('${p['pseudo']}'),
      'duel_ready' => l.eventDuelReady,
      'rematch' => l.eventRematch('${p['code']}'),
      _ => '${p['body'] ?? ''}',
    };
    if (text.isEmpty) return;
    unawaited(ref.read(onlineMeProvider.notifier).refresh());
    final action = _action(p);
    // Jamais persistante : elle masquerait le bouton « Je réponds ! » pendant un match.
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        persist: false,
        action: action == null ? null : SnackBarAction(label: l.eventSee, onPressed: action),
      ));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(playerEventsProvider, (_, next) {
      final e = next.value;
      if (e != null) _showEvent(e.payload);
    });
    // Connexion au jeu (ou profil chargé) : inscrire ce téléphone aux notifications.
    ref.listen(onlineMeProvider.select((me) => me.value?.player?.id), (before, now) {
      if (now != null && now != before) {
        unawaited(registerPushDevice(ref.read(onlineServiceProvider), ref.read(pushProvider)));
      }
    });
    return widget.child;
  }
}
