import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../lib/core/api.dart';
import '../lib/core/config.dart';

void main() async {
  print('Smoke testing API...');
  try {
    final healthRes = await http.get(Uri.parse('$kApiBase/health'));
    print('Health GET status: ${healthRes.statusCode}');
    print('Health GET body: ${healthRes.body}');
    
    final client = ApiClient();
    await client.login('test@test.com', 'wrongpassword123');
    print('Error: Login should have failed');
    exit(1);
  } on ApiException catch (e) {
    print('Successfully caught ApiException during login: ${e.message}');
    try {
      final json = jsonDecode(e.message);
      print('Parsed JSON error: $json');
    } catch (_) {
      print('Response was not JSON');
    }
  } catch (e) {
    print('Caught unexpected error: $e');
  }
}