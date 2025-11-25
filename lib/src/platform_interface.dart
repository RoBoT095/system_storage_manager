import 'dart:io';

import 'default_file_handler.dart';
import 'saf_android_handler.dart';

abstract class FileHandler {
  static FileHandler createHandler() {
    if (_isAndroid) return SafAndroidHandler();
    return DefaultFileHandler();
  }

  static bool get _isAndroid => Platform.isAndroid;

  Future<FileItem?> pickDir({
    String? initUri,
    bool? writePermission,
    bool? persistablePermission,
  });
  Future<FileItem?> pickFile({List<String>? allowedExtensions});
  Future<List<FileItem>?> pickFiles({List<String>? allowedExtensions});
  Future<List<FileItem>> listFiles(String uri, {bool showHidden = false});

  Future<FileItem> create(String uri, String name, {bool isDir});
  Future<FileItem> rename(String uri, String newName);
  Future<bool> delete(String uri);

  Future<bool> exists(String uri);
  // Future<FileItemStats> stats(String uri);
  Future<String> parentUri(String uri);

  Future<FileItem> copy(String fromUri, String toUri);
  Future<FileItem> move(String fromUri, String toUri);

  Future<String> readAsString(String uri);
  Future<List<int>> readAsBytes(String uri);
  Future<FileItem> writeAsString(String uri, String contents, {String mime});
  Future<FileItem> writeAsBytes(String uri, List<int> bytes, {String mime});
}

class FileItem {
  final String uri;
  final String name;
  final bool isDir;

  FileItem({required this.uri, required this.name, this.isDir = false});
}

class FileItemStats {
  final String uri;
  final String name;
  final bool isDir;
  final int size;
  // TODO: Add more stats

  FileItemStats({
    required this.uri,
    required this.name,
    required this.isDir,
    required this.size,
  });
}
