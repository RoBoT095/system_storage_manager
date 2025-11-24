import 'package:flutter/material.dart';

import 'package:system_storage_manager/system_storage_manager.dart';

void main() {
  runApp(const SSMExampleApp());
}

class SSMExampleApp extends StatelessWidget {
  const SSMExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'System Storage Manager Example',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      home: const FileManagerDemo(),
    );
  }
}

class FileManagerDemo extends StatefulWidget {
  const FileManagerDemo({super.key});

  @override
  State<FileManagerDemo> createState() => _FileManagerDemoState();
}

class _FileManagerDemoState extends State<FileManagerDemo> {
  final manager = SystemStorageManager();
  String? selectedPath;
  String currentPath = '/';
  List<FileItem> files = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickDir() async {
    final result = await manager.pickDir();
    if (result != null) {
      setState(() {
        selectedPath = result.uri;
      });
      _listFiles();
    }
  }

  Future<void> _listFiles({String? uri}) async {
    setState(() {
      loading = true;
      currentPath = uri ?? selectedPath ?? '/';
    });
    try {
      final result = await manager.listFiles(currentPath, showHidden: false);
      setState(() => files = result);
    } catch (e) {
      debugPrint('List Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to list files: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _createFile() async {
    final name = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      await manager.create(currentPath, 'file_$name.txt');
      _listFiles();
    } catch (e) {
      debugPrint('Create Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Create Error: $e')));
    }
  }

  Future<void> _deleteFile(String uri) async {
    try {
      await manager.delete(uri);
      _listFiles();
    } catch (e) {
      debugPrint('Delete Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Delete Error: $e')));
    }
  }

  Future<void> _goBack() async {
    List<String> uriList = [...Uri.parse(currentPath).pathSegments];
    uriList.removeAt(uriList.length - 2);
    String newUri = Uri(scheme: 'file', path: uriList.join('/')).toString();

    setState(() => currentPath = newUri);
    _listFiles(uri: newUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Storage Manager Example'),
        actions: [
          if (selectedPath != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _listFiles(uri: currentPath),
            ),
        ],
        leading: selectedPath != null && selectedPath != currentPath
            ? IconButton(icon: Icon(Icons.chevron_left), onPressed: _goBack)
            : null,
      ),
      floatingActionButton: selectedPath != null
          ? FloatingActionButton(
              onPressed: _createFile,
              child: const Icon(Icons.add),
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : selectedPath == null
          ? ListTile(
              title: Text('Select Folder Path'),
              subtitle: Text('Press Me'),
              onTap: _pickDir,
            )
          : GridView.builder(
              itemCount: files.length,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 6 / 2,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) {
                final file = files[index];
                return Card(
                  color: Colors.grey[200],
                  child: ListTile(
                    leading: file.isDir
                        ? Icon(Icons.folder, color: Colors.purple)
                        : Icon(Icons.insert_drive_file, color: Colors.blue),
                    title: Text(
                      file.name,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      Uri.parse(file.uri).toFilePath(),
                      style: TextStyle(overflow: TextOverflow.ellipsis),
                      softWrap: true,
                      maxLines: 2,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteFile(file.uri),
                    ),
                    onTap: file.isDir
                        ? () {
                            _listFiles(uri: file.uri);
                          }
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
