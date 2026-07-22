import 'dart:io';
import 'package:flutter_media_store/flutter_media_store.dart';

class MediaStoreServices {

  static Future<void> pushToInternal(String tempFilePath, title, mimeType) async {
    final mediastore = FlutterMediaStore();
    final bytes = await File(tempFilePath).readAsBytes();
    final safeTitle = title.replaceAll(
      RegExp(r'[<>:"/\\|?*]'),
      "_",
    );
    try {
      await mediastore.saveFile(
        fileData: bytes,
        mimeType: "video/mp4",
        rootFolderName: "You Pirate",
        folderName: "Videos",
        fileName: "${safeTitle}.mp4",
        onSuccess: (uri, path) async {
          final tempFile = File(tempFilePath);
          if(await tempFile.exists()) {
            tempFile.delete();
            print("Temp File Deleted");
          }
          print(uri);
          print(path);
        },
        onError: (error) {
          print(error);
        },
      );
    } catch (error) {
      throw Exception(error);
    }
  }
}
