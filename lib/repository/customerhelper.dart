import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';

import 'package:pos2/model/branch.dart';

class Helper {
  String GetCurrentDatetime() {
    DateTime currentDateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd HH:mm').format(currentDateTime);
    return formattedDateTime;
  }

  Future<String> readJsonFile(String filePath) async {
    String fileContent = await readFileContent(filePath);
    return fileContent;
  }

  Future<String> readFileContent(String filePath) async {
    try {
      File file = File(filePath);
      return await file.readAsString();
    } catch (e) {
      print('Error reading file: $e');
      return '';
    }
  }

  String formatAsCurrency(double value) {
    return '${toCurrencyString(value.toString())}';
  }

  Future<void> deleteFile(String filepath) async {
    try {
      File file = File(filepath);

      if (await file.exists()) {
        await file.delete();
      } else {
        print('File not found');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
