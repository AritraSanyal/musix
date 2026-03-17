import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../services/pocketbase_service.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final titleController = TextEditingController();
  final artistController = TextEditingController();

  PlatformFile? audioFile;
  PlatformFile? coverFile;

  Future pickAudio() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      withData: true,
    );

    if (result != null) {
      setState(() => audioFile = result.files.first);
    }
  }

  Future pickCover() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null) {
      setState(() => coverFile = result.files.first);
    }
  }

  Future upload() async {
    if (audioFile == null || coverFile == null) return;

    await PocketBaseService.uploadSong(
      title: titleController.text,
      artist: artistController.text,
      audioBytes: audioFile!.bytes!,
      audioName: audioFile!.name,
      coverBytes: coverFile!.bytes!,
      coverName: coverFile!.name,
    );

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Uploaded!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Music")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: artistController,
              decoration: const InputDecoration(labelText: "Artist"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickAudio,
              child: const Text("Pick Audio"),
            ),
            ElevatedButton(
              onPressed: pickCover,
              child: const Text("Pick Cover"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: upload, child: const Text("Upload")),
          ],
        ),
      ),
    );
  }
}
