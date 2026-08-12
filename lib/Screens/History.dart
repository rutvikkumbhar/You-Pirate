import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:you_pirate_app/Database/database_services.dart';
import 'package:you_pirate_app/Services/SnackbarServices.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class DownloadHistory extends StatefulWidget {
  @override
  State<DownloadHistory> createState() => _DownloadHistoryState();
}

class _DownloadHistoryState extends State<DownloadHistory> {

  bool isDataAvailable = false;

  Future<void> openMediaFile(BuildContext context, String path) async {
    final file = File(path);
    if(!await file.exists()) {
      SnackbarServices().error(context, "File does not exists");
      return;
    }
   await OpenFilex.open(path);
  }

  Future<void> shareMediaFile(BuildContext context, String path) async {
    final file = File(path);
    if(!await file.exists()) {
      SnackbarServices().error(context, "File does not exists");
      return;
    }
    await SharePlus.instance.share(
      ShareParams(
        text: "Shared from You Pirate!",
        files: [XFile(path)]
      )
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff111111),
      appBar: AppBar(
        backgroundColor: Color(0xff111111),
        title: Text("Download History",
        style: GoogleFonts.poppins(
          fontSize: 17,
          color: Colors.white,
          fontWeight: FontWeight.w500
        ),),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        actions: [
          IconButton(
            icon: Icon(Boxicons.bxs_trash, size: 22, color: Colors.red.withValues(alpha: 0.7),),
            onPressed: () async {
              if(isDataAvailable) {
                bool isDeleted = await deleteDownloadConfirmation("", false) ?? false;
                if(isDeleted) {
                  setState(()=>{});
                }
              } else {
                SnackbarServices().warning(context, "No Records to Delete!");
              }
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: DatabaseServices().getDownloads(),
        builder: (builder, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Lottie.asset("assets/Animations/stream_loading.json", height: 100));
          } else if(snapshot.hasError) {
            return Center(
              child: Text("Something went wrong",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500
              ),),
            );
          } else if(snapshot.data!.isEmpty || snapshot.hasData == false) {
            isDataAvailable = false;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset("assets/Animations/no_downloads.json", height: 100),
                  Text("No Downloads Yet!",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),),
                ],
              ),
            );
          } else {
            isDataAvailable = true;
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index){
                final data = snapshot.data?[index] as Map<String, dynamic>;
                return downloadHistoryCard(data);
              },
            );
          }
        },
      )
    );
  }

  Widget metaDataRow (Widget icon,String key, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 12,),
            Text(key, style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400
            ),),
          ],
        ),
        SizedBox(width: 55,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w400
              ),),
            ],
          ),
        )
      ],
    );
  }

  Future<dynamic> mediaMetaDataDialog(Map<String, dynamic> data) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xff1B1B1B),
          insetPadding: EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 130,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: data['thumbnail']!= null
                            ? NetworkImage(data['thumbnail'])
                            : AssetImage("assets/images/no-thumbnail.png"),
                        fit: BoxFit.cover)
                  ),
                ),
                SizedBox(height: 12,),
                Text("${data['title']}", style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w500
                ),),
                SizedBox(height: 20,),
                metaDataRow(
                  Icon(Boxicons.bxl_youtube,color: Color(0xff503bd1),size: 20,),
                  "Platform", data['platform']
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bxs_movie_play,color: Color(0xff503bd1),size: 20,),
                    "Media Type", data['mediaType'].toString().toUpperCase()
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bxs_film,color: Color(0xff503bd1),size: 20,),
                    "Quality", data['quality']
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bx_hash,color: Color(0xff503bd1),size: 20,),
                    "Format ID", data['formatId']
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bxs_file,color: Color(0xff503bd1),size: 20,),
                    "Extension", data['extension'].toString().toUpperCase()
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bx_time,color: Color(0xff503bd1),size: 20,),
                    "Duration", data['duration'].toString().isNotEmpty ? data['duration'] : "NA"
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bxs_data,color: Color(0xff503bd1),size: 20,),
                    "File Size", data['fileSize']
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bxs_calendar,color: Color(0xff503bd1),size: 20,),
                    "Downloaded On", DateTime.parse(data['downloadDate'])
                    .toIso8601String()
                    .split('T')
                    .first
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bxs_folder,color: Color(0xff503bd1),size: 20,),
                    "Saved Location",
                    data['mediaType'] == "video"
                        ? "/storage/emulated/0/DCIM/You Pirate/"
                        : "/storage/emulated/0/Music/You Pirate/"
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Container(
                    height: 0.5,width: MediaQuery.of(context).size.width,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                ),
                metaDataRow(
                    Icon(Boxicons.bx_link,color: Color(0xff503bd1),size: 20,),
                    "Original URL", ""
                ),
                SizedBox(height: 5,),
                TextField(
                  readOnly: true ,
                  decoration: InputDecoration(
                    hintText: data['sourceUrl'],
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12
                    ),
                    filled: true,
                    fillColor: Color(0xff111111),
                    contentPadding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Color(0xff503bd1).withValues(alpha: 0.3),width: 1.8,)
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xff503bd1).withValues(alpha: 0.3),width: 1.8,)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Color(0xff503bd1).withValues(alpha: 0.3),width: 1.8,)
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Boxicons.bx_copy, color: Color(0xff503bd1),size: 21,),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: data['sourceUrl'].toString()));
                      },
                    )
                  ),
                ),
                SizedBox(height: 15,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Boxicons.bxs_trash, size: 23, color: Colors.red.withValues(alpha: 0.7),),
                      onPressed: () async {
                        // String videoPath = "/storage/emulated/0/DCIM/You Pirate/"+data['title'];
                        // String audioPath = "/storage/emulated/0/Music/You Pirate/"+data['title'];
                        // bool isVideo = data['mediaType'] == "video" ? true : false;
                        // await shareMediaFile(context, data['filePath'] );
                        bool isDeleted = await deleteDownloadConfirmation(data['id'].toString(), true);
                        if(isDeleted) {
                          Navigator.pop(context, true);
                        }
                      },
                    ),
                    SizedBox(width: 15,),
                    GestureDetector(
                      onTap: () async {
                        // String videoPath = "/storage/emulated/0/DCIM/You Pirate/"+data['title'];
                        // String audioPath = "/storage/emulated/0/Music/You Pirate/"+data['title'];
                        // bool isVideo = data['mediaType'] == "video" ? true : false;
                        // print("OPEN MEDIA FILE PATH $audioPath");
                       await  openMediaFile(context, data['filePath'] );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Color(0xff503bd1).withValues(alpha: 0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Center(
                            child: Text("Open File", style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Color(0xff503bd1),
                                fontWeight: FontWeight.w500
                            ),),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    GestureDetector(
                      onTap: () async {
                        await shareMediaFile(context, data['filePath'] );
                      },
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Color(0xff503bd1).withValues(alpha: 0.4)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: Center(
                            child: Text("Share", style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Color(0xff503bd1),
                                fontWeight: FontWeight.w500
                            ),),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Widget downloadHistoryCard(Map<String, dynamic> data) {
    return GestureDetector(
      onTap: () async {
        bool isDeleted = await mediaMetaDataDialog(data) ?? false;
        if(isDeleted) {
          setState(()=>{});
        }
      },
      child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
          child: Container(
              height: 75,width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: Color(0xff1B1B1B),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: Color(0xff503bd1).withValues(alpha: 0.2),),
              ),
              child:Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Row(mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 45,width: 45,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xff503bd1).withValues(alpha: 0.7),
                      ),
                      child: Center(
                          child: data['mediaType']=="video"
                              ? Icon(Boxicons.bxs_video, size: 23,color: Colors.white70,)
                              : FaIcon(FontAwesomeIcons.itunesNote,size: 20,color: Colors.white70,)
                      ),
                    ),
                    SizedBox(width: 15,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((data['title'].toString().length) > 35 ? "${data['title'].toString().substring(0,35)}..." : data['title'],
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text("${data['extension'].toString().toUpperCase()}",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Color(0xff503bd1),
                                  fontWeight: FontWeight.w500
                              ),),
                            SizedBox(width: 11,),
                            Text("•",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500
                              ),),
                            SizedBox(width: 11,),
                            Text("${data['quality']}",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500
                              ),),
                            SizedBox(width: 11,),
                            Text("•",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500
                              ),),
                            SizedBox(width: 11,),
                            Text("${data['fileSize']}",
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w500
                              ),),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              )
          )
      ),
    );
  }

  Future<dynamic> deleteDownloadConfirmation (String recordId, bool isSingle) {
    return showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Confirm Deletion",
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w500
                  ),),
                Text("This action will not affect your original media file",
                  style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500
                  ),),
              ],
            ),
            backgroundColor: Color(0xff1B1B1B),
            content: Lottie.asset("assets/Animations/delete.json", height: 110,width: 110),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Color(0xff503bd1))
                        ),
                        child: Center(
                          child: Text("Cancel",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Color(0xff503bd1),
                                fontWeight: FontWeight.w500
                            ),),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if(isSingle) {
                          await DatabaseServices().deleteDownloadById(recordId).then((result)=>{
                            SnackbarServices().success(context, "Download History Deleted!"),
                            Navigator.pop(context,true),
                          }).onError((error, stackTrace)=>{
                            SnackbarServices().error(context, error.toString()),
                            Navigator.pop(context, false),
                          });
                        } else {
                          await DatabaseServices().deleteAllDownload().then((result)=>{
                            SnackbarServices().success(context, "Download History Deleted!"),
                            Navigator.pop(context, true),
                          }).onError((error, stackTrace)=>{
                            SnackbarServices().error(context, error.toString()),
                            Navigator.pop(context, false),
                          });
                        }
                      },
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: Color(0xffD90000),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text("Delete",
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w500
                            ),),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        });
  }
}