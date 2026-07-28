import 'package:you_pirate_app/Database/database_helper.dart';

class DatabaseServices {
  Future<int> insertDownload(Map<String, dynamic> data) async {
    final db = await DatabaseHelper.database;
    return await db.insert(
      "download_history",
      data,
    );
  }
}