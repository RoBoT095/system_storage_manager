import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:system_storage_manager/system_storage_manager.dart';
import 'package:system_storage_manager_demo/file_list_view.dart';
import 'package:system_storage_manager_demo/text_editor.dart';

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
  bool isMoving = false;
  bool loading = true;

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
        selectedFile = null;
        isMoving = false;
      });
      _listFiles();
    }
  }

  Future<void> _pickFile() async {
    // TODO
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

  Future<void> _create(String name) async {
    try {
      await manager.create(currentPath, name);
      _listFiles();
    } catch (e) {
      debugPrint('Create Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Creating Error: $e')));
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
      ).showSnackBar(SnackBar(content: Text('Deleting Error: $e')));
    }
  }

  Future<void> _copy() async {
    // TODO
  }

  Future<void> _move(String fromUri, String toUri) async {
    try {
      await manager.move(fromUri, toUri);
      setState(() => isMoving = false);
      selectedFile = null;
      _listFiles(uri: currentPath);
    } catch (e) {
      debugPrint('Move Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Moving Error: $e')));
    }
  }

  Future<void> _rename(String uri, String newName) async {
    try {
      await manager.rename(uri, newName);
      selectedFile = null;
      _listFiles();
    } catch (e) {
      debugPrint('Rename Error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Renaming Error: $e')));
    }
  }

  Future<void> _openFile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextEditor(fileUri: selectedFile!),
      ),
    );
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
        title: const Text('SSM Example'),
        actions: [
          IconButton(
            onPressed: () => _showInfoDialog(),
            icon: Icon(Icons.info_outline),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = MediaQuery.sizeOf(context).width;
                      final maxWidth = constraints.maxWidth;
                      final double buttonWidth = screenWidth > 650
                          ? (maxWidth / 3 - 16)
                          : screenWidth > 320
                          ? (maxWidth / 2 - 16)
                          : (maxWidth / 1 - 16);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildButtonCard(
                              'Select Folder',
                              () =>
                                  _pickDir(writePerm: true, persistPerm: true),
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              'Pick File',
                              () => _pickFile(),
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              'Pick Multiple Files',
                              () {},
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              'Create file',
                              () async => await _showTextDialog(
                                title: 'Create',
                                hint: 'Enter file name',
                                (name) => _create(name),
                              ),
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              'Open File',
                              selectedFile == null ? null : () => _openFile(),
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              'Copy',
                              selectedFile == null ? null : () => _copy(),
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              isMoving ? 'Drop Here' : 'Move',
                              selectedFile == null
                                  ? null
                                  : () {
                                      if (!isMoving) {
                                        setState(() => isMoving = true);
                                      } else {
                                        _move(selectedFile!, currentPath);
                                      }
                                    },
                              buttonWidth,
                            ),
                            _buildButtonCard(
                              'Rename',
                              selectedFile == null
                                  ? null
                                  : () async => await _showTextDialog(
                                      title: 'Rename',
                                      hint: 'Enter new name',
                                      (newName) =>
                                          _rename(selectedFile!, newName),
                                    ),
                              buttonWidth,
                            ),
                          ],
                        ),
                      );
                    },
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
            ),
    );
  }

  Future<void> _showTextDialog(
    Function(String name) onConfirm, {
    required String title,
    String? hint,
  }) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(hintText: hint),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm(controller.text);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonCard(String label, VoidCallback? onPressed, double width) {
    return SizedBox(
      width: width,
      child: Card(
        child: TextButton(
          onPressed: onPressed,
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  Future<void> _showInfoDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('INFO'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _textHeader('Selected Path:'),
            Text('$selectedPath'),
            _textHeader('Current Path:'),
            Text(currentPath),
            _textHeader('Selected File:'),
            Text('$selectedFile'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('close'),
          ),
        ],
      ),
    );
  }

  Widget _textHeader(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
    );
  }
}
