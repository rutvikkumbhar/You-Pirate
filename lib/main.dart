import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:you_pirate_app/Screens/Splash.dart';
import 'Screens/Home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'Screens/Maintenance.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "You Pirate";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "You Pirate",
      home: Splash(),
      debugShowCheckedModeBanner: false,
    );
  }

  // CollectionReference reference = FirebaseFirestore.instance.collection("SERVICES");
  // Future<bool> isMaintenanceMode() async {
  //   final data = await reference.doc("maintenance").get();
  //   return data['on_maintenance'];
  // }
}