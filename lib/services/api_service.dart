import 'dart:convert';
import 'dart:typed_data';
import 'package:assets_app/models/asset.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String _baseUrl = 'http://127.0.0.1:8000/api';
  static String? _token;

  static void setBaseUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      _baseUrl = url;
    }
  }

  static void setToken(String token) {
    _token = token;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $_token',
  };

  static Future<List<dynamic>> getAssets() async {
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
