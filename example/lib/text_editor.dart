import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:system_storage_manager/system_storage_manager.dart';

class TextEditor extends StatefulWidget {
  const TextEditor({super.key, required this.fileUri});

  final String fileUri;

  @override
  State<TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<TextEditor> {
  final manager = SystemStorageManager();
  final textController = TextEditingController();
  final undoController = UndoHistoryController();
  String content = '';
  bool editMode = false;

  @override
  void initState() {
    _loadFile();
    super.initState();
  }

  Future<void> _loadFile() async {
    final fileContent = await manager.readAsString(widget.fileUri);
    setState(() {
      content = fileContent;
      textController.text = fileContent;
    });
  }

  Future<void> _saveText(String editedText) async {
    await manager.writeAsString(widget.fileUri, editedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(path.basename(widget.fileUri)),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              editMode = !editMode;
            }),
            icon: Icon(editMode ? Icons.visibility : Icons.edit),
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: () => setState(() => editMode = !editMode),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: editMode
              ? TextField(
                  controller: textController,
                  onChanged: (value) => _saveText(value),
                  undoController: undoController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(border: InputBorder.none),
                )
              : Text(content, style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
