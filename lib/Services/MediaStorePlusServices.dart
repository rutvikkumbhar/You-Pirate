import 'package:media_store_plus/media_store_plus.dart';

class MediaStorePlusServices {
  static Future<void> pushVideoToInternal(String tempPath) async {
    final mediaStore = MediaStore();
    try {
      final result = await mediaStore.saveFile(
          tempFilePath: tempPath,
          dirType:DirType.video,
          dirName: DirName.dcim);
      if(result != null) {
        print(result.saveStatus);
        print(result.isSuccessful);
        print(result.uri);
      }
    } catch(error){
      throw Exception(error.toString());
    }
  }
  static Future<void> pushAudioToInternal (String tempPath) async {
    final mediaStore = MediaStore();
    try {
      final result = await mediaStore.saveFile(
          tempFilePath: tempPath,
          dirType: DirType.audio,
          dirName: DirName.music);
      if(result != null ){
        print(result.saveStatus);
        print(result.isSuccessful);
        print(result.uri);
      }
    } catch(error) {
      throw Exception(error.toString());
    }
  }
}