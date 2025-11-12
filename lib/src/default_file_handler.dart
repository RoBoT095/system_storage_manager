import 'dart:io';
import 'platform_interface.dart';

class DefaultFileHandler implements FileHandler {
  @override
  Future<List<FileItem>> listFiles(String uri) async {
    final dir = Directory(uri);
    final entities = await dir.list().toList();
    return entities.map((e) {
      return FileItem(
        uri: e.uri.toString(),
        name: e.uri.pathSegments.last,
        isDirectory: e is Directory,
      );
    }).toList();
  }

  @override
  Future<FileItem> createFile(String uri, String name) async {
    final file = File('$uri/$name');
    await file.create();
    return FileItem(uri: file.uri.toString(), name: name);
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
    final file = File(uri);
    final newPath = '${file.parent.path}/$newName';
    final renamed = await file.rename(newPath);
    return FileItem(uri: renamed.uri.toString(), name: newName);
  }

  @override
  Future<FileItem> copy(String fromUri, String toUri) async {
    final src = File(fromUri);
    final dest = await src.copy(toUri);
    return FileItem(uri: dest.uri.toString(), name: dest.uri.pathSegments.last);
  }

  @override
  Future<FileItem> move(String fromUri, String toUri) async {
    final src = File(fromUri);
    final dest = await src.rename(toUri);
    return FileItem(uri: dest.uri.toString(), name: dest.uri.pathSegments.last);
  }

  @override
  Future<bool> delete(String uri) async {
    final file = File(uri);
    await file.delete();
    return true;
  }
}
