import 'package:you_pirate_app/Database/database_helper.dart';

class DatabaseServices {
  Future<int> insertDownload(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.database;
    return await db.insert(
      "download_history",
      data,
    );
  }

  Future<List<Map<String, Object?>>> getDownloads () async {
    final db = await DatabaseHelper.database;

    return await db.query(
        "download_history",
      orderBy: "id DESC",
    );
  }

  Future<int> deleteAllDownload() async {
    final db = await DatabaseHelper.database;

    return await db.delete("download_history");
  }

  Future<int> deleteDownloadById(String id) async {
    final db = await DatabaseHelper.database;

    return await db.delete(
      "download_history",
      where: "id = ?",
      whereArgs: [id]
    );
  }
}