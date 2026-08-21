import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:you_pirate_app/Screens/Home.dart';
import 'package:flutter/material.dart';

class VideoServices {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> getVideoInfo(String url) async {
    final uri = Uri.parse("$baseUrl/user/video/info");
    try {
      final response = await http.post(
          uri,
          headers: {
            "Content-Type" : "application/json"
          },
          body: jsonEncode({
            "url": url,
          })
      );
      if(response.statusCode == 200){
        return jsonDecode(response.body);
      } else if(response.statusCode == 400){
        throw jsonDecode(response.body);
      } else {
        throw {
          'success': false,
          'message': "Unable to connect with Server"
        };
      }
    } catch(error) {
      rethrow;
    }
  }

  static Future<bool> downloadVideo({
    required String url,
    required String savePath,
    required CancelToken downloadCancelToken,
    required void Function(int recieved, int total) onProgress}) async {
    Dio dio = Dio();
    final endpoint = "$baseUrl/user/video/quickdownload";
    try {
      await dio.download(
          endpoint,
          savePath,
          data: {
            "url": url
          },
          options: Options(
              method: "POST",
              contentType: "application/json"
          ),
          onReceiveProgress: onProgress,
          cancelToken: downloadCancelToken,
      );
      return true;
    } on DioException catch(e) {
      if (e.response != null) {
        print(e.response?.statusCode);
        print(e.response?.data);
        print(e.response?.data.runtimeType);
        return true;
      } else if(CancelToken.isCancel(e)) {
        print("Download Canceled");
        return false;
      } else if(e.response!.statusCode == 400) {
        throw jsonDecode(e.response!.data);
      } else {
        throw {
          'success': false,
          'message': "Unable to connect with Server"
        };
      }
    }
  }

  static Future<bool> downloadFileById({
    required String url,
    required String formatId,
    required String savePath,
    required bool isVideo,
    required CancelToken downloadCancelToken,
    required void Function(int received, int total) onProgress
  }) async {
    final endPoint = isVideo ?
    "${baseUrl}/user/video/qualitydownload" :
    "${baseUrl}/user/audio/qualitydownload" ;

    final Dio dio = Dio();

    try {
      await dio.download(
        endPoint,
        savePath,
        data: {
          "url": url,
          "formatId": formatId
        },
        options: Options(
          method: "POST",
          contentType: "application/json"
        ),
        onReceiveProgress: onProgress,
        cancelToken: downloadCancelToken
      );
      return true;
    } on DioException catch(e) {
      if (e.response != null) {
        print(e.response?.statusCode);
        print(e.response?.data);
        print(e.response?.data.runtimeType);
        return true;
      } else if(CancelToken.isCancel(e)) {
        print("Download Canceled");
        return false;
      } else if(e.response!.statusCode == 400) {
        throw jsonDecode(e.response!.data);
      } else  {
        throw {
          'success': false,
          'message': "Unable to connect with Server"
        };
      }
    }
  }
}
