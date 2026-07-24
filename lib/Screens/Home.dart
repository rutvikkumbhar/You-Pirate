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
  List<dynamic>? formats;
  bool infoLoading = false;
  bool downloadLoading = false;

  String bytesToMb(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2);
  }

  String mbToGb(int mb) {
    return (mb / 1024).toStringAsFixed(2);
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Media Ripping App"), centerTitle: true),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              keyboardType: TextInputType.url,
              decoration: InputDecoration(hintText: "http://"),
              controller: urlController,
            ),
          ),
          SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: infoLoading
                    ? CircularProgressIndicator()
                    : Text("Meta Data"),
                onPressed: () async {
                  setState(() => infoLoading = true);
                  String url = urlController.text;
                  try {
                    await VideoServices.getVideoInfo(url)
                        .then(
                          (result) => {
                            setState(() => infoLoading = false),
                            videoInfo = result,
                            formats = videoInfo?['formats'],
                          },
                        )
                        .onError((error, stackTrace) {
                          setState(() => infoLoading = false);
                          throw error.toString();
                        });
                    setState(() => {});
                  } catch (error) {
                    print("ERROR: ${error.toString()}");
                  }
                },
              ),
              ElevatedButton(
                child: downloadLoading
                    ? CircularProgressIndicator()
                    : Text("Download"),
                onPressed: () async {
                  setState(() => downloadLoading = true);
                  String url = urlController.text.trim().toString();
                  debugPrint("URL: ${url}");
                  Directory dir = await getApplicationDocumentsDirectory();
                  String savePath = "${dir.path}/${videoInfo!['title']}.mp4";
                  debugPrint("FILE PATH: ${savePath}");
                  VideoServices.downloadVideo(
                        url: url,
                        savePath: savePath,
                        onProgress: (received, total) => {
                          if (total != -1) {
                              progress = received / total,
                              totalBytes = total,
                              receivedBytes = received,
                              setState(() => {}),
                          },
                        },
                      ).then((result) async => {
                          progress=0,
                          totalBytes=0,
                          receivedBytes=0,
                          debugPrint("Media downloaded"),
                          debugPrint("Pushing file into Internal Storage"),
                          await MediaStorePlusServices.pushVideoToInternal(
                            savePath,
                          ),
                          setState(() => downloadLoading = false),
                          debugPrint("Stored into Internal Storage"),
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Download Completed")),
                          ),
                        },
                      )
                      .onError(
                        (error, stackTrace) => {
                          setState(() => downloadLoading = false),
                          debugPrint(
                            "Failed to  download ERROR: ${error.toString()}",
                          ),
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Failed to  download")),
                          ),
                        },
                      );
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Column(
                children: [
                  if (progress == 0)
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
                          SizedBox(width: 10),
                          Text("${(progress * 100).toStringAsFixed(1)}%"),
                        ],
                      ),
                    ),
                  SizedBox(height: 10),
                  if (progress == 0)
                    SizedBox()
                  else
                    Text(
                      "${bytesToMb(receivedBytes)}MB / ${bytesToMb(totalBytes)}MB",
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              height: 180,width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  image: DecorationImage(image: NetworkImage(videoInfo?['thumbnail'] ?? ""),
                      fit: BoxFit.cover)
              ),
            ),
          ),
          SizedBox(height: 10,),
          if (videoInfo != null) Text(videoInfo!['title']),
          Text("Video Formats"),
          Text("ID | Quality | FPS | Size | Ext | VBR"),
          // if (videoInfo != null)Text("${videoInfo?['format_id']} | ${videoInfo?['format_note']} | "
          //     "${videoInfo?['ext']} | ${videoInfo?['fps']} | ${videoInfo?['channel']} | ${videoInfo?['duration_string']}"),
          if(videoInfo != null)
            Container(
              height: 500,width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                itemCount: formats?.length,
                itemBuilder: (context, index) {
                  // Map<String, dynamic> data = formats?[index] as Map<String,dynamic>;
                  final data = formats?[index] as Map<String, dynamic>?;

                  if (data == null) {
                    return const SizedBox.shrink();
                  }

                  final size = data['filesize'];
                  return data['ext']=="mp4"?
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${data['format_id']} | "
                                "${data['format_note']} | "
                                "${data['fps']} | "
                                "${size == null ? 'Unknown' : '${double.parse(bytesToMb(size))>1024?(double.parse(bytesToMb(size))/1024).toStringAsFixed(2)+" GB":bytesToMb(size)+" MB"}'} | "
                                "${data['ext']} | "
                                "${((data['vbr'] ?? 0.0) as num).toInt()}k",
                          ),
                          ElevatedButton(
                            child: Text("Download"),
                            onPressed: () async {
                              String url = urlController.text.toString();
                              debugPrint("URL: ${url}");
                              Directory dir = await getApplicationDocumentsDirectory();
                              String savePath = "${dir.path}/${videoInfo?['title']}.mp4";
                              debugPrint("PATH: ${savePath}");
                              print("Format ID: ${data['format_id']}");
                              try {
                                await VideoServices.downloadVideoById(
                                    url: url,
                                    formatId: data['format_id'],
                                    savePath: savePath,
                                    onProgress: (received, total)=>{
                                      if(totalBytes != -1){
                                        receivedBytes = received,
                                        totalBytes = total,
                                        progress= receivedBytes / totalBytes,
                                        setState(()=>{})
                                      }
                                    }).then((result) async =>{
                                      print("File downloaded to private storage"),
                                  print("Moving from private to internal storage"),
                                  await MediaStorePlusServices.pushVideoToInternal(savePath),
                                  print("Moved to internal storage"),
                                  print("download completed")
                                }).onError((error,stackTrace)=>{
                                  print("Failed to Download"),
                                  print("ERROR: ${error.toString()}")
                                });
                              } catch(error) {
                                print("Error: ${error}");
                              }
                            },
                          )
                        ],
                      ):SizedBox();
                },
              ),
            )
        ],
      ),
    );
  }
}
