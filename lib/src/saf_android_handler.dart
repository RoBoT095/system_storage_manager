import 'platform_interface.dart';

class SafAndroidHandler implements FileHandler {
  // TODO everything

  @override
  Future<FileItem?> pickFile() async {
    return null;
  }

  @override
  Future<List<FileItem>?> pickFiles() async {
    return null;
  }

  @override
  Future<FileItem?> pickDir() async {
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
  Future<FileItem> createFile(String uri, String name) async {
    throw UnimplementedError();
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
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
  Future<bool> delete(String uri) async {
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String uri) async {
    throw UnimplementedError();
  }
}
