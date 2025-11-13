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
  String currentPath = '/';
  List<FileItem> files = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  Future<void> _listFiles() async {
    setState(() => loading = true);
    try {
      final result = await manager.listFiles(currentPath);
      setState(() => files = result);
    } catch (e) {
      debugPrint('Error: $e');
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
      await manager.createFile(currentPath, 'file_$name.txt');
      _listFiles();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteFile(String uri) async {
    try {
      await manager.delete(uri);
      _listFiles();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Storage Manager Example'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _listFiles),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createFile,
        child: const Icon(Icons.add),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(
                    file.isDir ? Icons.folder : Icons.insert_drive_file,
                  ),
                  title: Text(file.name),
                  subtitle: Text(file.uri),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteFile(file.uri),
                  ),
                );
              },
            ),
    );
  }
}
