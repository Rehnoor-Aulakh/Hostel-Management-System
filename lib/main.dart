import 'package:flutter/material.dart';
import 'package:hostel_management/main_screen.dart';
import 'add_hostel.dart';

void main() {
  runApp(MaterialApp(
      routes: {
        '/addHostel': (context) => AddHostelScreen(),
        // '/updateHostel': (context) => UpdateHostelScreen()
      },
      theme: ThemeData(
        primaryColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 60, 10, 127),
          foregroundColor: Colors.white,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
          ),
        ),
      ),
      home: MainScreen()));
}
