import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:you_pirate_app/Screens/Home.dart';
import 'package:you_pirate_app/Screens/Maintenance.dart';

class Splash extends StatefulWidget {
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  CollectionReference reference = FirebaseFirestore.instance.collection("SERVICES");
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () async{
      final data = await reference.doc("maintenance").get();
      if(data['on_maintenance']) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){
          return Maintenance();
        }));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){
          return Home();
        }));
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 70,width: 70,
                child: Image.asset("assets/images/app-logo.png"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}