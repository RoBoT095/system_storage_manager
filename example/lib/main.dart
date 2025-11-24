import 'dart:io';

import 'package:flutter/material.dart';

import 'package:system_storage_manager/system_storage_manager.dart';
import 'package:system_storage_manager_demo/views/desktop_grid_view.dart';
import 'package:system_storage_manager_demo/views/mobile_list_view.dart';

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

  Future<void> _pickDir({bool? writePerm, bool? persistPerm}) async {
    final result = await manager.pickDir(
      writePermission: writePerm,
      persistablePermission: persistPerm,
    );
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
    final newUri = await manager.parentUri(currentPath);
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
          : Column(
              children: [
                selectedPath == null
                    ? ListTile(
                        title: Text('Select Folder Path'),
                        subtitle: Text('Press Me'),
                        onTap: () =>
                            _pickDir(writePerm: true, persistPerm: true),
                      )
                    : Platform.isAndroid || Platform.isIOS
                    ? Expanded(
                        child: MobileListView(
                          files: files,
                          deleteFile: _deleteFile,
                          listFiles: _listFiles,
                        ),
                      )
                    : Expanded(
                        child: DesktopGridView(
                          files: files,
                          deleteFile: _deleteFile,
                          listFiles: _listFiles,
                        ),
                      ),
              ],
            ),
    );
  }
}
