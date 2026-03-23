import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:musix_backend/models/playlist.dart';
import 'package:musix_backend/models/user.dart';
import 'package:musix_backend/repositories/data_store.dart';
import 'package:uuid/uuid.dart';

Future<Response> onRequest(RequestContext context) async {
  switch (context.request.method) {
    case HttpMethod.get:
      final dataStore = context.read<DataStore>();
      final playlists = dataStore.getAllPlaylists();
      return Response.json(
        body: playlists.map((p) => p.toJson()).toList(),
      );

    case HttpMethod.post:
      final user = context.read<User>();
      final dataStore = context.read<DataStore>();

      final body = await context.request.json() as Map<String, dynamic>;
      final name = body['name'] as String?;
      final description = body['description'] as String?;
      final isPublic = body['is_public'] as bool? ?? true;

      if (name == null) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Name is required'},
        );
      }

      final now = DateTime.now();
      final playlist = Playlist(
        id: const Uuid().v4(),
        name: name,
        userId: user.id,
        description: description,
        songIds: [],
        isPublic: isPublic,
        createdAt: now,
        updatedAt: now,
      );

      await dataStore.createPlaylist(playlist);

      return Response.json(
        statusCode: HttpStatus.created,
        body: playlist.toJson(),
      );

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
