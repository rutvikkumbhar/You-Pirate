import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:you_pirate_app/Database/database_services.dart';

class DownloadHistory extends StatelessWidget {
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
            icon: Icon(Icons.delete_rounded, color: Colors.red.withValues(alpha: 0.7),),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Confirm to delete download history"),
                      backgroundColor: Color(0xff1B1B1B),
                      // delete download options
                    );
                  });
            },
          )
        ],
      ),
      body: FutureBuilder(
        future: DatabaseServices().getDownloads(),
        builder: (builder, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Lottie.asset("assets/Animations/loading.json", height: 100));
          } else if(snapshot.hasError) {
            return Center(
              child: Text("Something went wrong",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.red,
                fontWeight: FontWeight.w500
              ),),);
          } else if(snapshot.data!.isEmpty || snapshot.hasData == false) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset("assets/Animations/no_downloads.json", height: 100),
                  Text("No Downloads Yet!!!",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),)
                ],
              ),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index){
                final data = snapshot.data?[index] as Map<String, dynamic>;
                return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                    child: Container(
                        height: 75,width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            color: Color(0xff1B1B1B),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: Color(0xff503bd1).withValues(alpha: 0.2))
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
                                    child: data['mediaType']=="video" ? Icon(Boxicons.bxs_film, size: 23,color: Colors.white70,)
                                        : FaIcon(FontAwesomeIcons.itunesNote,size: 20,color: Colors.white70,)),
                              ),
                              SizedBox(width: 15,),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text((data['title'].toString().length) >35?"${data['title'].toString().substring(0,35)}...":data['title'],
                                    style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500
                                    ),),
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
                        ))
                );
              },
            );
          }
        },
      )
    );
  }
}