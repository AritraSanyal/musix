import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:uuid/uuid.dart';
import 'package:musix_backend/models/playlist.dart';
import 'package:musix_backend/models/user.dart';
import 'package:musix_backend/repositories/data_store.dart';

Future<Response> onRequest(RequestContext context) async {
  final dataStore = context.read<DataStore>();

  switch (context.request.method) {
    case HttpMethod.get:
      final userId = context.request.uri.queryParameters['userId'];
      final playlists = dataStore.getAllPlaylists(userId: userId);
      return Response.json(body: playlists.map((p) => p.toJson()).toList());

    case HttpMethod.post:
      final user = context.read<User>();
      final body = await context.request.json() as Map<String, dynamic>;
      final name = body['name'] as String?;

      if (name == null) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {'error': 'Missing required fields'},
        );
      }

      final now = DateTime.now();
      final playlist = Playlist(
        id: const Uuid().v4(),
        name: name,
        description: body['description'] as String?,
        coverUrl: body['cover_url'] as String?,
        userId: user.id,
        songIds: [],
        isPublic: body['is_public'] as bool? ?? true,
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
