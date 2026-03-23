import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:musix_backend/repositories/data_store.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final dataStore = context.read<DataStore>();
  final playlist = dataStore.getPlaylistById(id);

  if (playlist == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'Playlist not found'},
    );
  }

  if (context.request.method == HttpMethod.post) {
    final body = await context.request.json() as Map<String, dynamic>;
    final songId = body['song_id'] as String?;

    if (songId == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {'error': 'Missing song_id'},
      );
    }

    await dataStore.addSongToPlaylist(id, songId);
    return Response.json(body: {'message': 'Song added to playlist'});
  }

  return Response(statusCode: HttpStatus.methodNotAllowed);
}
