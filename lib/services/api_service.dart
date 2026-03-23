import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.95.65.227:8080';
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static void clearToken() {
    _token = null;
  }

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Auth
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String username,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Login failed');
  }

  // Songs
  static Future<List<dynamic>> getSongs() async {
    final res = await http.get(Uri.parse('$baseUrl/songs'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to fetch songs');
  }

  static Future<dynamic> getSong(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/songs/$id'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Song not found');
  }

  static Future<List<dynamic>> searchSongs(String query) async {
    final res = await http.get(Uri.parse('$baseUrl/songs/search?q=$query'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Search failed');
  }

  static Future<dynamic> createSong({
    required String title,
    required String artist,
    String? audioUrl,
    String? coverUrl,
    int? durationSeconds,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/songs/create'),
      headers: _headers,
      body: jsonEncode({
        'title': title,
        'artist': artist,
        'audio_url': audioUrl,
        'cover_url': coverUrl,
        'duration_seconds': durationSeconds,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Failed to create song');
  }

  // Playlists
  static Future<List<dynamic>> getPlaylists() async {
    final res = await http.get(Uri.parse('$baseUrl/playlists'));
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to fetch playlists');
  }

  static Future<dynamic> createPlaylist({
    required String name,
    String? description,
    bool isPublic = true,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/playlists'),
      headers: _headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'is_public': isPublic,
      }),
    );
    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to create playlist');
  }

  static Future<dynamic> updatePlaylist(
    String id, {
    String? name,
    String? description,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/playlists/$id'),
      headers: _headers,
      body: jsonEncode({
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      }),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to update playlist');
  }

  static Future<void> deletePlaylist(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/playlists/$id'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to delete playlist');
    }
  }

  // Favorites
  static Future<List<dynamic>> getFavorites() async {
    final res = await http.get(
      Uri.parse('$baseUrl/favorites'),
      headers: _headers,
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Failed to fetch favorites');
  }

  static Future<void> toggleFavorite(String songId) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorites/$songId'),
      headers: _headers,
    );
    if (res.statusCode != 200) {
      throw Exception('Failed to toggle favorite');
    }
  }

  // File Upload
  static Future<Map<String, dynamic>> uploadAudio(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/audio'),
    );
    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final res = await request.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      return jsonDecode(body);
    }
    throw Exception('Failed to upload audio');
  }

  static Future<Map<String, dynamic>> uploadCover(String filePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/cover'),
    );
    request.headers['Authorization'] = 'Bearer $_token';
    request.files.add(await http.MultipartFile.fromPath('file', filePath));

    final res = await request.send();
    final body = await res.stream.bytesToString();
    if (res.statusCode == 200) {
      return jsonDecode(body);
    }
    throw Exception('Failed to upload cover');
  }
}
