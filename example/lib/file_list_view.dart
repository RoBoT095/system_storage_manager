import 'package:flutter/material.dart';

import 'package:system_storage_manager/system_storage_manager.dart';

class FileListView extends StatefulWidget {
  const FileListView({
    super.key,
    required this.files,
    required this.deleteFile,
    required this.listFiles,
    required this.selectedFile,
  });

  final List<FileItem> files;
  final Function deleteFile;
  final Function listFiles;
  final Function(String? file) selectedFile;

  @override
  State<FileListView> createState() => _FileListViewState();
}

class _FileListViewState extends State<FileListView> {
  FileItem? _selectedFile;
  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) {
      return Center(child: Text('No files or directories here'));
    }
    return ListView.builder(
      itemCount: widget.files.length,
      itemBuilder: (context, index) {
        final file = widget.files[index];
        return ListTile(
          leading: file.isDir
              ? Icon(Icons.folder, color: Colors.purple)
              : Icon(
                  _selectedFile == file ? Icons.check : Icons.insert_drive_file,
                  color: Colors.blue,
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
            style: TextStyle(overflow: TextOverflow.ellipsis),
            softWrap: true,
            maxLines: 2,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => widget.deleteFile(file.uri),
          ),
          onTap: file.isDir
              ? () {
                  widget.listFiles(uri: file.uri);
                }
              : () {
                  if (_selectedFile != file) {
                    widget.selectedFile(file.uri);
                    setState(() => _selectedFile = file);
                  } else {
                    widget.selectedFile(null);
                    setState(() => _selectedFile = null);
                  }
                },
        );
      },
    );
  }
}
