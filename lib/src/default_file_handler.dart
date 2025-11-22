import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

import 'platform_interface.dart';

class DefaultFileHandler implements FileHandler {
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
  Future<FileItem> createFile(String uri, String name) async {
    final file = File(
      '${Uri.parse(uri).toFilePath()}${Platform.pathSeparator}$name',
    );
    await file.create();
    return FileItem(uri: file.uri.toString(), name: name);
  }

  @override
  Future<FileItem> rename(String uri, String newName) async {
    final file = File.fromUri(Uri.parse(uri));
    final newPath = '${file.parent.path}/$newName';
    final renamed = await file.rename(newPath);
    return FileItem(uri: renamed.uri.toString(), name: newName);
  }

  @override
  Future<FileItem> copy(String fromUri, String toUri) async {
    final src = File.fromUri(Uri.parse(fromUri));
    final dest = await src.copy(toUri);
    return FileItem(uri: dest.uri.toString(), name: dest.uri.pathSegments.last);
  }

  @override
  Future<FileItem> move(String fromUri, String toUri) async {
    final src = File.fromUri(Uri.parse(fromUri));
    final dest = await src.rename(toUri);
    return FileItem(uri: dest.uri.toString(), name: dest.uri.pathSegments.last);
  }

  @override
  Future<bool> delete(String uri) async {
    final file = File.fromUri(Uri.parse(uri));
    await file.delete();
    return true;
  }

  @override
  Future<bool> exists(String uri) async {
    final file = File.fromUri(Uri.parse(uri));
    return await file.exists();
  }
}
