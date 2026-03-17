import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/pocketbase_service.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Musix")),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.upload),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UploadScreen()),
          );
        },
      ),
      body: FutureBuilder(
        future: PocketBaseService.fetchSongs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final songs = snapshot.data!;

          return GridView.builder(
            itemCount: songs.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
            ),
            itemBuilder: (context, index) {
              final song = songs[index];

              final coverUrl = PocketBaseService.pb.files
                  .getUrl(song, song.data['cover'])
                  .toString();

              final audioUrl = PocketBaseService.pb.files
                  .getUrl(song, song.data['audio'])
                  .toString();

              return Card(
                child: Column(
                  children: [
                    Image.network(coverUrl, height: 120, fit: BoxFit.cover),
                    Text(song.data['title']),
                    Text(song.data['artist']),
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () async {
                        await player.setUrl(audioUrl);
                        player.play();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
