import 'package:media_store_plus/media_store_plus.dart';

class MediaStorePlusServices {

  static Future<SaveInfo?> pushVideoToInternal(String tempPath) async {
    final mediaStore = MediaStore();
    try {
      final result = await mediaStore.saveFile(
        tempFilePath: tempPath,
        dirType: DirType.video,
        dirName: DirName.dcim,
      );
      return result;
    } catch(error) {
      rethrow;
    }
  }

  static Future<SaveInfo?> pushAudioToInternal (String tempPath) async {
    final mediaStore = MediaStore();
    try {
      final result = await mediaStore.saveFile(
          tempFilePath: tempPath,
          dirType: DirType.audio,
          dirName: DirName.music);
      return result;
    } catch(error) {
      rethrow;
    }
  }
}