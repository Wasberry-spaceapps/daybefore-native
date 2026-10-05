
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionRequired implements Exception {}
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
}

class ApiClient {
  static const baseUrl = 'https://daybefore-backend.officialmutairu.workers.dev/api';
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> register(String email, String pwHash, String saltB64) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: _headers,
        body: jsonEncode({'email': email, 'passwordHash': pwHash, 'salt': saltB64}));
    if (res.statusCode != 200) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> login(String email, String pwHash) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'passwordHash': pwHash}));
    if (res.statusCode != 200) throw ApiException(res.body);
    return jsonDecode(res.body);
  }

  Future<List<Map<String, dynamic>>> pullSync(String collection, int since) async {
    final res = await http.get(Uri.parse('$baseUrl/sync/$collection?since=$since'), headers: _headers);
    if (res.statusCode == 403) throw SubscriptionRequired();
    if (res.statusCode != 200) throw ApiException(res.body);
    return List<Map<String, dynamic>>.from(jsonDecode(res.body)['items'] ?? []);
  }

  Future<void> pushSync(String collection, List<Map<String, dynamic>> items) async {
    final res = await http.post(Uri.parse('$baseUrl/sync/$collection'),
        headers: _headers, body: jsonEncode({'items': items}));
    if (res.statusCode == 403) throw SubscriptionRequired();
  }
}
