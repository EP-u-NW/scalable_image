import 'package:flutter/material.dart';
import 'package:scalable_image/scalable_image.dart';

void main() {
  runApp(new MaterialApp(
      theme: new ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green
      ),
      title: 'Scalable Image Example',
      home: new MainPage()
  ));
}
class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Scalable Image Example'),
        centerTitle: true,
      ),
      body: new Container(
        alignment: Alignment.center,
        child: new ScalableImage(
          imageProvider: new AssetImage('assets/example.png'),
          dragSpeed: 4.0,
          maxScale: 16.0,
          wrapInAspect: false,
          enableScaling: true,
        ),
      ),
    );
  }
}
