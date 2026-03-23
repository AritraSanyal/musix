import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/song_model.dart';

class SongsProvider with ChangeNotifier {
  List<Song> _songs = [];
  bool _isLoading = false;
  String? _error;

  List<Song> get songs => _songs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSongs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.getSongs();
      _songs = data.map((json) => Song.fromJson(json)).toList();
      _songs.shuffle();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchSongs(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.searchSongs(query);
      _songs = data.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createSong({
    required String title,
    required String artist,
    String? audioUrl,
    String? coverUrl,
    int? durationSeconds,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await ApiService.createSong(
        title: title,
        artist: artist,
        audioUrl: audioUrl,
        coverUrl: coverUrl,
        durationSeconds: durationSeconds,
      );
      final song = Song.fromJson(data);
      _songs.insert(0, song);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
