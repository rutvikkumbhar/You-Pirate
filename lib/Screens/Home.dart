import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:you_pirate_app/API%20Services/VideoServices.dart';
import 'package:path_provider/path_provider.dart';
import 'package:you_pirate_app/Database/database_helper.dart';
import 'package:you_pirate_app/Screens/History.dart';
import 'package:you_pirate_app/Services/MediaStorePlusServices.dart';
import 'package:you_pirate_app/Services/SnackbarServices.dart';
import 'package:you_pirate_app/Database/database_services.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final urlController = TextEditingController();
  final FocusNode urlInputFocus = FocusNode();
  final dio = Dio();
  final path = "/storage/emulated/0/Download/";
  double progress = 0;
  int totalBytes = 0;
  int receivedBytes = 0;
  Map<String, dynamic>? videoInfo;
  List<dynamic>? formats;
  bool infoLoading = false;
  bool isInfoAvailable = false;
  bool fetchingStream = false;
  bool fetchInfo = false;
  bool isVideo = true;
  bool isDownloading = false;
  String extension = "";
  String quality = "";
  int previousReceived = 0;
  DateTime previousTime = DateTime.now();
  double downloadSpeed = 0;
  double remainingSeconds = 0;
  double displayedSpeed = 0;
  CancelToken? downloadCancelToken;

  String bytesToMb(int bytes) {
    return (bytes / (1024 * 1024)).toStringAsFixed(2);
  }

  String mbToGb(int mb) {
    return (mb / 1024).toStringAsFixed(2);
  }

  String formatSpeed(double bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return "${bytesPerSecond.toStringAsFixed(0)} B/s";
    }
    if (bytesPerSecond < 1024 * 1024) {
      return "${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s";
    }
    return "${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s";
  }

  String formatRemaining(double seconds) {
    if (seconds.isInfinite || seconds.isNaN) {
      return "--";
    }

    final duration = Duration(seconds: seconds.round());
    if (duration.inHours > 0) {
      return "${duration.inHours}:${duration.inMinutes.remainder(60)}:${duration.inSeconds.remainder(60)}";
    }
    if (duration.inMinutes > 0) {
      return "00:${duration.inMinutes}:${duration.inSeconds.remainder(60)}:";
    }
    return "00:00:${duration.inSeconds}";
  }

  Widget build(BuildContext context) {

    // downloadCancelToken = CancelToken();
    return Scaffold(
      backgroundColor: Color(0xff111111),
      appBar: AppBar(title: Text("You Pirate",
          style: GoogleFonts.akayaTelivigala(
            textStyle: const TextStyle(
                fontSize: 24,
                color: Colors.white),)),
          centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.history,color: Colors.white70,),
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => DownloadHistory(),
                transitionsBuilder: (_, animation, _, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              ),
            );
            urlInputFocus.unfocus();
          },
        ),
      ],
      backgroundColor: Color(0xff111111),),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 13),
        child: ListView(
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 100),
              height: isInfoAvailable? 10: 180,
            ),
            TextField(
              keyboardType: TextInputType.url,
              controller: urlController,
              style: TextStyle(color: Colors.white),
              autofocus: false,
              focusNode: urlInputFocus,
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
                      SnackbarServices().error(context,"Enter video link");
                    } else if(fetchInfo){
                      urlInputFocus.unfocus();
                      SnackbarServices().warning(context, "Fetching video information");
                    } else if(isDownloading) {
                      urlInputFocus.unfocus();
                      SnackbarServices().warning(context, "Download is in progress");
                    } else {
                      urlInputFocus.unfocus();
                      setState(() => infoLoading = true);
                      fetchInfo = true;
                      try {
                        VideoServices.getVideoInfo(urlController.text).then((result) => {
                          fetchInfo = false,
                          isInfoAvailable = true,
                          setState(()=>infoLoading=false),
                          videoInfo = result,
                          formats = videoInfo?['formats'],
                        }
                        ).onError((error, stackTrace) =>{
                          fetchInfo = false,
                          isInfoAvailable = false,
                          setState(() => infoLoading = false),
                          SnackbarServices().error(context, error.toString()),
                        });
                      } catch (error) {
                        fetchInfo = false;
                        isInfoAvailable = false;
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
            if(isInfoAvailable)
              Column(
                children: [
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
                                      borderRadius: BorderRadius.circular(5),
                                      image: DecorationImage(
                                          image: videoInfo?['thumbnail'] == null? AssetImage("assets/images/no-thumbnail.png"):NetworkImage(videoInfo?['thumbnail']),
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
                                        child: Text("${videoInfo?['duration_string'] ?? "NA"}",
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
                                Text((videoInfo?['title'].toString().length ?? "".length) >50?"${videoInfo?['title'].toString().substring(0,50)}...":videoInfo?['title'] ?? "",
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500),),
                                Text("${videoInfo?['extractor'].toString().toUpperCase()} • ${videoInfo?['channel']}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500
                                ),),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 180),
                    switchInCurve: Curves.easeIn,
                    switchOutCurve: Curves.easeOut,
                    child: isDownloading ?
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Color(0xff1B1B1B),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: Color(0xff503bd1).withValues(alpha: 0.2))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("${(videoInfo?['title'].toString().length ?? "".toString().length) > 30 ? (videoInfo?['title'].toString().substring(0,30)):videoInfo?['title']}...${quality}.${extension}",
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: progress,
                                    color: Color(0xff5B46D8),
                                    backgroundColor: Color(0xff343438),
                                    borderRadius: BorderRadius.circular(10),
                                    minHeight: 6,
                                  ),
                                  SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${bytesToMb(receivedBytes)}MB / ${bytesToMb(totalBytes)}MB",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Text(
                                        formatSpeed(displayedSpeed),
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Color(0xff503bd1),
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                      Text(
                                        "${formatRemaining(remainingSeconds)} left",
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white70,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${(progress * 100).toStringAsFixed(1)}%",
                                  style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      color: Color(0xff503bd1),
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                SizedBox(height: 10,),
                                GestureDetector(
                                  onTap: () {
                                    if(fetchingStream) {
                                      SnackbarServices().warning(context, "Wait Until Media Process!");
                                    } else {
                                      downloadCancelToken!.cancel("User Canceled Download");
                                      isDownloading = false;
                                      setState((){});
                                      SnackbarServices().warning(context, "Download Canceled");
                                      previousReceived = 0;
                                      downloadSpeed = 0;
                                      extension = "";
                                      quality = "";
                                      remainingSeconds = 0;
                                      displayedSpeed = 0;
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white12
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Center(
                                        child: Icon(Boxicons.bx_x, size: 21, color: Colors.white,),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                        : GestureDetector(
                      onTap: () async {
                        if(!isDownloading){
                          try {
                            isDownloading = true;
                            extension = "mp4";
                            quality = "Best";
                            progress = 0;
                            totalBytes= 0;
                            downloadCancelToken = CancelToken();
                            setState(() => fetchingStream = true);
                            Directory dir = await getApplicationDocumentsDirectory();
                            String savePath = "${dir.path}/${videoInfo?['title']}.mp4";
                            VideoServices.downloadVideo(
                                url: urlController.text.toString(),
                                savePath: savePath,
                                downloadCancelToken: downloadCancelToken!,
                                onProgress: (received, total) {
                                  if (total != -1) {
                                    setState(() => fetchingStream = false);
                                    // Progress bar
                                    progress = received / total;
                                    totalBytes = total;
                                    receivedBytes = received;
                                    // Download Speed
                                    final now = DateTime.now();
                                    final elapsed = now.difference(previousTime).inMilliseconds / 1000;
                                    if (elapsed >= 1000) {
                                      final currentSpeed = (received - previousReceived) / (elapsed / 1000);
                                      displayedSpeed = displayedSpeed * 0.8 + currentSpeed * 0.2;
                                      previousReceived = received;
                                      previousTime = now;
                                    }
                                    //Remaining TIme
                                    final remainingBytes = total - received;
                                    remainingSeconds = remainingBytes / displayedSpeed;
                                    setState(() => {});
                                  }
                                }).then((result) async {
                                  if(!result) {
                                    return;
                                  }
                                  debugPrint("Media downloaded");
                                  debugPrint("Pushing file into Internal Storage");
                                  String? displayTitle = await MediaStorePlusServices.pushVideoToInternal(
                                    savePath,
                                  );
                                  setState(()=>isDownloading = false);
                                  progress=0;
                                  receivedBytes=0;
                                  debugPrint("Stored into Internal Storage");
                                  SnackbarServices().success(context, "Download Completed");
                                  previousReceived = 0;
                                  downloadSpeed = 0;

                                  remainingSeconds = 0;
                                  displayedSpeed = 0;
                                  await saveToDownloadHistory(displayTitle!,true, "bv*+ba/b").then((result){
                                    extension = "";
                                    quality = "";
                                    print("Data saved to local storage ");
                                  }).onError((error, stackTrace){
                                    print("ERROR: ${error.toString()}");
                                  });
                                }).onError((error, stackTrace){
                                  setState(()=>isDownloading = false);
                                  SnackbarServices().error(context, error.toString());
                                  extension = "";
                                  quality = "";
                                  previousReceived = 0;
                                  downloadSpeed = 0;
                                  remainingSeconds = 0;
                                  displayedSpeed = 0;
                                });
                          } catch(error) {
                            setState(()=>isDownloading = false);
                            previousReceived = 0;
                            downloadSpeed = 0;
                            extension = "";
                            quality = "";
                            remainingSeconds = 0;
                            displayedSpeed = 0;
                            SnackbarServices().error(context, error.toString());
                          }
                        } else {
                          SnackbarServices().warning(context, "Download is in process");
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
                  ),
                  SizedBox(height: 10,),
                  fetchingStream ?
                  Lottie.asset("assets/Animations/loading.json",height: 50,width: 50)
                      : SizedBox(),
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
                                duration: Duration(milliseconds: 180),
                                decoration: BoxDecoration(
                                    color: isVideo ? Color(0xff503bd1) : Colors.transparent,
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
                                      ),
                                    ),
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
                                duration: Duration(milliseconds: 180),
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
                    switchOutCurve: Curves.easeOut,
                    switchInCurve: Curves.easeIn,
                    child: VideoAudioQualityCard(
                        isVideo: isVideo,
                        downloadCancelToken: downloadCancelToken ?? CancelToken()
                    )
                  ),
                ],
              )
            else
              Column(
                children: [
                  Lottie.asset("assets/Animations/chill_guy.json",height: 200),
                  Text("Paste a video link",
                    style: GoogleFonts.poppins(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w600
                    ),),
                  SizedBox(height: 30,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     Container(
                       height: 110,
                       width: 120,
                       decoration: BoxDecoration(
                         color: Color(0xff1B1B1B),
                         borderRadius: BorderRadius.circular(13)
                       ),
                       child: Padding(
                         padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 10),
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           crossAxisAlignment: CrossAxisAlignment.center,
                           children: [
                             Container(
                               decoration: BoxDecoration(
                                 shape: BoxShape.circle,
                                 color: Color(0xff503bd1).withValues(alpha: 0.6),
                               ),
                               child: Padding(
                                 padding: const EdgeInsets.all(7),
                                 child: Center(
                                   child: Icon(Boxicons.bxs_bolt,color: Colors.white,size: 22,),
                                 ),
                               ),
                             ),
                             Text("Fast Downloads", style: GoogleFonts.poppins(
                               fontSize: 13,
                               color: Colors.white,
                               fontWeight: FontWeight.w500,
                             ),
                             textAlign: TextAlign.center,)
                           ],
                         ),
                       ),
                     ),
                      Container(
                        height: 110,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Color(0xff1B1B1B),
                            borderRadius: BorderRadius.circular(13)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff503bd1).withValues(alpha: 0.6),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Center(
                                    child: Icon(Boxicons.bxs_film,color: Colors.white,size: 22,),
                                  ),
                                ),
                              ),
                              Text("Multiple Video Qualities", style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                                textAlign: TextAlign.center,)
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 110,
                        width: 120,
                        decoration: BoxDecoration(
                            color: Color(0xff1B1B1B),
                            borderRadius: BorderRadius.circular(13)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xff503bd1).withValues(alpha: 0.6),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(7),
                                  child: Center(
                                    child: Icon(Boxicons.bxs_music,color: Colors.white,size: 22,),
                                  ),
                                ),
                              ),
                              Text("Audio Downloads", style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                                textAlign: TextAlign.center,)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }

  Future<void> saveToDownloadHistory  (String savedTitle, bool isVideo, String formatId) async {
    print("DISPLAYED VIDEO TITLE: $savedTitle");
    // print("SAVED VIDEO PATH $savePath");
    String filePath;
    if(isVideo) {
      filePath = "/storage/emulated/0/DCIM/You Pirate/"+savedTitle;
    } else {
      filePath = "/storage/emulated/0/Music/You Pirate/"+savedTitle;
    }
    // String videoPath = "/storage/emulated/0/DCIM/You Pirate/"+title;
    // String audioPath = "/storage/emulated/0/Music/You Pirate/"+title;
    print("SAVED VIDEO PATH $filePath");
    try {
      await DatabaseServices().insertDownload({
        'title': videoInfo?['title'].toString(),
        'thumbnail': videoInfo?['thumbnail'].toString(),
        'sourceUrl': urlController.text.toString(),
        'platform': videoInfo?['extractor'].toString().toUpperCase(),
        'mediaType': isVideo ? "video" : "audio",
        'formatId': formatId,
        'quality': quality,
        'extension': extension,
        'filePath': filePath,
        'fileSize': double.parse(bytesToMb(totalBytes))>1024?"${(double.parse(bytesToMb(totalBytes))/1024).toStringAsFixed(2)} GB":"${bytesToMb(totalBytes)} MB",
        'duration': videoInfo?['duration_string'].toString(),
        'downloadDate': DateTime.now().toString(),
        'status': 1,
      }).onError((error, stackTrace){
        throw error.toString();
      });
    } catch(error) {
      throw error.toString();
    }
  }

  Future<void> downloadFileById({
    required String url,
    required String formatID,
    required bool isVideo,
    required String quality,
    required CancelToken downloadCancelToken,
  }) async {
    if(!isDownloading) {
      try {
        isDownloading = true;
        totalBytes= 0;
        progress = 0;
        extension = isVideo ? "mp4" : "m4a";
        this.quality = quality;
        // qualityVideoCancelToken = CancelToken();
        setState(() => fetchingStream = true);
        Directory dir = await getApplicationDocumentsDirectory();
        String savePath = "${dir.path}/${videoInfo?['title']}.$extension";
        VideoServices.downloadFileById(
            url: url,
            formatId: formatID,
            savePath: savePath,
            isVideo: isVideo,
            downloadCancelToken: downloadCancelToken,
            onProgress: (received, total) {
              setState(() => fetchingStream = false);
              // Progress bar
              receivedBytes = received;
              totalBytes = total;
              progress = receivedBytes / totalBytes;
              // Download Speed
              final now = DateTime.now();
              final elapsed = now.difference(previousTime).inMilliseconds / 1000;
              if (elapsed >= 1000) {
                final currentSpeed = (received - previousReceived) / (elapsed / 1000);
                displayedSpeed = displayedSpeed * 0.8 + currentSpeed * 0.2;
                previousReceived = received;
                previousTime = now;
              }
              // Remaining Time
              final remainingBytes = total - received;
              remainingSeconds = remainingBytes / displayedSpeed;
              setState(()=>{});
            }).then((result) async {
              if(!result) {
                return;
              }
              debugPrint("Media downloaded");
              debugPrint("Pushing file into Internal Storage");
              // await MediaStorePlusServices.pushVideoToInternal(savePath),
          String? displayTitle;
          if(isVideo) {
            displayTitle = await MediaStorePlusServices.pushVideoToInternal(savePath);
          } else {
            displayTitle =
            await MediaStorePlusServices.pushAudioToInternal(savePath);
          }
          setState(()=>isDownloading = false);
          progress =0;
          receivedBytes=0;
          print("Download Completed");
          SnackbarServices().success(context, "Download Completed");
          await saveToDownloadHistory(displayTitle!, isVideo, formatID).then((result){
            print("Data saved to local storage ");
          }).onError((error, stackTrace){
            print("ERROR: ${error.toString()}");
          });
          totalBytes = 0;
          extension = "";
          quality = "";
          previousReceived = 0;
          downloadSpeed = 0;
          remainingSeconds = 0;
          displayedSpeed = 0;
        }).onError((error, stackTrace){
          setState(()=>isDownloading = false);
          SnackbarServices().error(context, error.toString());
          extension = "";
          quality = "";
          previousReceived = 0;
          downloadSpeed = 0;
          remainingSeconds = 0;
          displayedSpeed = 0;
        });
      } catch(error) {
        SnackbarServices().error(context, error.toString());
        setState(()=>isDownloading = false);
        extension = "";
        quality = "";
        previousReceived = 0;
        downloadSpeed = 0;
        remainingSeconds = 0;
        displayedSpeed = 0;
      }
    } else {
      SnackbarServices().warning(context, "Download is in process");
    }
  }

  Widget VideoAudioQualityCard({
    required bool isVideo,
    required CancelToken downloadCancelToken
  }) {
    // CancelToken qualityFileCancelToken;
    return SizedBox(
      height: 350, width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        itemCount: formats?.length,
        itemBuilder: (context,index){
          final data = formats?[index] as Map<String, dynamic>?;
          final size = data?['filesize'];

          return (data?['ext']== (isVideo ? "mp4" : "m4a") && (isVideo ? ((data?['vbr'] ?? 0) as num).toInt()>0 : true)) ? Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Container(
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
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          decoration: BoxDecoration(
                              color: Color(0xff3B2C88),
                              borderRadius: BorderRadius.circular(5)
                          ),
                          child: Center(
                            child: Text("${data?['format_note'] ?? "NA"}",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color(0xff9F8DF0),
                                  fontWeight: FontWeight.w500
                              ),),),
                        ),
                        SizedBox(width: 10,),
                        Text("${data?['ext']}", style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xffB8B8BD),
                            fontWeight: FontWeight.w500
                        ),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text("•",style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(0xffB8B8BD),
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                        Text(
                            isVideo
                                ? "${data?['fps'] ?? '-'} FPS"
                                : "${data?['audio_channels'] ?? '-'} CH",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(0xffB8B8BD),
                              fontWeight: FontWeight.w500
                          ),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text("•",style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(0xffB8B8BD),
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                        Text("${(((isVideo ? (data?['vbr']) : (data?['abr'])) ?? 0) as num).toInt()}k", style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Color(0xffB8B8BD),
                            fontWeight: FontWeight.w500
                        ),),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 7),
                          child: Text("•",style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(0xffB8B8BD),
                              fontWeight: FontWeight.w500
                          ),),
                        ),
                        Text("${size == null ? 'Unknown' : '${double.parse(bytesToMb(size))>1024?(double.parse(bytesToMb(size))/1024).toStringAsFixed(2)+" GB":bytesToMb(size)+" MB"}'}",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Color(0xffB8B8BD),
                              fontWeight: FontWeight.w500
                          ),),
                      ],
                    ),
                    GestureDetector(
                      child: Padding(
                        padding: const EdgeInsets.only(right:  5),
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xff503bd1).withValues(alpha: 0.2)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(9),
                            child: Center(
                                child: FaIcon(FontAwesomeIcons.arrowDown, color: Color(0xff503bd1),size: 16,)),
                          ),
                        ),
                      ),
                      onTap: () async {
                        // qualityFileCancelToken = CancelToken();
                        await downloadFileById(
                            url: urlController.text.toString(),
                            formatID: data?['format_id'],
                            isVideo: isVideo,
                            downloadCancelToken: downloadCancelToken,
                            quality: "${data?['format_note']}");
                      },
                    )
                  ],
                ),
              ),
            ),
          ) : SizedBox();
        },
      ),
    );
  }
}
