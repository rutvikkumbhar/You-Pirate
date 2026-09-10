import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class Maintenance extends StatelessWidget {
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
              Lottie.asset("assets/Animations/chill_guy.json", height: 190),
            ],
          ),
          SizedBox(height: 30,),
          Text("We'll Be Right Back", style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white
          ),),
          SizedBox(height: 6,),
          Text("You Pirate is currently under maintenance", style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white60
          ),),
          Text("We'll be back shortly", style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white60
          ),),
        ],
      )
    );
  }
}