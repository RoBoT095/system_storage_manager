import 'package:flutter/material.dart';

import 'package:system_storage_manager/system_storage_manager.dart';

class FileListView extends StatefulWidget {
  const FileListView({
    super.key,
    required this.files,
    required this.deleteFile,
    required this.listFiles,
    required this.selectedFile,
    required this.selectedFolder,
  });

  final List<FileItem> files;
  final Function deleteFile;
  final Function listFiles;
  final Function(String? file) selectedFile;
  final Function(String? folder) selectedFolder;

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  FileItem? _selectedFile;
  FileItem? _selectedFolder;

  void _toggleFolderSelection(FileItem folder) {
    if (_selectedFolder == folder) {
      widget.selectedFolder(null);
      setState(() => _selectedFolder = null);
      return;
    }

    widget.selectedFolder(folder.uri);
    widget.selectedFile(null);
    setState(() {
      _selectedFolder = folder;
      _selectedFile = null;
    });
  }

  void _toggleFileSelection(FileItem file) {
    if (_selectedFile == file) {
      widget.selectedFile(null);
      setState(() => _selectedFile = null);
      return;
    }

    widget.selectedFile(file.uri);
    widget.selectedFolder(null);
    setState(() {
      _selectedFile = file;
      _selectedFolder = null;
    });
  }

  void _onFolderOpen(FileItem folder) {
    if (_selectedFolder == folder) {
      _toggleFileSelection(folder);
    } else {
      widget.listFiles(uri: folder.uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) {
      return Center(child: Text('No files or directories here'));
    }
    return ListView.builder(
      itemCount: widget.files.length,
      itemBuilder: (context, index) {
        final file = widget.files[index];
        final isFolder = file.isDir;

        return ListTile(
          leading: Icon(
            isFolder
                ? (_selectedFolder == file ? Icons.check : Icons.folder)
                : (_selectedFile == file
                      ? Icons.check
                      : Icons.insert_drive_file),
            color: isFolder ? Colors.purple : Colors.blue,
          ),
          title: Text(
            file.name,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            file.uri,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            maxLines: 2,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => widget.deleteFile(file.uri),
          ),
          onLongPress: isFolder ? () => _toggleFolderSelection(file) : null,
          onTap: isFolder
              ? () => _onFolderOpen(file)
              : () => _toggleFileSelection(file),
        );
      },
    );
  }
}
