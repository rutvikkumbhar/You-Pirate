import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:you_pirate_app/API%20Services/VideoServices.dart';
import 'package:path_provider/path_provider.dart';
import 'package:you_pirate_app/Services/MediaStorePlusServices.dart';
import 'package:you_pirate_app/Services/SnackbarServices.dart';

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
  bool fetchingVideo = false;
  bool isVideo = true;

  // Temp Data Here
  String tempTitle = "This is the video title which should have to be this long or more than this so i can trim it accordingly";
  String bytesToMb(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2);
  }
  String mbToGb(int mb) {
    return (mb / 1024).toStringAsFixed(2);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff111111),
      appBar: AppBar(title: Text("You Pirate",
          style: GoogleFonts.akayaTelivigala(
            textStyle: const TextStyle(
                fontSize: 24,
                color: Colors.white),)),
          centerTitle: true,
      backgroundColor: Color(0xff111111),),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: ListView(
          children: [
            SizedBox(height: 30,),
            TextField(
              keyboardType: TextInputType.url,
              controller: urlController,
              decoration: InputDecoration(
                hintText: "Paste link",
                hintStyle: TextStyle(color: Colors.white60,),
                filled: true,
                fillColor: Color(0xff1B1B1B),
                prefixIcon: Icon(
                  Boxicons.bx_link,
                  color: Colors.white60,),
                suffixIcon: IconButton(
                  icon: Icon(Boxicons.bxs_send, color: Colors.white60,),
                  onPressed: () async {
                    if(urlController.text.isEmpty){
                      SnackbarServices().error(context,"Link to dal lavde");
                    } else {
                      setState(() => infoLoading = true);
                      try {
                        VideoServices.getVideoInfo(urlController.text).then((result) => {
                          setState(()=>infoLoading=false),
                          videoInfo = result,
                          formats = videoInfo?['formats'],
                        }
                        ).onError((error, stackTrace) {
                          setState(() => infoLoading = false);
                          throw error.toString();
                        });
                      } catch (error) {
                        print("ERROR: ${error.toString()}");
                        SnackbarServices().error(context, error.toString());
                      }
                    }
                    },
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Color(0xff6D5DF6).withValues(alpha: 0.3))
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Color(0xff6D5DF6).withValues(alpha: 0.3))
                ),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: BorderSide(color: Color(0xff6D5DF6).withValues(alpha: 0.4))
                ),),
            ),
            SizedBox(height: 15,),
            infoLoading?Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: LinearProgressIndicator(),
            ):SizedBox(),
            SizedBox(height: 15,),
            Container(
              height: 120,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xff1B1B1B),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Color(0xff6D5DF6).withValues(alpha: 0.2))
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.width,
                          width: 180,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(5),
                              image: DecorationImage(image: AssetImage("assets/test.webp"),
                                  fit: BoxFit.cover)
                          ),
                        ),
                        Positioned(
                          bottom: 1,right: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Center(
                                child: Text("3:23",
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.white,
                                    fontWeight: FontWeight.w600
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ]
                    ),
                    SizedBox(width: 11,),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tempTitle.length>80?"${tempTitle.substring(0,50)}...":tempTitle,
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w500),),
                          Text("Channel Name", style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 13,
                          ),),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 15,),
            GestureDetector(
              onTap: () async {
                try {
                  setState(() => fetchingVideo = true);
                  Directory dir = await getApplicationDocumentsDirectory();
                  String savePath = "${dir.path}/${videoInfo?['title']}.mp4";
                  VideoServices.downloadVideo(
                      url: urlController.text.toString(),
                      savePath: savePath,
                      onProgress: (received, total)=>{
                        if (total != -1) {
                          fetchingVideo = false,
                          progress = received / total,
                          totalBytes = total,
                          receivedBytes = received,
                          setState(() => {}),
                        },
                      }).then((result) async =>{
                    // progress,totalBytes,receivedBytes=0,
                    debugPrint("Media downloaded"),
                    debugPrint("Pushing file into Internal Storage"),
                    await MediaStorePlusServices.pushVideoToInternal(
                      savePath,
                    ),
                    debugPrint("Stored into Internal Storage"),
                    SnackbarServices().success(context, "Download Completed")
                  });
                } catch(error) {
                  SnackbarServices().error(context, error.toString());
                }
              },
              child: Container(
                height: 75,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xff523CD3),
                  borderRadius: BorderRadius.circular(13)
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Boxicons.bxs_bolt, color: Colors.white,size: 18,),
                          SizedBox(width: 13,),
                          Text("Quick Download",
                          style: GoogleFonts.poppins(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.w600
                          ),)
                        ],
                      ),
                      Text("Best Quality (Video + Audio)",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500
                      ),),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            fetchingVideo?Lottie.asset("assets/Animations/loading.json",height: 50,width: 50):SizedBox(),
            SizedBox(height: 10),
            Container(
              height: 55, width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Color(0xff1B1B1B),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Color(0xff6D5DF6).withValues(alpha: 0.2))
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: ()=>setState(()=>isVideo=true),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5,top: 5,bottom: 5),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: isVideo?Color(0xff503bd1):Colors.transparent,
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.videocam_rounded,size: 19,color: isVideo?Colors.white:Colors.white70,),
                              SizedBox(width: 10,),
                              Text("Video",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: isVideo?Colors.white:Colors.white70,
                                fontWeight: FontWeight.w500
                              ),),
                            ],
                          )),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: ()=>setState(()=>isVideo=false),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5,bottom: 5,right: 5),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                              color: isVideo?Colors.transparent:Color(0xff503bd1),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Center(child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.itunesNote,size: 14,color: isVideo?Colors.white70:Colors.white,),
                              SizedBox(width: 10,),
                              Text("Audio",
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: isVideo?Colors.white70:Colors.white,
                                    fontWeight: FontWeight.w500
                                ),),
                            ],
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 200),
              child: isVideo? Container(
                height: 50,width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xff1B1B1B),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Color(0xff503bd1).withValues(alpha: 0.2))
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: Color(0xff3B2C88),
                              borderRadius: BorderRadius.circular(5)
                            ),
                            child: Center(
                              child: Text("1080p",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color(0xff9F8DF0),
                                  fontWeight: FontWeight.w500
                                ),),),
                          ),
                          Text("MP4", style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.red,
                            fontWeight: FontWeight.w500
                          ),)
                        ],
                      )
                    ],
                  ),
                ),
              ) : Row(
                children: [

                ],
              ),
            ),
            SizedBox(height: 20,),
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
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 30),
            //   child: Container(
            //     height: 180,width: MediaQuery.of(context).size.width,
            //     decoration: BoxDecoration(
            //         image: DecorationImage(image: NetworkImage(videoInfo?['thumbnail'] ?? ""),
            //             fit: BoxFit.cover)
            //     ),
            //   ),
            // ),
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
                              "${data['fps']} | "
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
                                  VideoServices.downloadVideoById(
                                      url: url,
                                      formatId: data['format_id'],
                                      savePath: savePath,
                                      onProgress: (received, total)=>{
                                        if(total != -1){
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
                                    print("download completed"),
                                    setState((){
                                      progress=0;
                                      receivedBytes=0;
                                      totalBytes=0;
                                    }),
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Download Completed")))
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
      ),
    );
  }
}
