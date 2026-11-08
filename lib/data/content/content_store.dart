import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:huntube_app/domain/models/file_data.dart';
import 'package:huntube_app/domain/models/part_collection.dart';
import 'package:huntube_app/domain/models/part_files.dart';

/// Injectable transport. Implementations must enforce [maxBytes].
typedef ContentFetcher = Future<List<int>> Function(Uri uri, int maxBytes);

const remoteIdMinimum = 1000000;
const maxCatalogBytes = 1024 * 1024;
const maxSoundBytes = 50 * 1024 * 1024;
const maxTotalSoundBytes = 500 * 1024 * 1024;

class RemoteSound {
  const RemoteSound({
    required this.id,
    required this.title,
    required this.driveFileId,
    required this.sha256,
    required this.bytes,
  });
  final int id;
  final String title;
  final String driveFileId;
  final String sha256;
  final int bytes;

  String get filename => '${id}_$sha256.mp3';
  Uri get downloadUri => Uri.https('drive.google.com', '/uc', {
    'export': 'download',
    'id': driveFileId,
  });
}

class RemotePart {
  const RemotePart({
    required this.id,
    required this.title,
    required this.collection,
    required this.sounds,
  });
  final int id;
  final String title;
  final PartCollection collection;
  final List<RemoteSound> sounds;
}

class RemoteCatalog {
  const RemoteCatalog(this.parts, {this.collections = const []});
  final List<RemotePart> parts;
  final List<PartCollection> collections;
  Iterable<RemoteSound> get sounds => parts.expand((part) => part.sounds);
}

/// Parses untrusted data before it can influence paths or database IDs.
RemoteCatalog parseRemoteCatalog(String source) {
  if (utf8.encode(source).length > maxCatalogBytes) {
    throw const FormatException('Content catalog is too large');
  }
  // Google Docs plain-text exports may begin with a UTF-8 BOM.
  final json = jsonDecode(
    source.startsWith('\uFEFF') ? source.substring(1) : source,
  );
  if (json is! Map<String, dynamic> ||
      json['schemaVersion'] != 1 ||
      json['parts'] is! List) {
    throw const FormatException('Unsupported content catalog');
  }
  final collectionsByName = {
    for (final collection in PartCollection.values) collection.name: collection,
  };
  final remoteCollections = <PartCollection>[];
  final declarations = json['collections'] ?? [];
  if (declarations is! List || declarations.length > 500) {
    throw const FormatException('Invalid collection declarations');
  }
  for (final value in declarations) {
    final declaration = _object(value);
    final id = _text(declaration['id']);
    if (!RegExp(r'^[a-z][a-z0-9_]{0,63}$').hasMatch(id) ||
        collectionsByName.containsKey(id)) {
      throw const FormatException('Invalid or duplicate collection ID');
    }
    final collection = PartCollection(id, _text(declaration['title']));
    collectionsByName[id] = collection;
    remoteCollections.add(collection);
  }
  final partIds = <int>{};
  final soundIds = <int>{};
  final parts = <RemotePart>[];
  var totalBytes = 0;
  for (final value in json['parts'] as List) {
    final part = _object(value);
    final id = _id(part['id']);
    if (!partIds.add(id)) throw const FormatException('Duplicate part ID');
    final collectionName = _text(part['collection']);
    final collection = collectionsByName[collectionName];
    if (collection == null || part['sounds'] is! List) {
      throw const FormatException('Invalid content collection or sounds');
    }
    final sounds = <RemoteSound>[];
    for (final value in part['sounds'] as List) {
      final sound = _object(value);
      final id = _id(sound['id']);
      if (!soundIds.add(id) || soundIds.length > 5000) {
        throw const FormatException('Duplicate sound ID or too many sounds');
      }
      final fileId = _text(sound['driveFileId']);
      final hash = _text(sound['sha256']);
      final bytes = sound['bytes'];
      if (!RegExp(r'^[A-Za-z0-9_-]{10,200}$').hasMatch(fileId) ||
          !RegExp(r'^[a-f0-9]{64}$').hasMatch(hash) ||
          bytes is! int ||
          bytes <= 0 ||
          bytes > maxSoundBytes) {
        throw const FormatException('Invalid sound download metadata');
      }
      totalBytes += bytes;
      if (totalBytes > maxTotalSoundBytes) {
        throw const FormatException('Content exceeds storage limit');
      }
      sounds.add(
        RemoteSound(
          id: id,
          title: _text(sound['title']),
          driveFileId: fileId,
          sha256: hash,
          bytes: bytes,
        ),
      );
    }
    parts.add(
      RemotePart(
        id: id,
        title: _text(part['title']),
        collection: collection,
        sounds: List.unmodifiable(sounds),
      ),
    );
    if (parts.length > 5000) throw const FormatException('Too many parts');
  }
  return RemoteCatalog(
    List.unmodifiable(parts),
    collections: List.unmodifiable(remoteCollections),
  );
}

Map<String, dynamic> _object(dynamic value) {
  if (value is! Map<String, dynamic>) {
    throw const FormatException('Expected object');
  }
  return value;
}

int _id(dynamic value) {
  if (value is! int || value < remoteIdMinimum || value > 2147483647) {
    throw const FormatException('Invalid stable content ID');
  }
  return value;
}

String _text(dynamic value) {
  if (value is! String || value.trim().isEmpty || value.length > 500) {
    throw const FormatException('Invalid content text');
  }
  return value;
}

/// Only public Google download hosts are allowed, including redirect targets.
bool isAllowedContentUri(Uri uri) {
  final host = uri.host.toLowerCase();
  return uri.scheme == 'https' &&
      uri.userInfo.isEmpty &&
      (!uri.hasPort || uri.port == 443) &&
      (host == 'drive.google.com' ||
          host == 'docs.google.com' ||
          host == 'drive.usercontent.google.com' ||
          host == 'googleusercontent.com' ||
          host.endsWith('.googleusercontent.com'));
}

class ContentStore {
  ContentStore({
    required this.directory,
    required this.manifestUri,
    ContentFetcher? fetcher,
  }) : _fetcher = fetcher ?? fetchGoogleContent {
    if (!isAllowedContentUri(manifestUri)) {
      throw ArgumentError.value(
        manifestUri,
        'manifestUri',
        'Expected HTTPS Google URL',
      );
    }
  }

  final Directory directory;
  final Uri manifestUri;
  final ContentFetcher _fetcher;
  Future<List<PartFiles>>? _activeSync;
  File get _catalogFile => File('${directory.path}/catalog.json');
  File _soundFile(RemoteSound sound) =>
      File('${directory.path}/${sound.filename}');

  /// Includes declared main folders that do not yet have any subfolders.
  Future<List<PartCollection>> loadCachedCollections() async {
    try {
      if (!await _catalogFile.exists() ||
          await _catalogFile.length() > maxCatalogBytes) {
        return [];
      }
      return parseRemoteCatalog(await _catalogFile.readAsString()).collections;
    } on FileSystemException {
      return [];
    } on FormatException {
      return [];
    }
  }

  /// No network access. A damaged file never makes the bundled library unusable.
  Future<List<PartFiles>> loadCached() async {
    try {
      final file = _catalogFile;
      if (!await file.exists() || await file.length() > maxCatalogBytes) {
        return [];
      }
      final catalog = parseRemoteCatalog(await file.readAsString());
      final available = <int>{};
      for (final sound in catalog.sounds) {
        if (await _isValid(sound)) available.add(sound.id);
      }
      return _toParts(catalog, available);
    } on FileSystemException {
      return [];
    } on FormatException {
      return [];
    }
  }

  /// Concurrent callers share one transfer. Publish only after every file passes.
  Future<List<PartFiles>> sync({
    void Function(int completed, int total)? onProgress,
  }) {
    return _activeSync ??= _sync(
      onProgress,
    ).whenComplete(() => _activeSync = null);
  }

  Future<List<PartFiles>> _sync(void Function(int, int)? onProgress) async {
    final bytes = await _fetcher(manifestUri, maxCatalogBytes);
    if (bytes.length > maxCatalogBytes) {
      throw const FormatException('Catalog too large');
    }
    final source = utf8.decode(bytes);
    final catalog = parseRemoteCatalog(source);
    await directory.create(recursive: true);
    final sounds = catalog.sounds.toList();
    var completed = 0;
    onProgress?.call(completed, sounds.length);
    for (final sound in sounds) {
      if (!await _isValid(sound)) {
        final bytes = await _fetcher(sound.downloadUri, sound.bytes);
        if (bytes.length != sound.bytes ||
            sha256.convert(bytes).toString() != sound.sha256) {
          throw const FormatException('Sound integrity check failed');
        }
        final target = _soundFile(sound);
        final temporary = File('${target.path}.part');
        try {
          await temporary.writeAsBytes(bytes, flush: true);
          await temporary.rename(target.path);
        } finally {
          if (await temporary.exists()) await temporary.delete();
        }
      }
      onProgress?.call(++completed, sounds.length);
    }
    final temporary = File('${_catalogFile.path}.part');
    try {
      await temporary.writeAsString(source, flush: true);
      await temporary.rename(_catalogFile.path);
    } finally {
      if (await temporary.exists()) await temporary.delete();
    }
    return _toParts(catalog, sounds.map((s) => s.id).toSet());
  }

  Future<bool> _isValid(RemoteSound sound) async {
    final file = _soundFile(sound);
    try {
      if (!await file.exists() || await file.length() != sound.bytes) {
        return false;
      }
      return (await sha256.bind(file.openRead()).first).toString() ==
          sound.sha256;
    } on FileSystemException {
      return false;
    }
  }

  List<PartFiles> _toParts(RemoteCatalog catalog, Set<int> available) => [
    for (final part in catalog.parts)
      if (part.sounds.isEmpty ||
          part.sounds.any((s) => available.contains(s.id)))
        PartFiles(
          id: part.id,
          title: part.title,
          collection: part.collection,
          files: [
            for (final sound in part.sounds)
              if (available.contains(sound.id))
                FileData(
                  id: sound.id,
                  title: sound.title,
                  assetName: 'remote_${sound.id}',
                  localPath: _soundFile(sound).path,
                ),
          ],
        ),
  ];
}

/// Bounded transport with explicit redirect validation and no embedded secrets.
Future<List<int>> fetchGoogleContent(Uri uri, int maxBytes) async {
  final client = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    return await (() async {
      var current = uri;
      for (var redirects = 0; redirects <= 5; redirects++) {
        if (!isAllowedContentUri(current)) {
          throw const FormatException('Untrusted download URL');
        }
        final request = await client.getUrl(current);
        request.followRedirects = false;
        final response = await request.close();
        if ([301, 302, 303, 307, 308].contains(response.statusCode)) {
          final location = response.headers.value(HttpHeaders.locationHeader);
          if (location == null) {
            throw const HttpException('Missing redirect location');
          }
          current = current.resolve(location);
          continue;
        }
        if (response.statusCode != HttpStatus.ok) {
          throw HttpException(
            'Content download failed (${response.statusCode})',
          );
        }
        if (response.contentLength > maxBytes) {
          throw const FormatException('Download too large');
        }
        final result = BytesBuilder(copy: false);
        await for (final chunk in response.timeout(
          const Duration(seconds: 30),
        )) {
          if (result.length + chunk.length > maxBytes) {
            throw const FormatException('Download too large');
          }
          result.add(chunk);
        }
        return result.takeBytes();
      }
      throw const HttpException('Too many download redirects');
    })().timeout(const Duration(minutes: 2));
  } finally {
    client.close(force: true);
  }
}
