import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:system_storage_manager/system_storage_manager.dart';
import 'package:system_storage_manager_demo/file_list_view.dart';

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
  late String defaultPath;
  String? selectedPath;
  String currentPath = '/';
  String? selectedFile;
  List<FileItem> files = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultDir();
  }

  void _loadDefaultDir() async {
    setState(() => loading = true);
    final appDoc = await getApplicationDocumentsDirectory();
    setState(() {
      defaultPath = appDoc.uri.toString();
      selectedPath = defaultPath;
      currentPath = defaultPath;
      loading = false;
    });
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
      currentPath = uri ?? selectedPath ?? defaultPath;
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
      appBar: AppBar(title: const Text('SSM Example')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text('Selected Path: $selectedPath'),
                Text('Current Path: $currentPath'),
                Text('Selected File: $selectedFile'),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 2,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Card(
                        child: TextButton(
                          onPressed: () =>
                              _pickDir(writePerm: true, persistPerm: true),
                          child: Text('Select Folder'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () => _createFile(),
                          child: Text('Create file'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Read File'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Write to File'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Copy'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Move'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Rename'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Pick File'),
                        ),
                      ),
                      Card(
                        child: TextButton(
                          onPressed: () {},
                          child: Text('Pick Multiple Files'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text('File System View'),
                      leading:
                          selectedPath != null && selectedPath != currentPath
                          ? IconButton(
                              icon: Icon(Icons.chevron_left),
                              onPressed: _goBack,
                            )
                          : null,
                      actions: [
                        if (selectedPath != null)
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => _listFiles(uri: currentPath),
                          ),
                      ],
                    ),
                    body: FileListView(
                      files: files,
                      deleteFile: _deleteFile,
                      listFiles: _listFiles,
                      selectedFile: (file) => setState(() {
                        selectedFile = file;
                      }),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
