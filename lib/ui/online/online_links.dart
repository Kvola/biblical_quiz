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

/// Autour de l'application : ouvre les liens d'invitation et montre les
/// événements du joueur (invitation, duel à jouer, revanche) pendant qu'elle est ouverte.
class OnlineLinkHandler extends ConsumerStatefulWidget {
  const OnlineLinkHandler({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<OnlineLinkHandler> createState() => _OnlineLinkHandlerState();
}

class _OnlineLinkHandlerState extends ConsumerState<OnlineLinkHandler> {
  StreamSubscription<Uri>? _links;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Version web : le lien du serveur ouvre la page avec ?join=… ou ?watch=….
      WidgetsBinding.instance.addPostFrameCallback((_) => _handle(Uri.base));
    } else {
      _links = ref.read(gameLinksProvider).listen(_handle, onError: (_) {});
    }
  }

  @override
  void dispose() {
    _links?.cancel();
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

  @override
  Widget build(BuildContext context) {
    ref.listen(playerEventsProvider, (_, next) {
      final e = next.value;
      if (e == null) return;
      final l = context.l10n;
      final p = e.payload;
      final (String text, VoidCallback? action) = switch (p['event']) {
        'team_invitation' => (l.eventInvitation('${p['captain']}', '${p['team_name']}'), () => OnlineHomeScreen.open(context)),
        'team_request' => (l.eventRequest('${p['pseudo']}'), null),
        'duel_ready' => (
          l.eventDuelReady,
          () => TournamentScreen.open(context, (p['tournament_id'] as num).toInt()),
        ),
        'rematch' => (l.eventRematch('${p['code']}'), () => joinByCode(context, ref, code: '${p['code']}')),
        _ => ('${p['body'] ?? ''}', null),
      };
      if (text.isEmpty) return;
      unawaited(ref.read(onlineMeProvider.notifier).refresh());
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
    });
    return widget.child;
  }
}
