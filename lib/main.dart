import 'package:flutter/material.dart';
import 'package:surya/welcome.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crime Management System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WelcomePage(), // This page is shown first
    );
  }
}
