import 'package:sqlite3/sqlite3.dart';

class DatabaseHelperSql3 {
  late Database database;

  DatabaseHelperSql3() {
    openDatabase();
  }

  void openDatabase() {
    database = sqlite3.open('sample.db');
    database.execute('''
      CREATE TABLE sample_table (
        id INTEGER PRIMARY KEY,
        name TEXT,
        age INTEGER
      )
    ''');
  }
}
