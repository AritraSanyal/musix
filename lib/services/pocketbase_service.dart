import 'package:http/http.dart';
import 'package:pocketbase/pocketbase.dart';

class PocketBaseService {
  static final pb = PocketBase('http://10.0.2.2:8090');

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
            MultipartFile.fromBytes("audio", audioBytes, filename: audioName),
            MultipartFile.fromBytes("cover", coverBytes, filename: coverName),
          ],
        );
  }

  static Future<List<RecordModel>> fetchSongs() async {
    final records = await pb.collection('songs').getFullList(sort: '-created');

    records.shuffle();
    return records;
  }
}
