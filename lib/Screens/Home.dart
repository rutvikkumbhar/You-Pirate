import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:you_pirate_app/API%20Services/VideoServices.dart';
import 'package:path_provider/path_provider.dart';
import 'package:you_pirate_app/Services/MediaStorePlusServices.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final urlController = TextEditingController();
  final dio = Dio();
  final path = "/storage/emulated/0/Download/";
  double progress = 0;
  int totalBytes = 0;
  int receivedBytes = 0;
  Map<String, dynamic>? videoInfo;
  bool infoLoading = false;
  bool downloadLoading = false;

  String bytesToMb(int bytes){
    return (bytes/ (1024*1024)).toStringAsFixed(2);
  }

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: infoLoading? CircularProgressIndicator() : Text("Meta Data"),
                onPressed: () async{
                  setState(()=>infoLoading=true);
                  String url = urlController.text;
                  try {
                    await VideoServices.getVideoInfo(url).then((result)=>{
                      setState(()=>infoLoading=false),
                      videoInfo = result,
                    }).onError((error, stackTrace){
                      setState(()=>infoLoading=false);
                      throw error.toString();
                    });
                    setState(()=>{});
                  } catch(error){
                    print("ERROR: ${error.toString()}");
                  }
                },
              ),
              ElevatedButton(
                  child: downloadLoading?CircularProgressIndicator():Text("Download"),
                  onPressed: () async {
                    setState(()=>downloadLoading=true);
                    String url = urlController.text.trim().toString();
                    debugPrint("URL: ${url}");
                    Directory dir = await getApplicationDocumentsDirectory();
                    String savePath = "${dir.path}/${videoInfo!['title']}.mp4";
                    debugPrint("FILE PATH: ${savePath}");
                    VideoServices.downloadVideo(
                        url,
                        savePath).then((result) async =>{
                          debugPrint("Media downloaded"),
                          debugPrint("Pushing file into Internal Storage"),
                      await MediaStorePlusServices.pushVideoToInternal(savePath),
                      setState(()=>downloadLoading=false),
                      debugPrint("Stored into Internal Storage"),
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download Completed"))),
                    }).onError((error, stackTrace)=>{
                    setState(()=>downloadLoading=false),
                      debugPrint("Failed to  download ERROR: ${error.toString()}"),
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to  download"))),
                    });
                    // await dio.download(
                    //     url,
                    //     path+"${videoInfo!['title']}.mp4",
                    //     onReceiveProgress: (received, total)=>{
                    //       if(total!=-1){
                    //         progress = received/total,
                    //         totalBytes = total,
                    //         receivedBytes=received,
                    //         setState(()=>{}),
                    //       }
                    //     }).then((data)=>{
                    //   print("Media downloaded"),
                    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download Completed"))),
                    // }).onError((error, stackTrace)=>{
                    //   print("Error ${error.toString()}")
                    // });
                  }
              ),
            ],
          ),
          SizedBox(height: 30,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red)
              ),
              child: Column(
                children: [
                  if(progress==0)
                    SizedBox()
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        children: [
                          Expanded(
                            child: LinearProgressIndicator(
                              color: Colors.red,
                              value: progress,
                            ),
                          ),
                          SizedBox(width: 10,),
                          Text("${(progress*100).toStringAsFixed(1)}%")
                        ],
                      ),
                    ),
                  SizedBox(height: 10,),
                  if(progress==0)
                    SizedBox()
                  else
                    Text("${bytesToMb(receivedBytes)}MB / ${bytesToMb(totalBytes)}MB")
                ],
              ),
            ),
          ),
          SizedBox(height: 10,),
          if (videoInfo != null)
            Text(videoInfo!['title'])
        ],
      )
    );
  }
}