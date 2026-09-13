import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:you_pirate_app/Screens/Home.dart';
import 'package:you_pirate_app/Screens/Maintenance.dart';
import 'package:you_pirate_app/Screens/Update.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  CollectionReference reference = FirebaseFirestore.instance.collection("SERVICES");
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 1), () async{
      final maintenanceData = await reference.doc("maintenance").get();
      final updateData = await reference.doc("update").get();
      final info = await PackageInfo.fromPlatform();
      if(false) {
        // maintenanceData['on_maintenance']
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){
          return Maintenance();
        }));
      } else if(updateData['is_update']) {
        // updateData['is_update']
        if(info.version != updateData['version']) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){
            return Update(currentVersion: info.version, data: updateData);
          }));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder){
            return Home();
          }));
        }

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