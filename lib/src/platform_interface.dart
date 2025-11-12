import 'default_file_handler.dart';
import 'saf_android_handler.dart';

abstract class FileHandler {
  static FileHandler create() {
    if (_isAndroid) return SafAndroidHandler();
    return DefaultFileHandler();
  }

  static bool get _isAndroid => const bool.fromEnvironment('dart.library.io');

  Future<List<FileItem>> listFiles(String uri);
  Future<FileItem> createFile(String uri, String name);
  Future<FileItem> rename(String uri, String newName);
  Future<FileItem> copy(String fromUri, String toUri);
  Future<FileItem> move(String fromUri, String toUri);
  Future<bool> delete(String uri);
}

class FileItem {
  final String uri;
  final String name;
  final bool isDirectory;

  FileItem({required this.uri, required this.name, this.isDirectory = false});
}
