import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class FileManager {


// Public method to get the file path for PDF
  Future<String> getPdfPath() async {
    final path = await _appPath;
    return '$path/timetable.pdf';
  }

  // Public method to write PDF data
  Future<File> writePdf(Uint8List bytes) async {
    final path = await getPdfPath();
    final file = File(path);
    return file.writeAsBytes(bytes);
  }

  
  // Get the path to the app-specific directory.
  Future<String> get _appPath async {
    final directory = await getApplicationDocumentsDirectory();  // This directory is private to the app.
    return directory.path;
  }
  
Future<File> writePdfFile(Uint8List bytes) async {
  final file = await _timetableFile;
  return file.writeAsBytes(bytes);
}
  // Get the timetable file in the app-specific directory.
  Future<File> get _timetableFile async {
    final path = await _appPath;
    return File('$path/timetable.json');
  }

  // Write data to the file.
  Future<File> writeTimetable(String jsonData) async {
    final file = await _timetableFile;
    print("Saving data to ${file.path}");
    return file.writeAsString(jsonData);
  }

  // Read data from the file.
  Future<String> readTimetable() async {
    try {
      final file = await _timetableFile;
      return file.readAsString();
    } catch (e) {
      print('Error reading file: $e');
      throw Exception('Failed to read file');
    }
  }












   Future<String> ensureCustomDirectory(String dirName) async {
    final directory = await getApplicationDocumentsDirectory();
    final customDir = Directory('${directory.path}/$dirName');
    if (!await customDir.exists()) {
      await customDir.create();
      print('Directory created: $customDir');
    } else {
      print('Directory already exists: $customDir');
    }
    return customDir.path;
  }

  // Public method to write PDF data to a custom directory
  Future<File> writePdfToCustomDirectory(Uint8List bytes, String dirName, String fileName) async {
    final path = await ensureCustomDirectory(dirName);
    final file = File('$path/$fileName');
    return file.writeAsBytes(bytes);
  }


  Future<String> getDocumentsPath() async {
    final directory = await getApplicationDocumentsDirectory();  // This is for more persistent storage
    return directory.path;
  }

  // Method to save the PDF in the Documents directory
  Future<File> savePdfToDocuments(Uint8List pdfBytes, String fileName) async {
    final path = await getDocumentsPath();
    final file = File('$path/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file;
  }


  // Example of a read method for custom directory
  Future<String> readTimetableFromCustomDirectory(String dirName, String fileName) async {
    try {
      final path = await ensureCustomDirectory(dirName);
      final file = File('$path/$fileName');
      return file.readAsString();
    } catch (e) {
      print('Error reading file from custom directory: $e');
      throw Exception('Failed to read file from custom directory');
    }
  }
}
