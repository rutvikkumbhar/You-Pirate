import 'package:media_store_plus/media_store_plus.dart';

class MediaStorePlusServices {
  static Future<void> pushVideoToInternal(String tempPath) async {
    final mediaStore = MediaStore();
    final result = await mediaStore.saveFile(
        tempFilePath: tempPath,
        dirType:DirType.video,
        dirName: DirName.dcim);
    if(result != null) {
      print(result.saveStatus);
      print(result.isSuccessful);
      print(result.uri);
    }
  }
}