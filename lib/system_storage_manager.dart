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
  ///
  /// - [initUri] is the initial URI to show in the dialog.
  /// - Android only, [writePermission] if the folder should have write permission.
  /// - Android only, [persistablePermission] if the permission should persist.
  Future<FileItem?> pickDir({
    String? initUri,
    bool? writePermission,
    bool? persistablePermission,
  }) => _handler.pickDir(
    initUri: initUri,
    writePermission: writePermission,
    persistablePermission: persistablePermission,
  );

  /// Opens file picker to select a single file
  ///
  /// [allowedExtensions] can be provided (e.g. [pdf, svg, jpg].) to limit what
  /// type of files are selected
  Future<FileItem?> pickFile({List<String>? allowedExtensions}) =>
      _handler.pickFile(allowedExtensions: allowedExtensions);

  /// Opens file picker to select multiple files
  ///
  /// [allowedExtensions] can be provided (e.g. [pdf, svg, jpg].) to limit what
  /// type of files are selected
  Future<List<FileItem>?> pickFiles({List<String>? allowedExtensions}) =>
      _handler.pickFiles(allowedExtensions: allowedExtensions);

  /// Pass uri string to get list of all the files and folders in that location
  ///
  /// `showHidden = true` will return all [FileItem] that have a path that
  /// starts with "." (ex. '.folder/' or '.image.png')
  Future<List<FileItem>> listFiles(String uri, {bool showHidden = false}) =>
      _handler.listFiles(uri, showHidden: showHidden);

  ///
  Future<FileItem> create(String uri, String name) =>
      _handler.create(uri, name);

  /// Renames file or folder to a new name
  ///
  /// Pass full uri path to [uri] and just the name to [newName].
  Future<FileItem> rename(String uri, String newName) =>
      _handler.rename(uri, newName);

  /// Delete file or folder and return true if succeeded and vice versa
  Future<bool> delete(String uri) => _handler.delete(uri);

  /// Checks whether file or folder exists
  Future<bool> exists(String uri) => _handler.exists(uri);

  /// Gets the parent directory of the passed uri string.
  ///
  /// On android a 'content://...' is expected, on other platforms a
  /// 'file:///...' string is expected
  Future<String> parentUri(String uri) => _handler.parentUri(uri);

  /// Copy file or folder to passed location
  ///
  /// [fromUri] is the uri of the file or folder that will be copied,
  /// [toUri] is the uri of copy location.
  Future<FileItem> copy(String fromUri, String toUri) =>
      _handler.copy(fromUri, toUri);

  /// Moves file or folder to new location
  ///
  /// [fromUri] is the uri of the file or folder that will be moved,
  /// [toUri] is the uri of the folder that will be the next location.
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
