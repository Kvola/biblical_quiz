import 'package:web_socket_channel/web_socket_channel.dart';

/// Navigateur : l'en-tête `Origin` est ajouté par le navigateur lui-même.
WebSocketChannel connectWebSocket(Uri uri, String origin) => WebSocketChannel.connect(uri);
