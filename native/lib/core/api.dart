import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'config.dart';

class SubscriptionRequired implements Exception {}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class NetworkFailure implements Exception {
  @override
  String toString() => "Can't reach Day Before. Check your connection and try again.";
}

class ApiClient {
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    try {
      return await http.post(
        Uri.parse('$kApiBase$path'),
        headers: _headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw NetworkFailure();
    } on TimeoutException {
      throw NetworkFailure();
    } on HandshakeException {
      throw NetworkFailure();
    } on http.ClientException {
      throw NetworkFailure();
    }
  }

  Future<http.Response> _get(String path) async {
    try {
      return await http.get(
        Uri.parse('$kApiBase$path'),
        headers: _headers,
      ).timeout(const Duration(seconds: 15));
    } on SocketException {
      throw NetworkFailure();
    } on TimeoutException {
      throw NetworkFailure();
    } on HandshakeException {
      throw NetworkFailure();
    } on http.ClientException {
      throw NetworkFailure();
    }
  }

  Future<Map<String, dynamic>> register(String email, String pwHash, String saltB64,
      {String? wrappedKeyPwd, String? wrappedKeyRecovery}) async {
    final body = <String, dynamic>{'email': email, 'passwordHash': pwHash, 'salt': saltB64};
    if (wrappedKeyPwd != null) body['wrappedKeyPwd'] = wrappedKeyPwd;
    if (wrappedKeyRecovery != null) body['wrappedKeyRecovery'] = wrappedKeyRecovery;
    final res = await _post('/auth/register', body);
    if (res.statusCode != 200) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  Future<void> migrateV2(String wrappedKeyPwd, String wrappedKeyRecovery) async {
    final res = await _post('/auth/migrate-v2', {
      'wrappedKeyPwd': wrappedKeyPwd,
      'wrappedKeyRecovery': wrappedKeyRecovery,
    });
    if (res.statusCode != 200) throw ApiException(res.body);
  }

  Future<Map<String, dynamic>> login(String email, String pwHash) async {
    final res = await _post('/auth/login', {'email': email, 'passwordHash': pwHash});
    if (res.statusCode != 200) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  Future<List<Map<String, dynamic>>> pullSync(String collection, int since) async {
    final res = await _get('/sync/$collection?since=$since');
    if (res.statusCode == 403) throw SubscriptionRequired();
    if (res.statusCode != 200) throw ApiException(res.body);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body)['items'] ?? []);
  }

  Future<void> pushSync(String collection, List<Map<String, dynamic>> items) async {
    final res = await _post('/sync/$collection', {'items': items});
    if (res.statusCode == 403) throw SubscriptionRequired();
    if (res.statusCode != 200) throw ApiException(res.body);
  }
}
