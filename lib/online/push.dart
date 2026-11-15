/// Notifications push (Firebase Cloud Messaging) du jeu en ligne.
///
/// Accessoires : sans Firebase (pas de services Google Play, pas de réseau,
/// autorisation refusée), le jeu fonctionne comme avant ; les événements
/// arrivent alors par le canal temps réel quand l'application est ouverte.
/// Seules les personnes connectées au jeu en ligne sont inscrites.
///
/// Jeton : on garde `getToken()` / `onTokenRefresh`, signalés obsolètes par
/// firebase_messaging 17 au profit de `register()` / `onRegistered` (identifiant
/// d'installation) ; le serveur (push_notification_hub) envoie à un jeton FCM
/// classique, comme pour toutes les applications Kvola.
// ignore_for_file: deprecated_member_use
library;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Données d'une notification : le même contenu que l'événement temps réel
/// (`event`, `tournament_id`, `code`…), en chaînes de caractères.
typedef PushData = Map<String, dynamic>;

PushData _data(RemoteMessage m) => {
  ...m.data,
  'title': m.notification?.title ?? '',
  'body': m.notification?.body ?? '',
};

class PushService {
  final _opened = StreamController<PushData>.broadcast();
  final _received = StreamController<PushData>.broadcast();
  final _tokens = StreamController<String>.broadcast();
  bool _ready = false;
  PushData? _initial;
  final _done = Completer<void>();

  /// Terminé quand l'initialisation est finie (réussie ou non) : rien n'attend
  /// Firebase avant le premier écran.
  Future<void> get ready => _done.future;

  /// Notification touchée (application en arrière-plan ou fermée).
  Stream<PushData> get opened => _opened.stream;

  /// Notification reçue pendant que l'application est à l'écran (rien ne s'affiche seul).
  Stream<PushData> get received => _received.stream;

  /// Nouveau jeton d'appareil (Firebase le renouvelle parfois).
  Stream<String> get tokenRefreshed => _tokens.stream;

  /// Notification qui a ouvert l'application (lue une seule fois).
  PushData? takeInitial() {
    final e = _initial;
    _initial = null;
    return e;
  }

  Future<void> init() async {
    try {
      await Firebase.initializeApp(options: firebaseOptions);
      FirebaseMessaging.onMessage.listen((m) => _received.add(_data(m)));
      FirebaseMessaging.onMessageOpenedApp.listen((m) => _opened.add(_data(m)));
      FirebaseMessaging.instance.onTokenRefresh.listen(_tokens.add);
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _initial = _data(initial);
      _ready = true;
    } catch (e) {
      debugPrint('Notifications indisponibles : $e');
    } finally {
      if (!_done.isCompleted) _done.complete();
    }
  }

  Future<String?>? _pending;

  /// Demande l'autorisation (Android 13+) puis renvoie le jeton de l'appareil, ou null.
  /// Deux demandes simultanées (démarrage, connexion) partagent la même réponse :
  /// Android refuse une seconde demande d'autorisation pendant la première.
  Future<String?> token() => _pending ??= _token().whenComplete(() => _pending = null);

  Future<String?> _token() async {
    await ready;
    if (!_ready) return null;
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Jeton de notification indisponible : $e');
      return null;
    }
  }

  /// Jeton actuel sans rien demander (pour la déconnexion).
  Future<String?> currentToken() async {
    if (!_done.isCompleted || !_ready) return null;
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (_) {
      return null;
    }
  }
}

/// Pour les tests, le web et les plateformes sans Firebase : ne fait rien.
class NoPushService extends PushService {
  @override
  Future<void> get ready async {}

  @override
  Future<void> init() async {}

  @override
  Future<String?> token() async => null;

  @override
  Future<String?> currentToken() async => null;
}
