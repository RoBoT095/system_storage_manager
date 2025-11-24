import 'package:flutter/material.dart';

import 'package:system_storage_manager/system_storage_manager.dart';

class MobileListView extends StatelessWidget {
  const MobileListView({
    super.key,
    required this.files,
    required this.deleteFile,
    required this.listFiles,
  });

  final List<FileItem> files;
  final Function deleteFile;
  final Function listFiles;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final file = files[index];
        return ListTile(
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
            file.uri,
            style: TextStyle(overflow: TextOverflow.ellipsis),
            softWrap: true,
            maxLines: 2,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => deleteFile(file.uri),
          ),
          onTap: file.isDir
              ? () {
                  listFiles(uri: file.uri);
                }
              : null,
        );
      },
    );
  }
}
