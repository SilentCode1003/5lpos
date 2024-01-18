import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    return _database ?? await _initDatabase();

    // if (_database != null) return _database;
    // _database = await _initDatabase();
    // return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'posconfig.db');

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute(
        'CREATE TABLE pos (posid int, posname varchar(10), serial varchar(20), min varchar(50), ptu varchar(50))');
    print('done creating pos table');
    await db.execute(
        'CREATE TABLE branch (branchid varchar(5), branchname varchar(300), tin varchar(60), address varchar(300), logo TEXT)');
    print('done creating branch table');
    await db.execute(
        'CREATE TABLE email (emailaddress varchar(300), emailpassword varchar(300), emailserver varchar(300))');
    print('done creating email table');

    await db.execute(
        'CREATE TABLE login (employeeid varchar(300), fullname varchar(300), accesstype varchar(300), positiontype varchar(300))');
    print('done creating login table');
    await db.execute(
        'CREATE TABLE printer (name varchar(300), ipaddress varchar(15), paperwith varchar(120))');
    print('done creating printer table');
  }

  Future<int> insertItem(Map<String, dynamic> item, String tablename) async {
    Database db = await database;
    return await db.insert(tablename, item);
  }

  Future<void> updateItem(Map<String, dynamic> data, String tablename,
      String condition, dynamic agrs) async {
    Database db = await database;

    await db.update(tablename, data, where: condition, whereArgs: [agrs]);
  }
}
