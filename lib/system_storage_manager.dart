/// Library exports all the classes and functions of the SSM package.
library;

export 'src/platform_interface.dart' show FileHandler, FileItem;
import 'src/platform_interface.dart';
import 'src/saf_android_handler.dart'
    if (dart.library.io) 'src/default_file_handler.dart';

class SystemStorageManager {
  static final SystemStorageManager _instance =
      SystemStorageManager._internal();

  factory SystemStorageManager() => _instance;
  SystemStorageManager._internal();

  final FileHandler _handler = FileHandler.create();

  Future<List<FileItem>> listFiles(String uri) => _handler.listFiles(uri);
  Future<FileItem> createFile(String uri, String name) =>
      _handler.createFile(uri, name);
  Future<bool> delete(String uri) => _handler.delete(uri);
  Future<FileItem> rename(String uri, String newName) =>
      _handler.rename(uri, newName);
  Future<FileItem> copy(String fromUri, String toUri) =>
      _handler.copy(fromUri, toUri);
  Future<FileItem> move(String fromUri, String toUri) =>
      _handler.move(fromUri, toUri);
}
