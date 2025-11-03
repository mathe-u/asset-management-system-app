import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../models/asset.dart';
import '../models/user.dart';

class ApiService {
  static String _baseUrl = 'http://192.168.0.112:8000/api';
  static String _token = '';
  static String _username = '';
  static String _password = '';
  static int _userId = 0;
  // static String _userEmail = '';

  static void setBaseUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      _baseUrl = url;
    }
  }

  static void setToken(String token) {
    _token = token;
  }

  static void setCredentials(String username, String password) {
    _username = username;
    _password = password;
  }

  static void setUserId(int id) {
    _userId = id;
  }

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Token $_token',
  };

  static Future<Map<String, dynamic>> login() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _username, 'password': _password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        // final String token = data['token'];
        // final int userId = data['user_id'];
        // final String email = data['email'];
        // _userId = userId;
        // _userEmail = email;
        return data;
      } else if (response.statusCode == 400) {
        throw Exception('Usuario ou senha incorretos');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error on login: $e');
    }
  }

  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/logout/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        _token = '';
        _userId = 0;
        // _userEmail = '';
      } else {}
    } catch (e) {
      throw Exception('Error on logout: $e');
    }
  }

  static Future<User> getUserById(int? userId) async {
    try {
      if (_token == '') {
        throw Exception('Token nao configurado');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/users/${userId ?? _userId}/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        return User.fromJson(data);
      } else {
        throw Exception('Error fetching user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: ${e.toString()}');
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

  static Future<Asset> getAssetByCode(String code) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/assets/$code/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Asset.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Asset not found');
      } else {
        throw Exception('Failed to load asset: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching asset: $e');
    }
  }

  static Future<void> deleteAsset(String code) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/assets/$code/'),
        headers: _headers,
      );

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorBody = response.body.isNotEmpty
            ? json.decode(utf8.decode(response.bodyBytes))
            : {'message': 'Status code: ${response.statusCode}'};
        throw Exception(errorBody['message'] ?? 'Failed to delete asset');
      }
    } catch (e) {
      throw Exception('Error deleting asset: $e');
    }
  }

  static Future<List<String>> printAssets(List<String> assetCodes) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/assets/print/'),
        headers: _headers,
        body: json.encode({'asset_codes': assetCodes}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return List<String>.from(data['assets']);
      } else {
        final errorBody = json.decode(utf8.decode(response.bodyBytes));
        throw Exception(errorBody['message'] ?? 'Fail to comunicate server');
      }
    } catch (e) {
      throw Exception('Error printing assets: $e');
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

  static Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/categories/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> categories = data['categories'];
        return categories.map((json) => json['name']).toList();
      } else if (response.statusCode == 401) {
        throw Exception('No credentials');
      } else {
        throw Exception('Erro');
      }
    } catch (e) {
      throw Exception('Error fetching categories: ${e.toString()}');
    }
  }
}
