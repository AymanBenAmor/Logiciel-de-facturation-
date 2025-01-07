import 'package:achraf_app/welcome_page.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages




void main() {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(

      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: WelcomePage(), // Use the ButtonPage widget
    );
  }
}
