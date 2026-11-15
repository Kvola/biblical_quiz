import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models.dart';
import 'push.dart';
import 'realtime.dart';
import 'service.dart';

/// Serveur du jeu en ligne ; fixé dans `main()` (même serveur que les mises à jour).
final serverUrlProvider = Provider<String>((ref) => 'https://iyf.ebng.world');

final onlineServiceProvider = Provider<OnlineService>((ref) {
  final service = OnlineService(server: ref.watch(serverUrlProvider));
  ref.onDispose(service.hub.dispose);
  return service;
});

/// Le compte en ligne : null = pas connecté. Chargé à la première ouverture de « Jouer ».
final onlineMeProvider = AsyncNotifierProvider<OnlineMeNotifier, OnlineMe?>(OnlineMeNotifier.new);

class OnlineMeNotifier extends AsyncNotifier<OnlineMe?> {
  @override
  Future<OnlineMe?> build() async {
    final service = ref.watch(onlineServiceProvider);
    service.onSignedOut = () => state = const AsyncData(null);
    return service.me();
  }

  void set(OnlineMe? me) => state = AsyncData(me);

  Future<void> refresh() async {
    final service = ref.read(onlineServiceProvider);
    try {
      state = AsyncData(await service.me());
    } catch (e, st) {
      // Un réseau absent ne déconnecte pas : on garde le dernier profil connu.
      if (state.value == null) state = AsyncError(e, st);
    }
  }

  Future<void> signOut() async {
    final deviceToken = await ref.read(pushProvider).currentToken();
    await ref.read(onlineServiceProvider).signOut(deviceToken: deviceToken);
    state = const AsyncData(null);
  }
}

/// Notifications push ; fixé dans `main()` sur Android, sans effet ailleurs (tests, web).
final pushProvider = Provider<PushService>((ref) => NoPushService());

/// Inscrit ce téléphone aux notifications si la personne est connectée au jeu.
/// Jamais bloquant : réessayé à la prochaine ouverture.
Future<void> registerPushDevice(OnlineService service, PushService push, [String? token]) async {
  try {
    if (!await service.hasSession()) return;
    final t = token ?? await push.token();
    if (t != null) await service.registerDevice(t);
  } catch (_) {}
}

final serverConfigProvider = FutureProvider<ServerConfig>((ref) => ref.watch(onlineServiceProvider).config());

/// Événements personnels du joueur (invitation, duel à jouer, revanche…), application ouverte.
final playerEventsProvider = StreamProvider<RealtimeEvent>((ref) {
  final channel = ref.watch(onlineMeProvider.select((me) => me.value?.player?.channel));
  if (channel == null || channel.isEmpty) return const Stream.empty();
  final service = ref.watch(onlineServiceProvider);
  final unsubscribe = service.hub.subscribe(channel);
  ref.onDispose(unsubscribe);
  return service.hub.events.where((e) => e.type == 'bq_player');
});
