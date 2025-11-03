import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../models/asset.dart';
import '../models/user.dart';
import '../models/asset_image.dart';

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

  static Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));

        return (data as List<dynamic>)
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error fetching user: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user: ${e.toString()}');
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

  static Future<Asset> createAsset(
    Asset assetData,
    List<String> imageFilePaths,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/assets/'),
        // headers: {'Content-Type': 'multipart/form-data', 'Authorization': 'Token $_token',},
        // body: json.encode(asset.toJson()),
      );

      request.headers.addAll({'Authorization': 'Token $_token'});

      request.fields['name'] = assetData.name;
      request.fields['category'] = assetData.category;
      request.fields['status'] = assetData.status;
      request.fields['custodian'] = assetData.custodian;
      request.fields['location'] = assetData.location;

      for (var path in imageFilePaths) {
        request.files.add(await http.MultipartFile.fromPath('images', path));
      }

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);

        final List<AssetImage> newImages = (data['images'] as List)
            .map((url) => AssetImage(id: data['id'], url: url as String))
            .toList();
        return Asset(
          name: assetData.name,
          category: assetData.category,
          status: assetData.status,
          custodian: assetData.custodian,
          location: assetData.location,
          code: data['code'],
          barcode: data['barcode'],
          images: newImages,
        );
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message']);
      }
    } catch (e) {
      throw Exception('Error creating asset: $e');
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

  static Future<List<String>> getStatusChoices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/status-choices/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final statusChoices = data['status_choices'];
        return statusChoices.map((json) => json['label'] as String).toList();
      } else {
        throw Exception('${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching status: $e');
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
        throw Exception('Unexpected error');
      }
    } catch (e) {
      throw Exception('Error fetching categories: ${e.toString()}');
    }
  }

  static Future<List<String>> getLocations() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/locations/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> locations = data['locations'];
        return locations.map((json) => json['name'] as String).toList();
      } else {
        throw Exception('Unexpected error');
      }
    } catch (e) {
      throw Exception('Error fetching locations: ${e.toString()}');
    }
  }
}
