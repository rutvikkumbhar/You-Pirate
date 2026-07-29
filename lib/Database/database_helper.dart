import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseHelper {
  static Database? _db;
  static final DatabaseHelper _databaseServices = DatabaseHelper._();
  DatabaseHelper._();

  static Future<Database> get database async {
    if(_db != null ) return _db!;
    _db = await getDatabase();
    return _db!;
  }

  static Future<Database> getDatabase () async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = path.join(dir.path, "downloads.db");
    final database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        db.execute('''
        CREATE TABLE download_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          thumbnail TEXT NOT NULL,
          sourceUrl TEXT NOT NULL,
          platform TEXT NOT NULL,
          mediaType TEXT NOT NULL,
          formatId TEXT NOT NULL,
          quality TEXT NOT NULL,
          extension TEXT NOT NULL,
          filePath TEXT NOT NULL,
          fileSize TEXT NOT NULL,
          duration TEXT NOT NULL,
          downloadDate TEXT NOT NULL,
          status INTEGER DEFAULT 1
          );
        ''');
      }
    );
    return database;
  }
}