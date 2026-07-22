import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';

class VideoServices {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  static Future<Map<String, dynamic>> getVideoInfo(String url) async {
    final uri = Uri.parse("$baseUrl/user/video/info");
    final response = await http.post(
      uri,
      headers: {
        "Content-Type" : "application/json"
      },
      body: jsonEncode({
        "url": url,
      })
    );
    if(response.statusCode==200){
      return jsonDecode(response.body);
    } else if(response.statusCode==400){
      throw Exception(response.body);
    } else {
      throw Exception(response.body);
    }
  }

  static Future<void> downloadVideo(String url, String savePath) async {
    Dio dio = Dio();
    final endpoint = "$baseUrl/user/video/download";
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
          onReceiveProgress: (received, total) {
            if (total != -1) {
              print("${(received / total * 100).toStringAsFixed(1)}%");
            }
          }
      );
    } catch(error){
      print(error.toString());
      throw Exception(error);
    }
  }
}
