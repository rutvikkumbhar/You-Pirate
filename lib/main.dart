import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:you_pirate_app/Screens/Splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_store_plus/media_store_plus.dart';
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
}