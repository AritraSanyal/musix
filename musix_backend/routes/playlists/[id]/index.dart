import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:musix_backend/models/user.dart';
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

  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(body: playlist.toJson());

    case HttpMethod.put:
      final user = context.read<User>();
      if (playlist.userId != user.id) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {'error': 'Not authorized'},
        );
      }
      final body = await context.request.json() as Map<String, dynamic>;
      final updated = playlist.copyWith(
        name: body['name'] as String? ?? playlist.name,
        description: body['description'] as String? ?? playlist.description,
        coverUrl: body['cover_url'] as String? ?? playlist.coverUrl,
        isPublic: body['is_public'] as bool? ?? playlist.isPublic,
        updatedAt: DateTime.now(),
      );
      await dataStore.updatePlaylist(updated);
      return Response.json(body: updated.toJson());

    case HttpMethod.delete:
      final user = context.read<User>();
      if (playlist.userId != user.id) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {'error': 'Not authorized'},
        );
      }
      await dataStore.deletePlaylist(id);
      return Response.json(body: {'message': 'Playlist deleted'});

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}
