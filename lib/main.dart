import 'dart:convert';
import 'dart:io';

import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:fiveLPOS/components/dashboard.dart';
import 'package:fiveLPOS/components/settings.dart';
import 'package:flutter/material.dart';
import 'package:fiveLPOS/components/posconfig.dart';
import 'package:fiveLPOS/repository/dbhelper.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  if (Platform.isAndroid) {
    DatabaseHelper dh = DatabaseHelper();
    dh.database;
  } else if (Platform.isWindows) {
// Initialize the sqflite FFI bindings
    // sqfliteFfiInit();

    // // Set the databaseFactory to use the FFI version
    // databaseFactory = databaseFactoryFfi;

    // // Now you can use the database APIs
    // openDatabase('posconfig.db', version: 1, onCreate: (db, version) {
    //   // Create your database schema here
    //   db.execute(
    //       'CREATE TABLE pos (posid int, posname varchar(10), serial varchar(20), min varchar(50), ptu varchar(50))');
    //   print('done creating pos table');
    //   db.execute(
    //       'CREATE TABLE branch (branchid varchar(5), branchname varchar(300), tin varchar(60), address varchar(300), logo TEXT)');
    //   print('done creating branch table');
    //   db.execute(
    //       'CREATE TABLE email (emailaddress varchar(300), emailpassword varchar(300), emailserver varchar(300))');
    //   print('done creating email table');
    //   db.execute(
    //       'CREATE TABLE login (employeeid varchar(300), fullname varchar(300), accesstype varchar(300), positiontype varchar(300))');
    //   print('done creating login table');
    //   db.execute(
    //       'CREATE TABLE printer (name varchar(300), ipaddress varchar(15), paperwith varchar(120))');
    //   print('done creating printer table');
    // }).then((db) {
    //   // Database is now open and ready to use
    // }).catchError((error) {
    //   // Handle any errors during database initialization
    //   print('Error opening database: $error');
    // });
  }

  if (Platform.isWindows) {
    createJsonFile('pos.json');
    createJsonFile('email.json');
    createJsonFile('branch.json');
  }

  runApp(const MyApp());
}

void createJsonFile(filename) {
  try {
    // Get the current working

    final String currentDirectory = Directory.current.path;

    // Specify the file name and path
    final String filePath = '$currentDirectory/$filename';

    // Create a File object
    final File file = File(filePath);

    if (file.existsSync()) {
      return;
    }

    // Create a Map (or any other data structure) to convert to JSON
    final Map<String, dynamic> jsonData = {'key': 'value'};

    // Convert the Map to a JSON string
    final jsonString = jsonEncode(jsonData);

    // Write the JSON string to the file
    file.writeAsStringSync(jsonString);

    print('JSON file created successfully at: $filePath');
  } catch (e) {
    print('Error creating JSON file: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal),
      ),
      initialRoute: '/', // Set the initial route
      home: const PosConfig(),
      routes: {
        '/setting': (context) => const SettingsPage(),
      },
    );
  }
}
