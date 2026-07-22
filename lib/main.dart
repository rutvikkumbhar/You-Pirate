import 'package:flutter/material.dart';
import 'Screens/Home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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