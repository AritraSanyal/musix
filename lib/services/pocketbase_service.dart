import 'package:http/http.dart' as http show MultipartFile;
import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  static final pb = PocketBase('http://127.0.0.1:8090');

  static Future<void> uploadSong({
    required String title,
    required String artist,
    required List<int> audioBytes,
    required String audioName,
    required List<int> coverBytes,
    required String coverName,
  }) async {
    await pb
        .collection('songs')
        .create(
          body: {"title": title, "artist": artist},
          files: [
            http.MultipartFile.fromBytes(
              "audio",
              audioBytes,
              filename: audioName,
            ),
            http.MultipartFile.fromBytes(
              "cover",
              coverBytes,
              filename: coverName,
            ),
          ],
        );
  }

  static Future<List<RecordModel>> fetchSongs() async {
    final records = await pb.collection('songs').getFullList(sort: '-created');

    records.shuffle();
    return records;
  }
}
