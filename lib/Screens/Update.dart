import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Home.dart';

class Update extends StatefulWidget {
  late DocumentSnapshot data;
  Update({super.key, required this.data});
  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff111111),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/update-logo.png",height: 180, width: 180,)
              ],
            ),
            SizedBox(height: 20,),
            Text("Update Available", style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white
            ),),
            SizedBox(height: 8,),
            Text("Version ${widget.data['version']}", style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white60
            ),),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(widget.data['note'], style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white60
              ),
              textAlign: TextAlign.center,),
            ),
            SizedBox(height: 40,),
            GestureDetector(
              onTap: () {
                // You pirate website redirector
              },
              child: Container(
                height: 48, width: 150,
                decoration: BoxDecoration(
                  color: Color(0xff503bd1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text("Update Now",  style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white
                  )),
                ),
              ),
            ),
            SizedBox(height: 30,),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushAndRemoveUntil( MaterialPageRoute(builder: (context) => Home()),
                      (Route<dynamic> route) => false,);
              },
              child: Center(
                child: Text("Later",  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xff503bd1)
                )),
              ),
            ),
          ],
        )
    );
  }
}