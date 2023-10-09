import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pos2/components/posconfig.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isAndroid) {
  } else if (Platform.isWindows) {
    // Initialize the sqflite FFI bindings
    sqfliteFfiInit();

    // Set the databaseFactory to use the FFI version
    databaseFactory = databaseFactoryFfi;

    // Now you can use the database APIs
    openDatabase('posconfig.db', version: 1, onCreate: (db, version) {
      // Create your database schema here
      db.execute(
          'CREATE TABLE pos (posid int, posname varchar(10), serial varchar(20), min varchar(50), ptu varchar(50))');
      print('done creating pos table');
      db.execute(
          'CREATE TABLE branch (branchid varchar(5), branchname varchar(300), tin varchar(60), address varchar(300), logo TEXT)');
      print('done creating branch table');
      db.execute(
          'CREATE TABLE email (emailaddress varchar(300), emailpassword varchar(300), emailserver varchar(300))');
      print('done creating email table');
    }).then((db) {
      // Database is now open and ready to use
    }).catchError((error) {
      // Handle any errors during database initialization
      print('Error opening database: $error');
    });
  }

  runApp(const MyApp());
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
    );
  }
}
