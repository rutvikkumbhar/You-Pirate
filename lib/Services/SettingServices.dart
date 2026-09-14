import 'package:shared_preferences/shared_preferences.dart';

class SettingServices {
  static const String incognitoDownloadKey = "incognito_download";
  static const String downloadNotificationKey = "download_notification";

  static Future<bool> isIncognitoDownload () async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(incognitoDownloadKey) ?? false;
  }
  static Future<void> setIncognitoDownload(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(incognitoDownloadKey, value);
  }
  static Future<bool> isDownloadNotificationEnabled() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(downloadNotificationKey) ?? true;
  }
  static Future<void> setDownloadNotification(bool value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(downloadNotificationKey, value);
  }
}