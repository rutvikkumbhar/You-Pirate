import 'package:flutter/material.dart';
import 'Screens/Home.dart';

void main() {
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