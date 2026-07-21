import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatelessWidget {

  final urlController = TextEditingController();
  final dio = Dio();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Media Ripping App"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              keyboardType: TextInputType.url,
              decoration: InputDecoration(hintText: "http://"),
              controller: urlController,
            ),
          ),
          SizedBox(height: 50,),
          ElevatedButton(
            child: Text("Download"),
            onPressed: (){
              String url = urlController.text.trim().toString();
              dio.download(
                  url,
                  "android/emulated/0/download/fileName.bat").then((data)=>{
                    print("Media downloaded")
              }).onError((error, stackTrace)=>{
                print("Error ${error.toString()}")
              });
            }
          )
        ],
      )
    );
  }
}