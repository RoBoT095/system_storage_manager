/// Library exports all the classes and functions of the SSM package.
library;

export 'src/platform_interface.dart' show FileHandler, FileItem;
import 'src/platform_interface.dart';

class SystemStorageManager {
  static final SystemStorageManager _instance =
      SystemStorageManager._internal();

  factory SystemStorageManager() => _instance;
  SystemStorageManager._internal();

  final FileHandler _handler = FileHandler.createHandler();

  /// Opens file picker to select directory
  Future<FileItem?> pickDir() => _handler.pickDir();

  /// Opens file picker to select a single file
  Future<FileItem?> pickFile({List<String>? allowedExtensions}) =>
      _handler.pickFile(allowedExtensions: allowedExtensions);

  /// Opens file picker to select multiple files
  Future<List<FileItem>?> pickFiles({List<String>? allowedExtensions}) =>
      _handler.pickFiles(allowedExtensions: allowedExtensions);

  /// Pass uri string to get list of all the files and folders in that location
  ///
  /// `showHidden = true` will return all [FileItem]s that have a path that
  /// starts with "." (ex. '.folder/' or '.image.png')
  Future<List<FileItem>> listFiles(String uri, {bool showHidden = false}) =>
      _handler.listFiles(uri, showHidden: showHidden);

  ///
  Future<FileItem> create(String uri, String name) =>
      _handler.create(uri, name);

  ///
  Future<FileItem> rename(String uri, String newName) =>
      _handler.rename(uri, newName);

  ///
  Future<bool> delete(String uri) => _handler.delete(uri);

  ///
  Future<bool> exists(String uri) => _handler.exists(uri);

  ///
  Future<FileItem> copy(String fromUri, String toUri) =>
      _handler.copy(fromUri, toUri);

  ///
  Future<FileItem> move(String fromUri, String toUri) =>
      _handler.move(fromUri, toUri);

  ///
  Future<String> readAsString(String uri) => _handler.readAsString(uri);

  ///
  Future<List<int>> readAsBytes(String uri) => _handler.readAsBytes(uri);

  /// Writes a string to file
  ///
  /// If writing to file on android, make sure to include mime type of the file,
  /// otherwise it will default to 'text/plain'
  Future<FileItem> writeAsString(
    String uri,
    String contents, {
    String mime = 'text/plain',
  }) => _handler.writeAsString(uri, contents, mime: mime);

  /// Writes a list of bytes to file
  ///
  /// If writing to file on android, make sure to include mime type of the file,
  /// otherwise it will default to 'text/plain'
  Future<FileItem> writeAsBytes(
    String uri,
    List<int> bytes, {
    String mime = 'text/plain',
  }) => _handler.writeAsBytes(uri, bytes, mime: mime);
}
