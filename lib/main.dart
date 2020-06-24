import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Boring Show',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BoringPage(),
    );
  }
}

class BoringPage extends StatefulWidget {
  @override
  _BoringPageState createState() => _BoringPageState();
}

class _BoringPageState extends State<BoringPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('This is sooo boring...'),
      ),
    );
  }
}
