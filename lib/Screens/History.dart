import 'package:flutter/material.dart';

class DownloadHistory extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Downloads"),
      ),
      body: Container(
        height: 100,width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.red
        ),
        child: Center(child: Text("Hello, Pandora!"),),
      ),
    );
  }
}