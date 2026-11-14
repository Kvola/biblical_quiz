import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Refus du serveur ou incident de transport.
///
/// [code] vient du serveur (`AUTH_REQUIRED`, `HAND_TAKEN`, `FULL`…) ou de
/// l'application (`NETWORK`, `TIMEOUT`, `SERVER`) : l'interface teste le
/// code et affiche [message] (déjà rédigé par le serveur dans la langue du joueur).
class ApiException implements Exception {
  ApiException(this.code, this.message);

  final String code;
  final String message;

  bool get isAuth => code == 'AUTH_REQUIRED';
  bool get isNetwork => code == 'NETWORK' || code == 'TIMEOUT';

  @override
  String toString() => message;
}

/// Client de l'API du jeu en ligne (`/quiz-biblique/api/v1`, JSON-RPC, enveloppe `success`).
///
/// Les lectures ([read]) sont retentées une fois après une coupure réseau ;
/// les actions de jeu ([write]) jamais : un appui rejoué pourrait prendre la
/// main à la question suivante.
class ApiClient {
  ApiClient({required this.baseUrl, http.Client? httpClient, this.timeout = const Duration(seconds: 15)})
    : _http = httpClient ?? http.Client();

  final String baseUrl;
  final Duration timeout;
  final http.Client _http;

  static const apiPath = '/quiz-biblique/api/v1';

  /// Jeton porteur ; null hors connexion.
  String? token;

  /// Appelé quand le serveur répond `AUTH_REQUIRED` (session expirée ou révoquée).
  void Function()? onUnauthorized;

  int _id = 0;

  String get origin => baseUrl.replaceAll(RegExp(r'/+$'), '');

  Future<Map<String, dynamic>> read(String path, [Map<String, dynamic> params = const {}]) async {
    try {
      return await _call(path, params);
    } on ApiException catch (e) {
      if (!e.isNetwork) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return _call(path, params);
    }
  }

  Future<Map<String, dynamic>> write(String path, [Map<String, dynamic> params = const {}]) => _call(path, params);

  Future<Map<String, dynamic>> _call(String path, Map<String, dynamic> params) async {
    final uri = Uri.parse('$origin$apiPath$path');
    final headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    if (token != null) headers['Authorization'] = 'Bearer $token';
    final body = jsonEncode({'jsonrpc': '2.0', 'method': 'call', 'id': ++_id, 'params': params});
    http.Response response;
    try {
      response = await _http.post(uri, headers: headers, body: body).timeout(timeout);
    } on TimeoutException {
      throw ApiException('TIMEOUT', 'Le serveur met trop de temps à répondre.');
    } on http.ClientException {
      throw ApiException('NETWORK', 'Pas de connexion Internet.');
    }
    if (response.statusCode != 200) {
      throw ApiException('SERVER', 'Erreur du serveur (${response.statusCode}).');
    }
    final Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException('SERVER', 'Réponse illisible du serveur.');
    }
    if (decoded['error'] != null) {
      throw ApiException('SERVER', 'Erreur du serveur. Réessayez plus tard.');
    }
    final result = decoded['result'];
    if (result is! Map<String, dynamic>) {
      throw ApiException('SERVER', 'Réponse inattendue du serveur.');
    }
    if (result['success'] != true) {
      final error = (result['error'] as Map?)?.cast<String, dynamic>() ?? const {};
      final e = ApiException(
        (error['code'] ?? result['error_code'] ?? 'REFUSED').toString(),
        (error['message'] ?? result['message'] ?? 'Action impossible.').toString(),
      );
      if (e.isAuth) onUnauthorized?.call();
      throw e;
    }
    return result;
  }
}
