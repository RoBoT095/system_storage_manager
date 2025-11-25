# WORK IN PROGRESS

Still in development with many bugs and unfinished functions as well has little to no error handling

**TODO:**

- Add File and Directory differentiation
- Throw errors if used incorrectly
- TEST! TEST! TEST!

# System Storage Manager (aka SSM)

A cross platform layer that uses SAF for Android and Dart:io for other platforms

> Created mainly for [Print(Notes)](https://github.com/RoBoT095/printnotes)!

For android's SAF (Storage Access Framework), this library uses [saf_stream](https://github.com/flutter-cavalry/saf_stream) for reading and writing files
and [saf_util](https://github.com/flutter-cavalry/saf_util) for everything else.

For other platforms, files are derived from `File.fromUri(Uri.parse(uriString))` and treated as a `FileSystemEntity`.

**Note:** URIs on other platforms tend to follow "file" scheme so they look like this:

```python
# unix-like systems
file:///home/<USERNAME>/Documents/file.txt
# or windows
file:///C:/Users/<USERNAME>/Documents/file.txt
# or ios
file:///var/mobile/Containers/Data/Application/<APP-UUID>/Documents/Library/tmp/
```

While with androids SAF, you get "content" scheme uri that look like

```
content://com.android.externalstorage.documents/tree/primary%3ADocuments/document/primary%3ADocuments%2Ffile.txt
```

## Usage Example:

Check out `example/` folder for more

```dart
import 'package:system_storage_manager/system_storage_manager.dart';

final _ssm = SystemStorageManager();

/// Select a directory
final FileItem? dir = await _ssm.pickDir();
print(dir.uri); // content://...
print(dir.name); // name of selected folder
print(dir.isDir); // it is a directory so true

/// Selecting a file
await _ssm.pickFile(allowedExtensions: ['txt', 'md']); // Opens a file picker and returns a [FileItem]

/// Selecting multiple files
await _ssm.pickFiles(); // returns a list of [FileItem]s that were selected

// Getting a list of files/folder in a folder
await _ssm.listFiles(dir.uri, showHidden: false); // returns list of [FileItem]s and skips any that start with "." aka hidden files

/// Creating files/folders
final FileItem file = await _ssm.create(dir.uri, 'file.txt', isDir: false); // returns the newly created [FileItem]

/// Renaming
file = await _ssm.rename(file.uri, 'New_${file.name}'); // returns the renamed [FileItem] or 'New_file.txt'

/// Deleting
await _ssm.delete(file.uri); // returns true or false if deletion was successful

/// Checking if file/folder exists
await _ssm.exists(file.uri); // false, you just deleted it =D

/// Getting the parent folder of a file, harder to do with content than with the absolute path like structure of file scheme
await _ssm.parentUri(file.uri); // If file in "../Documents/file.txt" then you will get "../Documents"

/// Copying
final FileItem newLocation = await _smm.pickDir();
final FileItem fileCopy = await _ssm.copy(file.uri, newLocation.uri); // returns the new copied [FileItem]

/// Moving
file = await _ssm.move(fileCopy.uri, dir.uri); // returns the file/folder with its new location, though you just overwrote `file` with `fileCopy` in code and in device storage, careful what you do

// Now the juicy parts

/// Reading files
final String fileText = await _ssm.readAsString(file.uri); // returns data as [String]
final Uint8List fileBytes = await _ssm.readAsBytes(file.uri); // returns data as [List<int>], you can use as [Uint8List]

/// Writing Files
await _ssm.writeAsString(file.uri, fileText, mime: 'text/plain'); // writes data to file and returns the file as a [FileItem]
await _ssm.writeAsBytes(file.uri, fileBytes, mime: 'text/plain'); // writes data bytes to file and returns the file as a[FileItem]
```
