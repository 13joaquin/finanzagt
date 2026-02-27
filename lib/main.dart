/*import 'dart:ffi';*/
/*import 'dart:ui';*/

import 'package:finanzagt/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas GT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0A4D68)),
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      home:  MainLayoutScreen() ,
    );
  }
}