import 'platform_interface.dart';

class SafAndroidHandler implements FileHandler {
  // TODO everything
  @override
  Future<FileItem?> pickDir() async {
    return null;
  }

  @override
  Future<FileItem?> pickFile({List<String>? allowedExtensions}) async {
    return null;
  }

  @override
  Future<List<FileItem>?> pickFiles({List<String>? allowedExtensions}) async {
    return null;
  }

  @override
  Future<List<FileItem>> listFiles(
    String uri, {
    bool showHidden = false,
  }) async {
    return [];
  }

  @override
  Future<FileItem> create(String uri, String name) async {
    throw UnimplementedError();
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> delete(String uri) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String uri) async {
    throw UnimplementedError();
  }

  @override
  Future<FileItem> copy(String fromUri, String toUri) async {
    throw UnimplementedError();
  }

  @override
  Future<FileItem> move(String fromUri, String toUri) async {
    throw UnimplementedError();
  }

  @override
  Future<String> readAsString(String uri) async {
    throw UnimplementedError();
  }

  @override
  Future<List<int>> readAsBytes(String uri) async {
    throw UnimplementedError();
  }

  @override
  Future<FileItem> writeAsString(
    String uri,
    String contents, {
    String mime = 'text/plain',
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<FileItem> writeAsBytes(
    String uri,
    List<int> bytes, {
    String mime = 'text/plain',
  }) async {
    throw UnimplementedError();
  }
}
