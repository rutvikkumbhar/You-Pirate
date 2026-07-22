import 'package:flutter/material.dart';
import 'Screens/Home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:media_store_plus/media_store_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await MediaStore.ensureInitialized();
  MediaStore.appFolder = "You Pirate";
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context){
    return MaterialApp(
      title: "You Pirate",
      home: Home(),
      debugShowCheckedModeBanner: true,
    );
  }
}