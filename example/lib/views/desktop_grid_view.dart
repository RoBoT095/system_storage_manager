import 'package:flutter/material.dart';

import 'package:system_storage_manager/system_storage_manager.dart';

class DesktopGridView extends StatelessWidget {
  const DesktopGridView({
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
    return GridView.builder(
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
          ),
        );
      },
    );
  }
}
