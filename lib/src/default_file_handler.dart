import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import 'platform_interface.dart';

class DefaultFileHandler implements FileHandler {
  File _parseUriToFile(String uri) {
    return File.fromUri(Uri.parse(uri));
  }

  @override
  Future<FileItem?> pickDir() async {
    String? result = await FilePicker.platform.getDirectoryPath();
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
    final dir = Directory.fromUri(Uri.parse(uri));
    final entities = await dir.list().toList();
    final List<FileItem> fileItems = [];
    for (var e in entities) {
      final name = path.basename(e.uri.toFilePath());
      final isHidden = name.startsWith('.');

      if (showHidden || !isHidden) {
        fileItems.add(
          FileItem(uri: e.uri.toString(), name: name, isDir: e is Directory),
        );
      }
    }
    return fileItems;
  }

  @override
  Future<FileItem> create(String uri, String name) async {
    final file = File(
      '${Uri.parse(uri).toFilePath()}${Platform.pathSeparator}$name',
    );
    await file.create();
    return FileItem(uri: file.uri.toString(), name: name);
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
    final file = _parseUriToFile(uri);
    final newPath = '${file.parent.path}/$newName';
    final renamed = await file.rename(newPath);
    return FileItem(uri: renamed.uri.toString(), name: newName);
  }

  @override
  Future<bool> delete(String uri) async {
    final file = _parseUriToFile(uri);
    await file.delete();
    return true;
  }

  @override
  Future<bool> exists(String uri) async {
    final file = _parseUriToFile(uri);
    return await file.exists();
  }

  @override
  Future<FileItem> copy(String fromUri, String toUri) async {
    final src = _parseUriToFile(fromUri);
    final dest = await src.copy(toUri);
    return FileItem(uri: dest.uri.toString(), name: dest.uri.pathSegments.last);
  }

  @override
  Future<FileItem> move(String fromUri, String toUri) async {
    final src = _parseUriToFile(fromUri);
    final dest = await src.rename(toUri);
    return FileItem(uri: dest.uri.toString(), name: dest.uri.pathSegments.last);
  }

  @override
  Future<String> readAsString(String uri) async {
    final file = _parseUriToFile(uri);
    return file.readAsString();
  }

  @override
  Future<List<int>> readAsBytes(String uri) async {
    final file = _parseUriToFile(uri);
    return file.readAsBytes();
  }

  @override
  Future<FileItem> writeAsString(
    String uri,
    String contents, {
    String mime = 'text/plain',
  }) async {
    final file = await _parseUriToFile(uri).writeAsString(contents);
    return FileItem(uri: file.uri.toString(), name: path.basename(file.path));
  }

  @override
  Future<FileItem> writeAsBytes(
    String uri,
    List<int> bytes, {
    String mime = 'text/plain',
  }) async {
    final file = await _parseUriToFile(uri).writeAsBytes(bytes);
    return FileItem(uri: file.uri.toString(), name: path.basename(file.path));
  }
}
