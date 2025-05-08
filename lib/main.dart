import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_page.dart';

void main() => runApp(CheckMeApp());

class CheckMeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CheckMe ToDo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
      routes: {
        '/home': (_) => HomePage(),
      },
    );
  }
}
