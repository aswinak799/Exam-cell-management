import 'package:exam_cell_staff/splash.dart';
import 'package:flutter/material.dart';

import 'login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const SAVE_KEY_NAME = "UserLogedIn";

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam cell KMCT',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: ScreenSplash(),
    );
  }
}
