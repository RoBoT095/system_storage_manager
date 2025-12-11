import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import 'platform_interface.dart';

class DefaultFileHandler implements FileHandler {
  @override
  Future<FileItem?> pickDir({
    String? initUri,
    bool? writePermission,
    bool? persistablePermission,
  }) async {
    String? result = await FilePicker.platform.getDirectoryPath(
      initialDirectory: initUri != null
          ? Uri.parse(initUri).toFilePath()
          : null,
    );
    if (result != null) {
      return FileItem(
        // Uri folders need to end in '/'
        uri: '${File(result).uri.toString()}/',
        name: path.basename(result),
      );
    }
    return null;
  }

  @override
  Future<FileItem?> pickFile({List<String>? allowedExtensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    if (result != null) {
      PlatformFile file = result.files.first;
      return FileItem(uri: File(file.path!).uri.toString(), name: file.name);
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
          .map((i) => FileItem(uri: File(i.path!).uri.toString(), name: i.name))
          .toList();
    }
    return null;
  }

  @override
  Future<List<FileItem>> listFiles(
    String uri, {
    bool showHidden = false,
  }) async {
    final entities = await Directory.fromUri(Uri.parse(uri)).list().toList();

    return entities
        .where((e) {
          if (showHidden) return true;
          return !e.uri.toFilePath().startsWith('.');
        })
        .map(
          (e) => FileItem(
            uri: e.uri.toString(),
            name: path.basename(e.uri.toFilePath()),
            isDir: e is Directory,
          ),
        )
        .toList();
  }

  @override
  Future<FileItem> create(String uri, String name, {bool isDir = false}) async {
    FileSystemEntity item;
    if (isDir) {
      item = Directory('${Uri.parse(uri).toFilePath()}/$name');
    } else {
      item = File('${Uri.parse(uri).toFilePath()}/$name');
    }
    if (isDir) {
      (item as Directory).create();
    } else {
      (item as File).create();
    }
    return FileItem(uri: item.uri.toString(), name: name, isDir: isDir);
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
    final file = _parseUriToFSE(uri);
    final newPath = '${file.parent.path}/$newName';
    final renamed = await file.rename(newPath);
    return FileItem(
      uri: renamed.uri.toString(),
      name: newName,
      isDir: renamed is Directory,
    );
  }

  @override
  Future<bool> delete(String uri) async {
    final file = _parseUriToFSE(uri);
    await file.delete();
    return true;
  }

  @override
  Future<bool> exists(String uri) async {
    final FileSystemEntity file;
    if (isDir(uri)) {
      file = _parseUriToFSE(uri);
    } else {
      file = _parseUriToFSE(uri);
    }
    return await file.exists();
  }

  @override
  Future<FileItemStats?> stats(String uri) async {
    if (await exists(uri)) {
      final stats = await _parseUriToFSE(uri).stat();

      return FileItemStats(
        uri: uri,
        name: path.basename(uri),
        isDir: isDir(uri),
        size: stats.size,
        lastModified: stats.modified.millisecondsSinceEpoch,
      );
    }
    return null;
  }

  @override
  Future<String> parentUri(String uri) async {
    final dir = _parseUriToFSE(uri);
    final parent = path.dirname(dir.path);
    return Directory.fromUri(Uri.parse(parent)).uri.toString();
  }

  @override
  Future<FileItem> copy(String fromUri, String toUri) async {
    final src = _parseUriToFSE(fromUri);
    final dest = _parseUriToFSE(toUri) as Directory;

    if (isDir(fromUri)) {
      await dest.create(recursive: true);
      (src as Directory).list(recursive: false).map((item) async {
        if (item is Directory) {
          final newDir = Directory(
            path.join(dest.path, path.basename(item.path)),
          );
          await copy(item.uri.toString(), newDir.uri.toString());
        } else if (item is File) {
          await item.copy(path.join(dest.path, path.basename(item.path)));
        }
      });
      return FileItem(
        uri: dest.uri.toString(),
        name: dest.uri.pathSegments.last,
        isDir: true,
      );
    }

    final newFilePath = await (src as File).copy(
      path.join(dest.path, path.basename(src.path)),
    );
    return FileItem(
      uri: newFilePath.uri.toString(),
      name: newFilePath.uri.pathSegments.last,
      isDir: false,
    );
  }

  @override
  Future<FileItem> move(String fromUri, String toUri) async {
    final src = _parseUriToFSE(fromUri);
    final dest = await src.rename(
      path.join(Uri.parse(toUri).toFilePath(), path.basename(src.path)),
    );
    return FileItem(
      uri: dest.uri.toString(),
      name: dest.uri.pathSegments.last,
      isDir: dest is Directory,
    );
  }

  @override
  Future<String> readAsString(String uri) async {
    final file = _parseUriToFSE(uri) as File;
    return file.readAsString();
  }

  @override
  Future<List<int>> readAsBytes(String uri) async {
    final file = _parseUriToFSE(uri) as File;
    return file.readAsBytes();
  }

  @override
  Future<FileItem> writeAsString(
    String uri,
    String contents, {
    String mime = 'text/plain',
  }) async {
    final file = await (_parseUriToFSE(uri) as File).writeAsString(contents);
    return FileItem(
      uri: file.uri.toString(),
      name: path.basename(file.path),
      isDir: file is Directory,
    );
  }

  @override
  Future<FileItem> writeAsBytes(
    String uri,
    List<int> bytes, {
    String mime = 'text/plain',
  }) async {
    final file = await (_parseUriToFSE(uri) as File).writeAsBytes(bytes);
    return FileItem(
      uri: file.uri.toString(),
      name: path.basename(file.path),
      isDir: file is Directory,
    );
  }

  FileItem getFileItem(String uri) {
    return FileItem(uri: uri, name: path.basename(uri), isDir: isDir(uri));
  }

  FileSystemEntity _parseUriToFSE(String uri) {
    if (isDir(uri)) {
      return Directory.fromUri(Uri.parse(uri));
    }
    return File.fromUri(Uri.parse(uri));
  }

  bool isDir(String uri) {
    return FileSystemEntity.isDirectorySync(Uri.parse(uri).toFilePath());
  }
}
