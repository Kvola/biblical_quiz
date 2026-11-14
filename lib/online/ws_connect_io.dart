import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Téléphone : Odoo refuse une connexion sans en-tête `Origin` (le navigateur, lui, l'envoie seul).
WebSocketChannel connectWebSocket(Uri uri, String origin) =>
    IOWebSocketChannel.connect(uri, headers: {'Origin': origin}, pingInterval: const Duration(seconds: 25));
