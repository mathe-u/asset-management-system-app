import 'dart:convert';
import 'dart:typed_data';
import 'package:assets_app/models/asset.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String _baseUrl = 'http://192.168.0.109:8000/api';
  static String? _token;
  static String? _username;
  static String? _password;

  static void setBaseUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      _baseUrl = url;
    }
  }

  static void setToken(String token) {
    _token = token;
  }

  static void setUsername(String username) {
    _username = username;
  }

  static void setPassword(String password) {
    _password = password;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $_token',
  };

  static Future<String> login() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _username, 'password': _password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final String token = data['token'];
        return token;
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error on login: $e');
    }
  }

  static Future<List<Asset>> getAssets() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/assets/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> assetsJson = data['assets'];
        return assetsJson.map((json) => Asset.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load assets: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching assets: $e');
    }
  }

  static Future<Uint8List> downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to download image: $url');
    }
  }
}
