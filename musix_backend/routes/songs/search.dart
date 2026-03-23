import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:musix_backend/repositories/data_store.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final uri = context.request.uri;
  final query = uri.queryParameters['q'] ?? '';

  final dataStore = context.read<DataStore>();
  final songs = query.isEmpty
      ? dataStore.getAllSongs()
      : dataStore.searchSongs(query);

  return Response.json(body: songs.map((s) => s.toJson()).toList());
}
