import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> readData(path) async {
    try {
      final file = File('$path');
      String body = await file.readAsString();
      return body;
    } catch (e) {
      return e.toString();
    }
  }

  // Future<File> writeData(String data) async {
  //   final file = await localFile;
  //   return file.writeAsString("$data");
  // }
}
