import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:system_storage_manager/src/default_file_handler.dart';

import 'platform_interface.dart';

class SafAndroidHandler implements FileHandler {
  final _safStream = SafStream();
  final _safUtil = SafUtil();

  @override
  Future<FileItem?> pickDir({
    String? initUri,
    bool? writePermission,
    bool? persistablePermission,
  }) async {
    final dir = await _safUtil.pickDirectory(
      initialUri: initUri,
      writePermission: writePermission,
      persistablePermission: persistablePermission,
    );
    if (dir != null) {
      return FileItem(uri: dir.uri, name: dir.name, isDir: dir.isDir);
    }
    return null;
  }

  @override
  Future<FileItem?> pickFile({
    String? initUri,
    List<String>? allowedExtensions,
  }) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      return FileItem(
        uri: File(file.path!).uri.toString(),
        name: file.name,
        isDir: false,
      );
    }
    return null;
  }

  @override
  Future<List<FileItem>?> pickFiles({List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );
    if (result != null) {
      List<PlatformFile> files = result.files;
      return files
          .map(
            (i) => FileItem(
              uri: File(i.path!).uri.toString(),
              name: i.name,
              isDir: false,
            ),
          )
          .toList();
    }
    return null;
  }

  @override
  Future<List<FileItem>> listFiles(
    String uri, {
    bool showHidden = false,
  }) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().listFiles(uri);
    }
    final list = await _safUtil.list(uri);
    return list
        .where((e) {
          if (showHidden) return true;
          return !e.name.startsWith('.');
        })
        .map((e) => FileItem(uri: e.uri, name: e.name, isDir: e.isDir))
        .toList();
  }

  @override
  Future<FileItem> create(String uri, String name, {bool isDir = false}) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().create(uri, name, isDir: isDir);
    }
    if (isDir) {
      final dir = await _safUtil.mkdirp(uri, [name]);
      return FileItem(uri: dir.uri, name: dir.name, isDir: dir.isDir);
    }
    return writeAsBytes(path.join(uri, name), []);
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().rename(uri, newName);
    }
    final renamed = await _safUtil.rename(uri, await isDir(uri), newName);
    return FileItem(uri: renamed.uri, name: renamed.name, isDir: renamed.isDir);
  }

  @override
  Future<bool> delete(String uri) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().delete(uri);
    }
    await _safUtil.delete(uri, await isDir(uri));
    bool exits = await exists(uri);
    return !exits;
  }

  @override
  Future<bool> exists(String uri) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().exists(uri);
    }
    return _safUtil.exists(uri, await isDir(uri));
  }

  @override
  Future<String> parentUri(String uri) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().parentUri(uri);
    }
    final parsedUri = Uri.parse(uri);
    final parentSegments = parsedUri.pathSegments.toList()..removeLast();
    final newUri = parsedUri.replace(pathSegments: parentSegments);
    return newUri.toString();
  }

  @override
  Future<FileItem> copy(String fromUri, String toUri) async {
    if (Uri.parse(fromUri).scheme == 'file') {
      return DefaultFileHandler().copy(fromUri, toUri);
    }
    final file = await _safUtil.copyTo(fromUri, await isDir(fromUri), toUri);
    return FileItem(uri: file.uri, name: file.name, isDir: file.isDir);
  }

  @override
  Future<FileItem> move(String fromUri, String toUri) async {
    if (Uri.parse(fromUri).scheme == 'file') {
      return DefaultFileHandler().move(fromUri, toUri);
    }
    final file = await _safUtil.moveTo(
      fromUri,
      await isDir(fromUri),
      await parentUri(fromUri),
      toUri,
    );
    return FileItem(uri: file.uri, name: file.name, isDir: file.isDir);
  }

  @override
  Future<String> readAsString(String uri) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().readAsString(uri);
    }
    return utf8.decode(await readAsBytes(uri));
  }

  @override
  Future<List<int>> readAsBytes(String uri) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().readAsBytes(uri);
    }
    return _safStream.readFileBytes(uri);
  }

  @override
  Future<FileItem> writeAsString(
    String uri,
    String contents, {
    String mime = 'text/plain',
  }) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().writeAsString(uri, contents);
    }
    return writeAsBytes(uri, utf8.encode(contents), mime: mime);
  }

  @override
  Future<FileItem> writeAsBytes(
    String uri,
    List<int> bytes, {
    String mime = 'text/plain',
  }) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().writeAsBytes(uri, bytes);
    }
    final newFile = await _safStream.writeFileBytes(
      Uri.parse(path.dirname(uri)).toString(),
      path.basename(uri),
      mime,
      Uint8List.fromList(bytes),
    );

    return FileItem(
      uri: newFile.uri.toString(),
      name: newFile.fileName ?? path.basename(newFile.uri.toString()),
      isDir: await isDir(newFile.uri.toString()),
    );
  }

  Future<bool> isDir(String uri) async {
    if (Uri.parse(uri).scheme == 'file') {
      return DefaultFileHandler().isDir(uri);
    }

    try {
      // Check if listing succeeds, if so, it's a directory
      await _safUtil.list(uri);
      return true;
    } catch (e) {
      // If failed, probably a file
      return false;
    }
  }
}
